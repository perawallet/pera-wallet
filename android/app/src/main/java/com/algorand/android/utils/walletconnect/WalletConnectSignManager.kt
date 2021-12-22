/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.utils.walletconnect

import android.bluetooth.BluetoothDevice
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.coroutineScope
import com.algorand.android.ledger.CustomScanCallback
import com.algorand.android.ledger.LedgerBleOperationManager
import com.algorand.android.ledger.LedgerBleSearchManager
import com.algorand.android.ledger.operations.WalletConnectTransactionOperation
import com.algorand.android.models.Account
import com.algorand.android.models.Account.Detail.Ledger
import com.algorand.android.models.Account.Detail.RekeyedAuth
import com.algorand.android.models.Account.Detail.Standard
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.LedgerBleResult
import com.algorand.android.models.LedgerBleResult.AppErrorResult
import com.algorand.android.models.LedgerBleResult.LedgerErrorResult
import com.algorand.android.models.LedgerBleResult.OperationCancelledResult
import com.algorand.android.models.LedgerBleResult.SignedTransactionResult
import com.algorand.android.models.WalletConnectSignResult
import com.algorand.android.models.WalletConnectSignResult.Error.Api
import com.algorand.android.models.WalletConnectSignResult.Error.Defined
import com.algorand.android.models.WalletConnectSignResult.LedgerWaitingForApproval
import com.algorand.android.models.WalletConnectSignResult.Success
import com.algorand.android.models.WalletConnectSignResult.TransactionCancelled
import com.algorand.android.models.WalletConnectSigner
import com.algorand.android.models.WalletConnectTransaction
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Event
import com.algorand.android.utils.LifecycleScopedCoroutineOwner
import com.algorand.android.utils.signTx
import javax.inject.Inject
import kotlinx.coroutines.cancelChildren
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class WalletConnectSignManager @Inject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val walletConnectSignValidator: WalletConnectSignValidator,
    private val ledgerBleSearchManager: LedgerBleSearchManager,
    private val ledgerBleOperationManager: LedgerBleOperationManager,
    private val signHelper: WalletConnectSigningHelper
) : LifecycleScopedCoroutineOwner() {

    val signResultLiveData: LiveData<WalletConnectSignResult>
        get() = _signResultLiveData
    private val _signResultLiveData = MutableLiveData<WalletConnectSignResult>()

    private var transaction: WalletConnectTransaction? = null

    private val signHelperListener = object : WalletConnectSigningHelper.Listener {
        override fun onTransactionSignCompleted(signedTransactions: List<ByteArray?>) {
            transaction?.run {
                _signResultLiveData.postValue(Success(session.id, requestId, signedTransactions))
            }
        }

        override fun onNextTransactionToSign(transaction: BaseWalletConnectTransaction) {
            val accountType = transaction.signer.getSignerAccountType()
            if (accountType == null) {
                signHelper.cacheSignedTransaction(null)
            } else {
                transaction.signTransaction(accountType)
            }
        }
    }

    private val scanCallback = object : CustomScanCallback() {
        override fun onLedgerScanned(device: BluetoothDevice) {
            ledgerBleSearchManager.stop()
            currentScope.launch {
                signHelper.currentTransaction?.run {
                    ledgerBleOperationManager.startLedgerOperation(WalletConnectTransactionOperation(device, this))
                }
            }
        }

        override fun onScanError(errorMessageResId: Int, titleResId: Int) {
            postResult(WalletConnectSignResult.LedgerScanFailed)
        }
    }

    private val operationManagerCollectorAction: (suspend (Event<LedgerBleResult>?) -> Unit) = { ledgerBleResultEvent ->
        ledgerBleResultEvent?.consume()?.run {
            if (transaction == null) return@run
            when (this) {
                is LedgerBleResult.LedgerWaitingForApproval -> postResult(LedgerWaitingForApproval)
                is SignedTransactionResult -> signHelper.cacheSignedTransaction(transactionByteArray)
                is LedgerErrorResult -> postResult(Api(errorMessage))
                is AppErrorResult -> postResult(Defined(AnnotatedString(errorMessageId), titleResId))
                is OperationCancelledResult -> postResult(TransactionCancelled())
            }
        }
    }

    fun setup(lifecycle: Lifecycle) {
        assignToLifecycle(lifecycle)
        setupLedgerOperationManager(lifecycle)
        signHelper.initListener(signHelperListener)
    }

    fun signTransaction(transaction: WalletConnectTransaction) {
        postResult(WalletConnectSignResult.Loading)
        this.transaction = transaction
        with(transaction) {
            when (val result = walletConnectSignValidator.canTransactionBeSigned(this)) {
                is WalletConnectSignResult.CanBeSigned -> signHelper.initTransactionsToBeSigned(transactionList)
                is WalletConnectSignResult.Error -> postResult(result)
            }
        }
    }

    private fun BaseWalletConnectTransaction.signTransaction(
        accountDetail: Account.Detail,
        checkIfRekeyed: Boolean = true
    ) {
        if (checkIfRekeyed && isRekeyedToAnotherAccount()) {
            when (accountDetail) {
                is RekeyedAuth -> {
                    accountDetail.rekeyedAuthDetail[authAddress].let { rekeyedAuthDetail ->
                        if (rekeyedAuthDetail != null) {
                            signTransaction(rekeyedAuthDetail, false)
                        } else {
                            processWithCheckingOtherAccounts()
                        }
                    }
                }
                else -> processWithCheckingOtherAccounts()
            }
        } else {
            when (accountDetail) {
                is Ledger -> sendTransactionWithLedger(accountDetail)
                is RekeyedAuth -> {
                    if (accountDetail.authDetail != null) {
                        signTransaction(accountDetail.authDetail, checkIfRekeyed = false)
                    } else {
                        signHelper.cacheSignedTransaction(null)
                    }
                }
                is Standard -> signHelper.cacheSignedTransaction(decodedTransaction?.signTx(accountDetail.secretKey))
                else -> signHelper.cacheSignedTransaction(null)
            }
        }
    }

    private fun sendTransactionWithLedger(ledgerDetail: Ledger) {
        val bluetoothAddress = ledgerDetail.bluetoothAddress
        val currentConnectedDevice = ledgerBleOperationManager.connectedBluetoothDevice
        if (currentConnectedDevice != null && currentConnectedDevice.address == bluetoothAddress) {
            sendCurrentTransaction(currentConnectedDevice)
        } else {
            searchForDevice(bluetoothAddress)
        }
    }

    private fun sendCurrentTransaction(bluetoothDevice: BluetoothDevice) {
        signHelper.currentTransaction?.run {
            ledgerBleOperationManager.startLedgerOperation(WalletConnectTransactionOperation(bluetoothDevice, this))
        }
    }

    private fun searchForDevice(ledgerAddress: String) {
        ledgerBleSearchManager.scan(scanCallback, ledgerAddress)
    }

    private fun BaseWalletConnectTransaction.processWithCheckingOtherAccounts() {
        when (
            val authAccountDetail = accountCacheManager.getCacheData(authAddress)?.account?.detail
        ) {
            is Standard -> signHelper.cacheSignedTransaction(decodedTransaction?.signTx(authAccountDetail.secretKey))
            is Ledger -> sendTransactionWithLedger(authAccountDetail)
            else -> signHelper.cacheSignedTransaction(null)
        }
    }

    private fun WalletConnectSigner.getSignerAccountType(): Account.Detail? {
        return accountCacheManager.getCacheData(address?.decodedAddress)?.account?.detail
    }

    private fun postResult(walletConnectSignResult: WalletConnectSignResult) {
        _signResultLiveData.postValue(walletConnectSignResult)
    }

    private fun setupLedgerOperationManager(lifecycle: Lifecycle) {
        ledgerBleOperationManager.setup(lifecycle)
        lifecycle.coroutineScope.launch {
            ledgerBleOperationManager.ledgerBleResultFlow.collect(action = operationManagerCollectorAction)
        }
    }

    override fun stopAllResources() {
        ledgerBleSearchManager.stop()
        signHelper.clearCachedData()
        transaction = null
    }

    fun manualStopAllResources() {
        this.stopAllResources()
        currentScope.coroutineContext.cancelChildren()
        ledgerBleOperationManager.manualStopAllProcess()
    }
}
