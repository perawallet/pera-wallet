/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ledger

import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import androidx.lifecycle.Lifecycle
import com.algorand.algosdk.mobile.Mobile
import com.algorand.android.R
import com.algorand.android.ledger.operations.AccountFetchAllOperation
import com.algorand.android.ledger.operations.BaseOperation
import com.algorand.android.ledger.operations.BaseTransactionOperation
import com.algorand.android.ledger.operations.ExternalTransactionOperation
import com.algorand.android.ledger.operations.TransactionOperation
import com.algorand.android.ledger.operations.VerifyAddressOperation
import com.algorand.android.ledger.operations.WalletConnectTransactionOperation
import com.algorand.android.models.LedgerBleResult
import com.algorand.android.usecase.AccountInformationUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.LifecycleScopedCoroutineOwner
import com.algorand.android.utils.getPublicKey
import com.algorand.android.utils.recordException
import com.algorand.android.utils.sendErrorLog
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancelChildren
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch
import no.nordicsemi.android.ble.observer.ConnectionObserver

class LedgerBleOperationManager @Inject constructor(
    private val accountInformationUseCase: AccountInformationUseCase,
    private val ledgerBleConnectionManager: LedgerBleConnectionManager
) : LifecycleScopedCoroutineOwner(), LedgerBleObserver {

    val connectedBluetoothDevice: BluetoothDevice?
        get() = ledgerBleConnectionManager.bluetoothDevice

    val ledgerBleResultFlow = MutableStateFlow<Event<LedgerBleResult>?>(null)
    private var currentOperation: BaseOperation? = null

    private var currentTransactionIndex: Int? = null
    private var totalTransactionCount: Int? = null

    fun setup(lifecycle: Lifecycle) {
        ledgerBleConnectionManager.setObserver(this)
        assignToLifecycle(lifecycle)
    }

    override fun onBondingFailed(device: BluetoothDevice) {
        postResult(LedgerBleResult.OnBondingFailed)
    }

    fun isBondingRequired(address: String): Boolean {
        return BluetoothAdapter.getDefaultAdapter().bondedDevices.all {
            it.address != address
        }
    }

    fun startLedgerOperation(
        newOperation: BaseOperation,
        currentTransactionIndex: Int? = null,
        totalTransactionCount: Int? = null
    ) {
        currentOperation = newOperation
        currentScope.launch {
            when (newOperation) {
                is TransactionOperation,
                is AccountFetchAllOperation,
                is WalletConnectTransactionOperation,
                is ExternalTransactionOperation -> {
                    if (currentTransactionIndex != null && totalTransactionCount != null) {
                        this@LedgerBleOperationManager.currentTransactionIndex = currentTransactionIndex
                        this@LedgerBleOperationManager.totalTransactionCount = totalTransactionCount
                    }
                    sendPublicKeyRequest()
                }
                is VerifyAddressOperation -> {
                    verifyPublicKeyRequest(newOperation)
                }
            }
        }
    }

    private suspend fun verifyPublicKeyRequest(newOperation: VerifyAddressOperation) {
        currentOperation?.run {
            if (connectToLedger(bluetoothDevice)) {
                ledgerBleConnectionManager.sendVerifyPublicKeyRequest(newOperation.indexOfAddress)
                nextIndex++
            }
        }
    }

    private suspend fun sendTransactionRequest() {
        (currentOperation as? BaseTransactionOperation)?.run {
            val currentTransactionData = transactionByteArray
            if (currentTransactionData != null) {
                if (connectToLedger(bluetoothDevice)) {
                    ledgerBleConnectionManager.sendSignTransactionRequest(currentTransactionData, nextIndex - 1)
                    val ledgerBleResult = LedgerBleResult.LedgerWaitingForApproval(
                        bluetoothName = bluetoothDevice.name,
                        currentTransactionIndex = currentTransactionIndex,
                        totalTransactionCount = totalTransactionCount
                    )
                    postResult(ledgerBleResult).also {
                        // After sending [LedgerWaitingForApproval] modal to ui, we need to clear value of indexes
                        currentTransactionIndex = null
                        totalTransactionCount = null
                    }
                }
            }
        }
    }

    private suspend fun sendPublicKeyRequest() {
        currentOperation?.run {
            if (connectToLedger(bluetoothDevice)) {
                ledgerBleConnectionManager.sendPublicKeyRequest(nextIndex)
                nextIndex++
            }
        }
    }

    override fun onDataReceived(device: BluetoothDevice, byteArray: ByteArray) {
        currentOperation?.run {
            when {
                this is BaseTransactionOperation && isAddressVerified -> {
                    onTransactionSignatureReceived(byteArray)
                }
                else -> {
                    val accountPublicKey = getPublicKey(byteArray)
                    if (!accountPublicKey.isNullOrBlank()) {
                        onPublicKeyReceived(device, accountPublicKey)
                    }
                }
            }
        } ?: run {
            recordException(Exception("LedgerBleOperationManager::onDataReceived::currentOperation is null "))
        }
    }

    @SuppressLint("MissingPermission")
    private fun onPublicKeyReceived(device: BluetoothDevice, publicKey: String) {
        currentScope.launch(Dispatchers.IO) {
            currentOperation?.run {
                if (this is VerifyAddressOperation) {
                    postResult(
                        LedgerBleResult.VerifyPublicKeyResult(
                            isVerified = publicKey == this.address,
                            ledgerPublicKey = publicKey,
                            originalPublicKey = this.address
                        )
                    )
                    return@launch
                }
                if (this is BaseTransactionOperation &&
                    (publicKey == accountAddress || publicKey == accountAuthAddress)
                ) {
                    isAddressVerified = true
                    sendTransactionRequest()
                    return@launch
                } else {
                    accountInformationUseCase.getAccountInformationAndFetchAssets(publicKey, this@launch, true).use(
                        onSuccess = { fetchedAccountInformation ->
                            if (fetchedAccountInformation.isCreated() || nextIndex == 1) {
                                if (this is AccountFetchAllOperation) {
                                    accounts.add(fetchedAccountInformation)
                                }
                                sendPublicKeyRequest()
                            } else {
                                // all the accounts are fetched.
                                postResult(
                                    when (this) {
                                        is AccountFetchAllOperation -> {
                                            LedgerBleResult.AccountResult(accounts, device)
                                        }
                                        is TransactionOperation,
                                        is WalletConnectTransactionOperation,
                                        is ExternalTransactionOperation -> {
                                            LedgerBleResult.AppErrorResult(R.string.it_appears_this, R.string.error)
                                        }
                                        is VerifyAddressOperation -> {
                                            throw Exception("Verify operation should not posted here.")
                                        }
                                    }
                                )
                            }
                        },
                        onFailed = { _, _ ->
                            postResult(
                                LedgerBleResult.AppErrorResult(
                                    R.string.a_network_error,
                                    R.string.error_connection_title
                                )
                            )
                        }
                    )
                }
            }
        }
    }

    private fun onTransactionSignatureReceived(transactionSignature: ByteArray) {
        currentScope.launch {
            try {
                (currentOperation as? BaseTransactionOperation)?.run {
                    val signedTransactionData = if (isRekeyedToAnotherAccount) {
                        Mobile.attachSignatureWithSigner(transactionSignature, transactionByteArray, accountAuthAddress)
                    } else {
                        Mobile.attachSignature(transactionSignature, transactionByteArray)
                    }
                    postResult(LedgerBleResult.SignedTransactionResult(signedTransactionData))
                }
            } catch (exception: Exception) {
                recordException(exception)
                postResult(LedgerBleResult.LedgerErrorResult(exception.message.toString()))
            }
        }
    }

    override fun onMissingBytes(device: BluetoothDevice) {
        postResult(LedgerBleResult.OnMissingBytes(device))
    }

    override fun onDeviceFailedToConnect(device: BluetoothDevice, reason: Int) {
        when (reason) {
            ConnectionObserver.REASON_NOT_SUPPORTED -> {
                postResult(
                    LedgerBleResult.AppErrorResult(
                        R.string.error_unsupported_message,
                        R.string.error_unsupported_title
                    )
                )
            }
            else -> {
                sendErrorLog("Unhandled else case in LedgerBleOperationManager.onDeviceFailedToConnect")
            }
        }
    }

    override fun onOperationCancelled() {
        postResult(LedgerBleResult.OperationCancelledResult)
    }

    override fun onManagerError(errorResId: Int, titleResId: Int) {
        postResult(LedgerBleResult.AppErrorResult(errorResId, titleResId))
    }

    override fun onDeviceDisconnected(device: BluetoothDevice, reason: Int) {
        postResult(LedgerBleResult.OnLedgerDisconnected)
    }

    override fun onError(device: BluetoothDevice, message: String, errorCode: Int) {
        postResult(
            if (errorCode == ERROR_ON_WRITE_CHARACTERISTIC) {
                LedgerBleResult.AppErrorResult(R.string.error_receiving_message, R.string.error_transmission_title)
            } else {
                LedgerBleResult.LedgerErrorResult(message)
            }
        )
    }

    private fun postResult(ledgerBleResult: LedgerBleResult) {
        ledgerBleResultFlow.value = Event(ledgerBleResult)
    }

    private suspend fun connectToLedger(bluetoothDevice: BluetoothDevice): Boolean {
        if (ledgerBleConnectionManager.bluetoothDevice?.address == bluetoothDevice.address) {
            // ledger is already connect to connectionManager.
            return true
        }
        ledgerBleConnectionManager.connectToDevice(bluetoothDevice)
        while (ledgerBleConnectionManager.isReady.not()) {
            delay(LEDGER_CONNECTION_DELAY)
            if (ledgerBleConnectionManager.isTryingToConnect().not()) {
                postResult(
                    LedgerBleResult.AppErrorResult(R.string.error_connection_message, R.string.error_connection_title)
                )
                return false
            }
        }
        return true
    }

    fun manualStopAllProcess() {
        currentScope.coroutineContext.cancelChildren()
        stopAllResources()
    }

    override fun stopAllResources() {
        ledgerBleResultFlow.value = null
        currentOperation = null
        ledgerBleConnectionManager.disconnect().enqueue()
    }

    companion object {
        private const val ERROR_ON_WRITE_CHARACTERISTIC = 133
        private const val LEDGER_CONNECTION_DELAY = 250L
    }
}
