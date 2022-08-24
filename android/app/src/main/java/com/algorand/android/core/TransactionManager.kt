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

package com.algorand.android.core

import android.bluetooth.BluetoothDevice
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.coroutineScope
import com.algorand.algosdk.mobile.BytesArray
import com.algorand.android.R
import com.algorand.android.ledger.CustomScanCallback
import com.algorand.android.ledger.LedgerBleOperationManager
import com.algorand.android.ledger.LedgerBleSearchManager
import com.algorand.android.ledger.operations.TransactionOperation
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.LedgerBleResult
import com.algorand.android.models.Result
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.models.TransactionManagerResult
import com.algorand.android.models.TransactionManagerResult.Error.Defined
import com.algorand.android.models.TransactionParams
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Event
import com.algorand.android.utils.LifecycleScopedCoroutineOwner
import com.algorand.android.utils.ListQueuingHelper
import com.algorand.android.utils.TransactionSigningHelper
import com.algorand.android.utils.assignGroupId
import com.algorand.android.utils.flatten
import com.algorand.android.utils.formatAsAlgoString
import com.algorand.android.utils.getTxFee
import com.algorand.android.utils.isLesserThan
import com.algorand.android.utils.makeAddAssetTx
import com.algorand.android.utils.makeRekeyTx
import com.algorand.android.utils.makeRemoveAssetTx
import com.algorand.android.utils.makeSendAndRemoveAssetTx
import com.algorand.android.utils.makeTx
import com.algorand.android.utils.minBalancePerAssetAsBigInteger
import com.algorand.android.utils.recordException
import com.algorand.android.utils.signTx
import com.algorand.android.utils.toBytesArray
import java.math.BigInteger
import java.net.ConnectException
import java.net.SocketException
import javax.inject.Inject
import kotlinx.coroutines.cancelChildren
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

