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
import com.algorand.android.models.WalletConnectRequest.WalletConnectTransaction
import com.algorand.android.models.WalletConnectSignResult
import com.algorand.android.models.WalletConnectSignResult.Error.Api
import com.algorand.android.models.WalletConnectSignResult.Error.Defined
import com.algorand.android.models.WalletConnectSignResult.LedgerWaitingForApproval
import com.algorand.android.models.WalletConnectSignResult.Success
import com.algorand.android.models.WalletConnectSignResult.TransactionCancelledByLedger
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.LifecycleScopedCoroutineOwner
import com.algorand.android.utils.ListQueuingHelper
import com.algorand.android.utils.sendErrorLog
import com.algorand.android.utils.signTx
import javax.inject.Inject
import kotlinx.coroutines.cancelChildren
import kotlinx.coroutines.launch

class WalletConnectTransactionSignManager @Inject constructor(
    private val walletConnectSignValidator: WalletConnectSignValidator,
    private val ledgerBleSearchManager: LedgerBleSearchManager,
    private val ledgerBleOperationManager: LedgerBleOperationManager,
    private val signHelper: WalletConnectTransactionSignHelper,
    private val accountDetailUseCase: AccountDetailUseCase
) : LifecycleScopedCoroutineOwner() {

    val signResultLiveData: LiveData<WalletConnectSignResult>
        get() = _signResultLiveData
    private val _signResultLiveData = MutableLiveData<WalletConnectSignResult>()

    private var transaction: WalletConnectTransaction? = null

    private val signHelperListener = object : ListQueuingHelper.Listener<BaseWalletConnectTransaction, ByteArray> {
        override fun onAllItemsDequeued(signedTransactions: List<ByteArray?>) {
            transaction?.run {
                _signResultLiveData.postValue(Success(session.sessionIdentifier, requestId, signedTransactions))
            }
        }

        override fun onNextItemToBeDequeued(
            transaction: BaseWalletConnectTransaction,
            currentItemIndex: Int,
            totalItemCount: Int
        ) {
            val accountType = getSignerAccountType(transaction.authAddress)
            if (accountType == null) {
                signHelper.cacheDequeuedItem(null)
            } else {
                transaction.signTransaction(
                    accountDetail = accountType,
                    currentTransactionIndex = currentItemIndex,
                    totalTransactionCount = totalItemCount
                )
            }
        }
    }

    private val scanCallback = object : CustomScanCallback() {

        override fun onLedgerScanned(
            device: BluetoothDevice,
            currentTransactionIndex: Int?,
            totalTransactionCount: Int?
        ) {
            ledgerBleSearchManager.stop()
            currentScope.launch {
                signHelper.currentItem?.run {
                    val walletConnectTransactionOperation = WalletConnectTransactionOperation(device, this)
                    ledgerBleOperationManager.startLedgerOperation(
                        walletConnectTransactionOperation,
                        currentTransactionIndex,
                        totalTransactionCount
                    )
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
                is LedgerBleResult.LedgerWaitingForApproval -> {
                    LedgerWaitingForApproval(
                        ledgerName = bluetoothName,
                        currentTransactionIndex = currentTransactionIndex,
                        totalTransactionCount = totalTransactionCount,
                        isTransactionIndicatorVisible = totalTransactionCount != null &&
                            currentTransactionIndex != null &&
                            totalTransactionCount > 1
                    ).apply(::postResult)
                }
                is SignedTransactionResult -> signHelper.cacheDequeuedItem(transactionByteArray)
                is LedgerErrorResult -> postResult(Api(errorMessage))
                is AppErrorResult -> postResult(Defined(AnnotatedString(errorMessageId), titleResId))
                is OperationCancelledResult -> postResult(TransactionCancelledByLedger())
                else -> {
                    sendErrorLog("Unhandled else case in WalletConnectSignManager.operationManagerCollectorAction")
                }
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
                is WalletConnectSignResult.CanBeSigned -> {
                    signHelper.initItemsToBeEnqueued(transactionList.flatten())
                }
                is WalletConnectSignResult.Error -> postResult(result)
                else -> {
                    sendErrorLog("Unhandled else case in WalletConnectSignManager.signTransaction")
                }
            }
        }
    }

    private fun BaseWalletConnectTransaction.signTransaction(
        accountDetail: Account.Detail,
        currentTransactionIndex: Int?,
        totalTransactionCount: Int?,
        checkIfRekeyed: Boolean = true
    ) {
        if (checkIfRekeyed && isRekeyedToAnotherAccount()) {
            when (accountDetail) {
                is RekeyedAuth -> {
                    accountDetail.rekeyedAuthDetail[authAddress].let { rekeyedAuthDetail ->
                        if (rekeyedAuthDetail != null) {
                            signTransaction(
                                accountDetail = rekeyedAuthDetail,
                                checkIfRekeyed = false,
                                currentTransactionIndex = currentTransactionIndex,
                                totalTransactionCount = totalTransactionCount
                            )
                        } else {
                            processWithCheckingOtherAccounts(
                                currentTransactionIndex = currentTransactionIndex,
                                totalTransactionCount = totalTransactionCount
                            )
                        }
                    }
                }
                else -> {
                    processWithCheckingOtherAccounts(
                        currentTransactionIndex = currentTransactionIndex,
                        totalTransactionCount = totalTransactionCount
                    )
                }
            }
        } else {
            when (accountDetail) {
                is Ledger -> {
                    sendTransactionWithLedger(
                        ledgerDetail = accountDetail,
                        currentTransactionIndex = currentTransactionIndex,
                        totalTransactionCount = totalTransactionCount
                    )
                }
                is RekeyedAuth -> {
                    if (accountDetail.authDetail != null) {
                        signTransaction(
                            accountDetail = accountDetail.authDetail,
                            checkIfRekeyed = false,
                            currentTransactionIndex = currentTransactionIndex,
                            totalTransactionCount = totalTransactionCount
                        )
                    } else {
                        signHelper.cacheDequeuedItem(null)
                    }
                }
                is Standard -> signHelper.cacheDequeuedItem(decodedTransaction?.signTx(accountDetail.secretKey))
                else -> signHelper.cacheDequeuedItem(null)
            }
        }
    }

    private fun sendTransactionWithLedger(
        ledgerDetail: Ledger,
        currentTransactionIndex: Int?,
        totalTransactionCount: Int?
    ) {
        val bluetoothAddress = ledgerDetail.bluetoothAddress
        val currentConnectedDevice = ledgerBleOperationManager.connectedBluetoothDevice
        if (currentConnectedDevice != null && currentConnectedDevice.address == bluetoothAddress) {
            sendCurrentTransaction(
                bluetoothDevice = currentConnectedDevice,
                currentTransactionIndex = currentTransactionIndex,
                totalTransactionCount = totalTransactionCount
            )
        } else {
            searchForDevice(
                ledgerAddress = bluetoothAddress,
                currentTransactionIndex = currentTransactionIndex,
                totalTransactionCount = totalTransactionCount
            )
        }
    }

    private fun sendCurrentTransaction(
        bluetoothDevice: BluetoothDevice,
        currentTransactionIndex: Int?,
        totalTransactionCount: Int?
    ) {
        signHelper.currentItem?.run {
            val walletConnectTransactionOperation = WalletConnectTransactionOperation(bluetoothDevice, this)
            ledgerBleOperationManager.startLedgerOperation(
                newOperation = walletConnectTransactionOperation,
                currentTransactionIndex = currentTransactionIndex,
                totalTransactionCount = totalTransactionCount
            )
        }
    }

    private fun searchForDevice(
        ledgerAddress: String,
        currentTransactionIndex: Int?,
        totalTransactionCount: Int?
    ) {
        ledgerBleSearchManager.scan(
            newScanCallback = scanCallback,
            currentTransactionIndex = currentTransactionIndex,
            totalTransactionCount = totalTransactionCount,
            filteredAddress = ledgerAddress,
            coroutineScope = currentScope
        )
    }

    private fun BaseWalletConnectTransaction.processWithCheckingOtherAccounts(
        currentTransactionIndex: Int?,
        totalTransactionCount: Int?
    ) {
        when (
            val authAccountDetail = accountDetailUseCase.getCachedAccountDetail(authAddress.orEmpty())
                ?.data
                ?.account
                ?.detail
        ) {
            is Standard -> {
                if (authAccountDetail.secretKey.isNotEmpty()) {
                    signHelper.cacheDequeuedItem(decodedTransaction?.signTx(authAccountDetail.secretKey))
                } else {
                    signHelper.cacheDequeuedItem(null)
                }
            }
            is Ledger -> {
                sendTransactionWithLedger(
                    ledgerDetail = authAccountDetail,
                    currentTransactionIndex = currentTransactionIndex,
                    totalTransactionCount = totalTransactionCount
                )
            }
            is Account.Detail.Rekeyed -> {
                if (authAccountDetail.secretKey?.isNotEmpty() == true) {
                    signHelper.cacheDequeuedItem(decodedTransaction?.signTx(authAccountDetail.secretKey))
                } else {
                    signHelper.cacheDequeuedItem(null)
                }
            }
            is RekeyedAuth -> {
                if (authAccountDetail.secretKey?.isNotEmpty() == true) {
                    signHelper.cacheDequeuedItem(decodedTransaction?.signTx(authAccountDetail.secretKey))
                } else {
                    signHelper.cacheDequeuedItem(null)
                }
            }
            else -> signHelper.cacheDequeuedItem(null)
        }
    }

    private fun getSignerAccountType(signerAccountAddress: String?): Account.Detail? {
        if (signerAccountAddress.isNullOrBlank()) return null
        return accountDetailUseCase.getCachedAccountDetail(signerAccountAddress)?.data?.account?.detail
    }

    private fun postResult(walletConnectSignResult: WalletConnectSignResult) {
        _signResultLiveData.postValue(walletConnectSignResult)
    }

    private fun setupLedgerOperationManager(lifecycle: Lifecycle) {
        ledgerBleOperationManager.setup(lifecycle)
        lifecycle.coroutineScope.launch {
            ledgerBleOperationManager.ledgerBleResultFlow.collect { operationManagerCollectorAction.invoke(it) }
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