// TODO: 26.06.2022 Refactor and use AccountDetail instead of AccountCacheData in transaction flow
// TODO: 26.06.2022 Replace AccountCacheManager with AccountDetailUsecase
class TransactionManager @Inject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val ledgerBleSearchManager: LedgerBleSearchManager,
    private val transactionsRepository: TransactionsRepository,
    private val ledgerBleOperationManager: LedgerBleOperationManager,
    private val signHelper: TransactionSigningHelper,
    private val accountDetailUseCase: AccountDetailUseCase
) : LifecycleScopedCoroutineOwner() {

    val transactionManagerResultLiveData = MutableLiveData<Event<TransactionManagerResult>?>()

    private var transactionParams: TransactionParams? = null
    var transactionDataList: List<TransactionData>? = null

    private val scanCallback = object : CustomScanCallback() {
        override fun onLedgerScanned(device: BluetoothDevice) {
            ledgerBleSearchManager.stop()
            currentScope.launch {
                signHelper.currentItem?.run {
                    ledgerBleOperationManager.startLedgerOperation(TransactionOperation(device, this))
                }
            }
        }

        override fun onScanError(errorMessageResId: Int, titleResId: Int) {
            setSignFailed(TransactionManagerResult.LedgerScanFailed)
        }
    }

    private val operationManagerCollectorAction: (suspend (Event<LedgerBleResult>?) -> Unit) = { ledgerBleResultEvent ->
        ledgerBleResultEvent?.consume()?.run {
            when (this) {
                is LedgerBleResult.LedgerWaitingForApproval -> postResult(
                    TransactionManagerResult.LedgerWaitingForApproval(
                        bluetoothName
                    )
                )
                is LedgerBleResult.SignedTransactionResult ->
                    checkAndCacheSignedTransaction(transactionByteArray)
                is LedgerBleResult.LedgerErrorResult ->
                    setSignFailed(TransactionManagerResult.Error.Api(errorMessage))
                is LedgerBleResult.AppErrorResult -> setSignFailed(Defined(AnnotatedString(errorMessageId), titleResId))
                is LedgerBleResult.OperationCancelledResult -> setSignFailed(
                    Defined(AnnotatedString(R.string.error_cancelled_message), R.string.error_cancelled_title)
                )
                is LedgerBleResult.OnMissingBytes -> setSignFailed(
                    Defined(AnnotatedString(R.string.error_sending_message), R.string.error_bluetooth_title)
                )
            }
        }
    }

    private val signHelperListener = object : ListQueuingHelper.Listener<TransactionData, ByteArray> {
        override fun onAllItemsDequeued(signedTransactions: List<ByteArray?>) {
            if (signedTransactions.isEmpty() || signedTransactions.any { it == null }) {
                setSignFailed(Defined(AnnotatedString(stringResId = R.string.an_error_occured)))
                return
            }
            if (signedTransactions.size == 1) {
                transactionDataList?.let { postTxnSignResult(signedTransactions.firstOrNull(), it.firstOrNull()) }
            } else {
                transactionDataList?.let { postGroupTxnSignResult(signedTransactions, it) }
            }
        }

        override fun onNextItemToBeDequeued(transaction: TransactionData) {
            val accountDetail = transaction.accountCacheData.account.detail
            if (accountDetail == null) {
                setSignFailed(Defined(AnnotatedString(stringResId = R.string.an_error_occured)))
            } else {
                transaction.signTxn(accountDetail)
            }
        }
    }

    private fun checkAndCacheSignedTransaction(transactionByteArray: ByteArray?) {
        if (transactionByteArray == null) {
            setSignFailed(Defined(AnnotatedString(R.string.unknown_error)))
            return
        }
        signHelper.currentItem?.run {
            calculatedFee = transactionParams?.getTxFee(transactionByteArray)
            if (this is TransactionData.Send && projectedFee != calculatedFee) {
                currentScope.launch { resignCurrentTransaction() }
                return
            }

            if (isMinimumLimitViolated()) {
                setSignFailed(Defined(AnnotatedString(stringResId = R.string.minimum_balance_required)))
                return
            }
        }
        signHelper.cacheDequeuedItem(transactionByteArray)
    }

    private fun setSignFailed(transactionManagerResult: TransactionManagerResult) {
        postResult(transactionManagerResult)
        signHelper.clearCachedData()
    }

    private suspend fun resignCurrentTransaction() {
        signHelper.currentItem?.createTransaction()
        signHelper.requeueCurrentItem()
    }

    fun setup(lifecycle: Lifecycle) {
        assignToLifecycle(lifecycle)
        setupLedgerOperationManager(lifecycle)
        signHelper.initListener(signHelperListener)
    }

    private fun setupLedgerOperationManager(lifecycle: Lifecycle) {
        ledgerBleOperationManager.setup(lifecycle)
        lifecycle.coroutineScope.launch {
            ledgerBleOperationManager.ledgerBleResultFlow.collect(action = operationManagerCollectorAction)
        }
    }

    fun initSigningTransactions(isGroupTransaction: Boolean, vararg transactionData: TransactionData) {
        currentScope.launch {
            postResult(TransactionManagerResult.Loading)
            processTransactionDataList(transactionData.toList(), isGroupTransaction)?.let {
                this@TransactionManager.transactionDataList = it
                signHelper.initItemsToBeEnqueued(it)
            } ?: setSignFailed(Defined(AnnotatedString(stringResId = R.string.an_error_occured)))
        }
    }

    private fun TransactionData.signTxn(accountDetail: Account.Detail, checkIfRekeyed: Boolean = true) {
        if (checkIfRekeyed && accountCacheData.isRekeyedToAnotherAccount()) {
            when (accountDetail) {
                is Account.Detail.RekeyedAuth -> {
                    accountDetail.rekeyedAuthDetail[accountCacheData.authAddress].let { rekeyedAuthDetail ->
                        if (rekeyedAuthDetail != null) {
                            signTxn(rekeyedAuthDetail, checkIfRekeyed = false)
                        } else {
                            signTxnWithCheckingOtherAccounts()
                        }
                    }
                }
                else -> {
                    signTxnWithCheckingOtherAccounts()
                }
            }
        } else {
            when (accountDetail) {
                is Account.Detail.Ledger -> {
                    sendTransactionWithLedger(accountDetail)
                }
                is Account.Detail.RekeyedAuth -> {
                    if (accountDetail.authDetail != null) {
                        signTxn(accountDetail.authDetail, checkIfRekeyed = false)
                    } else {
                        setSignFailed(Defined(AnnotatedString(stringResId = R.string.this_account_has)))
                    }
                }
                is Account.Detail.Standard -> {
                    checkAndCacheSignedTransaction(transactionByteArray?.signTx(accountDetail.secretKey))
                }
                else -> {
                    val exceptionMessage = "${accountCacheData.account.type} cannot sign by itself."
                    recordException(Exception(exceptionMessage))
                    setSignFailed(Defined(AnnotatedString(stringResId = R.string.an_error_occured)))
                }
            }
        }
    }

    private fun TransactionData.signTxnWithCheckingOtherAccounts() {
        when (val authAccountDetail = accountCacheManager.getCacheData(accountCacheData.authAddress)?.account?.detail) {
            is Account.Detail.Standard -> {
                checkAndCacheSignedTransaction(transactionByteArray?.signTx(authAccountDetail.secretKey))
            }
            is Account.Detail.Ledger -> {
                sendTransactionWithLedger(authAccountDetail)
            }
            else -> {
                postResult(Defined(AnnotatedString(stringResId = R.string.this_account_has)))
            }
        }
    }

    suspend fun TransactionData.createTransaction(): ByteArray? {
        val transactionParams = getTransactionParams() ?: return null

        val createdTransactionByteArray = when (this) {
            is TransactionData.Send -> {
                projectedFee = calculatedFee ?: transactionParams.getTxFee()
                // calculate isMax before calculating real amount because while isMax true fee will be deducted.
                isMax = isTransactionMax(amount, accountCacheData.account.address, assetInformation.assetId)
                amount = calculateAmount(amount, isMax, accountCacheData, assetInformation.assetId, projectedFee)
                    ?: return null

                if (accountCacheData.isRekeyedToAnotherAccount()) {
                    // if account is rekeyed to another account, min balance should be deducted from the amount.
                    // after it'll be deducted, isMax will be false to not write closeToAddress.
                    isMax = false
                }

                if (isCloseToSameAccount()) {
                    return null
                }

                transactionParams.makeTx(
                    senderAddress = accountCacheData.account.address,
                    receiverAddress = targetUser.publicKey,
                    amount = amount,
                    assetId = assetInformation.assetId,
                    isMax = isMax,
                    note = note
                )
            }
            is TransactionData.AddAsset -> {
                transactionParams.makeAddAssetTx(accountCacheData.account.address, assetInformation.assetId)
            }
            is TransactionData.RemoveAsset -> {
                if (shouldCreateAssetRemoveTransaction(accountCacheData.account.address, assetInformation.assetId)) {
                    transactionParams.makeRemoveAssetTx(
                        senderAddress = accountCacheData.account.address,
                        creatorPublicKey = creatorPublicKey,
                        assetId = assetInformation.assetId
                    )
                } else {
                    null
                }
            }
            is TransactionData.SendAndRemoveAsset -> {
                transactionParams.makeSendAndRemoveAssetTx(
                    senderAddress = accountCacheData.account.address,
                    receiverAddress = targetUser.publicKey,
                    assetId = assetInformation.assetId,
                    amount = amount
                )
            }
            is TransactionData.Rekey -> {
                transactionParams.makeRekeyTx(accountCacheData.account.address, rekeyAdminAddress)
            }
        }

        transactionByteArray = createdTransactionByteArray

        return createdTransactionByteArray
    }

    private suspend fun getTransactionParams(): TransactionParams? {
        when (val result = transactionsRepository.getTransactionParams()) {
            is Result.Success -> {
                transactionParams = result.data
            }
            is Result.Error -> {
                transactionParams = null
                when (result.exception.cause) {
                    is ConnectException, is SocketException -> {
                        postResult(
                            Defined(AnnotatedString(R.string.the_internet_connection))
                        )
                    }
                    else -> {
                        postResult(TransactionManagerResult.Error.Api(result.exception.message.orEmpty()))
                    }
                }
            }
        }
        return transactionParams
    }

    private fun sendCurrentTransaction(bluetoothDevice: BluetoothDevice) {
        signHelper.currentItem?.run {
            ledgerBleOperationManager.startLedgerOperation(TransactionOperation(bluetoothDevice, this))
        }
    }

    private fun calculateAmount(
        projectedAmount: BigInteger,
        isMax: Boolean,
        accountCacheData: AccountCacheData,
        assetId: Long,
        fee: Long
    ): BigInteger? {
        val calculatedAmount = if (isMax && assetId == AssetInformation.ALGO_ID) {
            if (accountCacheData.isRekeyedToAnotherAccount()) {
                projectedAmount - fee.toBigInteger() - accountCacheData.getMinBalance().toBigInteger()
            } else {
                projectedAmount - fee.toBigInteger()
            }
        } else {
            projectedAmount
        }

        if (calculatedAmount isLesserThan BigInteger.ZERO) {
            if (accountCacheData.isRekeyedToAnotherAccount()) {
                val errorMinBalance = AnnotatedString(
                    stringResId = R.string.the_transaction_cannot_be,
                    replacementList = listOf("min_balance" to accountCacheData.getMinBalance().formatAsAlgoString())
                )
                postResult(Defined(errorMinBalance))
            } else {
                postResult(Defined(AnnotatedString(R.string.transaction_amount_results)))
            }
            return null
        }

        return calculatedAmount
    }

    private fun isTransactionMax(amount: BigInteger, publicKey: String, assetId: Long): Boolean {
        if (assetId != AssetInformation.ALGO_ID) {
            return false
        } else {
            accountCacheManager.getAssetInformation(publicKey, assetId)?.let { assetBalanceInformation ->
                return amount == assetBalanceInformation.amount
            }
            return false
        }
    }

    private fun shouldCreateAssetRemoveTransaction(publicKey: String, assetId: Long): Boolean {
        with(accountDetailUseCase) {
            return isAssetOwnedByAccount(publicKey, assetId) && isAssetBalanceZero(publicKey, assetId) == true
        }
    }

    private fun TransactionData.isCloseToSameAccount(): Boolean {
        if (this is TransactionData.Send && isMax && accountCacheData.account.address == targetUser.publicKey) {
            postResult(Defined(AnnotatedString(R.string.you_can_not_send_your)))
            return true
        }
        return false
    }

    private fun TransactionData.isMinimumLimitViolated(): Boolean {
        if (this is TransactionData.Send && isMax) {
            return false
        }

        // every asset addition increases min balance by $MIN_BALANCE_PER_ASSET
        var minBalance = accountCacheManager.getMinBalanceOfAccount(accountCacheData.account.address)
        when (this) {
            is TransactionData.AddAsset ->
                minBalance += minBalancePerAssetAsBigInteger
            is TransactionData.RemoveAsset -> {
                minBalance -= minBalancePerAssetAsBigInteger
            }
        }

        val balance = accountCacheManager.getAssetInformation(
            accountCacheData.account.address,
            AssetInformation.ALGO_ID
        )?.amount ?: return true

        val fee = calculatedFee?.toBigInteger() ?: return true

        // fee only drops from the algos.
        val balanceAfterTransaction =
            if (this is TransactionData.Send && assetInformation.isAlgo().not()) {
                balance - fee
            } else {
                balance - fee - amount
            }

        if (balanceAfterTransaction < minBalance) {
            if (this is TransactionData.AddAsset) {
                postResult(TransactionManagerResult.Error.MinBalanceError(minBalance + fee))
            } else {
                val description = AnnotatedString(
                    stringResId = R.string.transaction_amount,
                    replacementList = listOf("min_balance" to minBalance.formatAsAlgoString())
                )
                postResult(Defined(description))
            }
            return true
        }

        return false
    }

    private fun postResult(transactionManagerResult: TransactionManagerResult) {
        transactionManagerResultLiveData.postValue(Event(transactionManagerResult))
    }

    private fun sendTransactionWithLedger(ledgerDetail: Account.Detail.Ledger) {
        val bluetoothAddress = ledgerDetail.bluetoothAddress
        val currentConnectedDevice = ledgerBleOperationManager.connectedBluetoothDevice
        if (currentConnectedDevice != null && currentConnectedDevice.address == bluetoothAddress) {
            sendCurrentTransaction(currentConnectedDevice)
        } else {
            searchForDevice(bluetoothAddress)
        }
    }

    private fun searchForDevice(ledgerAddress: String) {
        ledgerBleSearchManager.scan(scanCallback, ledgerAddress)
    }

    // this also stops LedgerBleOperationManager.
    fun manualStopAllResources() {
        this.stopAllResources()
        currentScope.coroutineContext.cancelChildren()
        ledgerBleOperationManager.manualStopAllProcess()
    }

    override fun stopAllResources() {
        ledgerBleSearchManager.stop()
        transactionManagerResultLiveData.value = null
        transactionDataList = null
    }

    private suspend fun processTransactionDataList(
        transactionDataList: List<TransactionData>,
        isGroupTransaction: Boolean
    ): List<TransactionData>? {
        if (transactionDataList.isEmpty()) {
            return null
        }
        transactionDataList.forEach { it.createTransaction() ?: return null }
        if (isGroupTransaction) {
            createGroupedBytesArray(transactionDataList)?.let {
                for (index in 0L until it.length()) {
                    transactionDataList[index.toInt()].transactionByteArray = it.get(index)
                }
            }
        }
        return transactionDataList
    }

    private fun postTxnSignResult(
        bytesArray: ByteArray?,
        transactionData: TransactionData?
    ) {
        if (bytesArray == null || transactionData == null) {
            postResult(Defined(AnnotatedString(stringResId = R.string.an_error_occured)))
        } else {
            postResult(TransactionManagerResult.Success(transactionData.getSignedTransactionDetail(bytesArray)))
        }
    }

    private fun postGroupTxnSignResult(
        groupedBytesArrayList: List<ByteArray?>,
        transactionDataList: List<TransactionData>
    ) {
        val signedGroupTxnDetailList = createSignedTransactionDetailList(transactionDataList, groupedBytesArrayList)
        if (signedGroupTxnDetailList != null) {
            postResult(
                TransactionManagerResult.Success(
                    SignedTransactionDetail.Group(
                        groupedBytesArrayList.flatten(),
                        signedGroupTxnDetailList
                    )
                )
            )
        } else {
            postResult(Defined(AnnotatedString(stringResId = R.string.an_error_occured)))
        }
    }

    private fun createSignedTransactionDetailList(
        transactionDataList: List<TransactionData>,
        signedBytesArrayList: List<ByteArray?>
    ): List<SignedTransactionDetail>? {
        return mutableListOf<SignedTransactionDetail>().apply {
            for (index in transactionDataList.indices) {
                signedBytesArrayList[index]?.let {
                    add(transactionDataList[index].getSignedTransactionDetail(it))
                } ?: return null
            }
        }
    }

    private fun createGroupedBytesArray(transactionDataList: List<TransactionData>): BytesArray? {
        return mutableListOf<ByteArray>().apply {
            transactionDataList.forEach {
                it.transactionByteArray?.let { transactionByteArray ->
                    add(transactionByteArray)
                } ?: return null
            }
        }.toBytesArray().assignGroupId()
    }
}
