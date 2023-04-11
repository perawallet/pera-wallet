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
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.LedgerBleResult
import com.algorand.android.models.Result
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TransactionData
import com.algorand.android.models.TransactionManagerResult
import com.algorand.android.models.TransactionManagerResult.Error.GlobalWarningError.Defined
import com.algorand.android.models.TransactionManagerResult.Error.GlobalWarningError.MinBalanceError
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
import com.algorand.android.utils.mapToNotNullableListOrNull
import com.algorand.android.utils.minBalancePerAssetAsBigInteger
import com.algorand.android.utils.recordException
import com.algorand.android.utils.sendErrorLog
import com.algorand.android.utils.signTx
import com.algorand.android.utils.toBytesArray
import java.math.BigInteger
import java.net.ConnectException
import java.net.SocketException
import javax.inject.Inject
import kotlinx.coroutines.cancelChildren
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
        override fun onLedgerScanned(
            device: BluetoothDevice,
            currentTransactionIndex: Int?,
            totalTransactionCount: Int?
        ) {
            ledgerBleSearchManager.stop()
            currentScope.launch {
                signHelper.currentItem?.run {
                    ledgerBleOperationManager.startLedgerOperation(
                        newOperation = TransactionOperation(device, this),
                        currentTransactionIndex = currentTransactionIndex,
                        totalTransactionCount = totalTransactionCount
                    )
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
                    setSignFailed(TransactionManagerResult.Error.GlobalWarningError.Api(errorMessage))
                is LedgerBleResult.AppErrorResult -> setSignFailed(Defined(AnnotatedString(errorMessageId), titleResId))
                is LedgerBleResult.OperationCancelledResult -> setSignFailed(
                    Defined(AnnotatedString(R.string.error_cancelled_message), R.string.error_cancelled_title)
                )
                is LedgerBleResult.OnMissingBytes -> setSignFailed(
                    Defined(AnnotatedString(R.string.error_sending_message), R.string.error_bluetooth_title)
                )
                else -> {
                    sendErrorLog("Unhandled else case in operationManagerCollectorAction")
                }
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
                val safeSignedTransactions = signedTransactions.mapToNotNullableListOrNull { it }
                if (safeSignedTransactions == null) {
                    postResult(Defined(AnnotatedString(stringResId = R.string.an_error_occured)))
                    return
                }
                transactionDataList?.let { postGroupTxnSignResult(safeSignedTransactions, it) }
            }
        }

        override fun onNextItemToBeDequeued(
            transaction: TransactionData,
            currentItemIndex: Int,
            totalItemCount: Int
        ) {
            val accountDetail = transaction.senderAccountDetail
            if (accountDetail == null) {
                setSignFailed(Defined(AnnotatedString(stringResId = R.string.an_error_occured)))
            } else {
                // TODO: add [currentItemIndex] and [totalItemCount] after merging this core swap screens
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
            ledgerBleOperationManager.ledgerBleResultFlow.collect {
                operationManagerCollectorAction.invoke(it)
            }
        }
    }

    fun initSigningTransactions(isGroupTransaction: Boolean, vararg transactionData: TransactionData) {
        currentScope.launch {
            postResult(TransactionManagerResult.Loading)
            transactionData.toList().ifEmpty {
                setSignFailed(Defined(AnnotatedString(stringResId = R.string.an_error_occured)))
                return@launch
            }.let { transactionList ->
                processTransactionDataList(transactionList, isGroupTransaction)?.let {
                    this@TransactionManager.transactionDataList = it
                    signHelper.initItemsToBeEnqueued(it)
                }
            }
        }
    }

    private fun TransactionData.signTxn(accountDetail: Account.Detail, checkIfRekeyed: Boolean = true) {
        if (checkIfRekeyed && isSenderRekeyedToAnotherAccount) {
            when (accountDetail) {
                is Account.Detail.RekeyedAuth -> {
                    accountDetail.rekeyedAuthDetail[senderAuthAddress].let { rekeyedAuthDetail ->
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
                        setSignFailed(Defined(AnnotatedString(stringResId = R.string.the_signing_account_has)))
                    }
                }
                is Account.Detail.Standard -> {
                    if (accountDetail.secretKey.isNotEmpty()) {
                        checkAndCacheSignedTransaction(transactionByteArray?.signTx(accountDetail.secretKey))
                    } else {
                        setSignFailed(Defined(AnnotatedString(stringResId = R.string.the_signing_account_has)))
                    }
                }
                else -> {
                    val exceptionMessage = "$senderAccountType cannot sign by itself."
                    recordException(Exception(exceptionMessage))
                    setSignFailed(Defined(AnnotatedString(stringResId = R.string.an_error_occured)))
                }
            }
        }
    }

    private fun TransactionData.signTxnWithCheckingOtherAccounts() {
        when (val authAccountDetail = accountCacheManager.getCacheData(senderAuthAddress)?.account?.detail) {
            is Account.Detail.Standard -> {
                checkAndCacheSignedTransaction(transactionByteArray?.signTx(authAccountDetail.secretKey))
            }
            is Account.Detail.Ledger -> {
                sendTransactionWithLedger(authAccountDetail)
            }
            else -> {
                postResult(Defined(AnnotatedString(stringResId = R.string.the_signing_account_has)))
            }
        }
    }

    @SuppressWarnings("LongMethod")
    suspend fun TransactionData.createTransaction(): ByteArray? {
        val transactionParams = getTransactionParams(this) ?: return null

        val createdTransactionByteArray = when (this) {
            is TransactionData.Send -> {
                projectedFee = calculatedFee ?: transactionParams.getTxFee()
                // calculate isMax before calculating real amount because while isMax true fee will be deducted.
                isMax = isTransactionMax(amount, senderAccountAddress, assetInformation.assetId)
                // TODO: 10.08.2022 Get all those calculations from a single AmountTransactionValidationUseCase
                amount = calculateAmount(
                    projectedAmount = amount,
                    isMax = isMax,
                    isSenderRekeyedToAnotherAccount = isSenderRekeyedToAnotherAccount,
                    senderMinimumBalance = minimumBalance,
                    assetId = assetInformation.assetId,
                    fee = projectedFee
                ) ?: return null

                if (isSenderRekeyedToAnotherAccount) {
                    // if account is rekeyed to another account, min balance should be deducted from the amount.
                    // after it'll be deducted, isMax will be false to not write closeToAddress.
                    isMax = false
                }

                if (isCloseToSameAccount()) {
                    return null
                }

                transactionParams.makeTx(
                    senderAddress = senderAccountAddress,
                    receiverAddress = targetUser.publicKey,
                    amount = amount,
                    assetId = assetInformation.assetId,
                    isMax = isMax,
                    note = if (xnote.isNullOrBlank()) note else xnote
                )
            }
            is TransactionData.AddAsset -> {
                transactionParams.makeAddAssetTx(senderAccountAddress, assetInformation.assetId)
            }
            is TransactionData.RemoveAsset -> {
                if (shouldCreateAssetRemoveTransaction(senderAccountAddress, assetInformation.assetId)) {
                    transactionParams.makeRemoveAssetTx(
                        senderAddress = senderAccountAddress,
                        creatorPublicKey = creatorPublicKey,
                        assetId = assetInformation.assetId
                    )
                } else {
                    null
                }
            }
            is TransactionData.SendAndRemoveAsset -> {
                transactionParams.makeSendAndRemoveAssetTx(
                    senderAddress = senderAccountAddress,
                    receiverAddress = targetUser.publicKey,
                    assetId = assetInformation.assetId,
                    amount = amount
                )
            }
            is TransactionData.Rekey -> {
                transactionParams.makeRekeyTx(senderAccountAddress, rekeyAdminAddress)
            }
            is TransactionData.RekeyToStandardAccount -> {
                transactionParams.makeRekeyTx(senderAccountAddress, rekeyAdminAddress)
            }
        }

        transactionByteArray = createdTransactionByteArray

        return createdTransactionByteArray
    }

    private suspend fun getTransactionParams(transactionData: TransactionData): TransactionParams? {
        when (val result = transactionsRepository.getTransactionParams()) {
            is Result.Success -> {
                transactionParams = result.data
            }
            is Result.Error -> {
                transactionParams = null
                when (result.exception.cause) {
                    is ConnectException, is SocketException -> {
                        postResult(Defined(AnnotatedString(R.string.the_internet_connection)))
                    }
                    else -> {
                        when (transactionData) {
                            is TransactionData.AddAsset -> {
                                postResult(
                                    TransactionManagerResult.Error.SnackbarError.Retry(
                                        titleResId = R.string.error_while_opting_to_the,
                                        descriptionResId = null,
                                        buttonTextResId = R.string.retry
                                    )
                                )
                            }
                            is TransactionData.Rekey,
                            is TransactionData.Send,
                            is TransactionData.SendAndRemoveAsset,
                            is TransactionData.RekeyToStandardAccount,
                            is TransactionData.RemoveAsset -> {
                                postResult(
                                    TransactionManagerResult.Error.GlobalWarningError.Api(
                                        result.exception.message.orEmpty()
                                    )
                                )
                            }
                        }
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
        isSenderRekeyedToAnotherAccount: Boolean,
        senderMinimumBalance: Long,
        assetId: Long,
        fee: Long
    ): BigInteger? {
        val calculatedAmount = if (isMax && assetId == AssetInformation.ALGO_ID) {
            if (isSenderRekeyedToAnotherAccount) {
                projectedAmount - fee.toBigInteger() - senderMinimumBalance.toBigInteger()
            } else {
                projectedAmount - fee.toBigInteger()
            }
        } else {
            projectedAmount
        }

        if (calculatedAmount isLesserThan BigInteger.ZERO) {
            if (isSenderRekeyedToAnotherAccount) {
                val errorMinBalance = AnnotatedString(
                    stringResId = R.string.the_transaction_cannot_be,
                    replacementList = listOf("min_balance" to senderMinimumBalance.formatAsAlgoString())
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
        if (this is TransactionData.Send && isMax && senderAccountAddress == targetUser.publicKey) {
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
        var minBalance = accountCacheManager.getMinBalanceOfAccount(senderAccountAddress)
        when (this) {
            is TransactionData.AddAsset ->
                minBalance += minBalancePerAssetAsBigInteger
            is TransactionData.RemoveAsset -> {
                minBalance -= minBalancePerAssetAsBigInteger
            }
            else -> {
                sendErrorLog("Unhandled else case in isMinimumLimitViolated")
            }
        }

        val balance = accountCacheManager.getAssetInformation(
            senderAccountAddress,
            AssetInformation.ALGO_ID
        )?.amount ?: run {
            setSignFailed(Defined(AnnotatedString(stringResId = R.string.minimum_balance_required)))
            return true
        }

        val fee = calculatedFee?.toBigInteger() ?: run {
            setSignFailed(Defined(AnnotatedString(stringResId = R.string.minimum_balance_required)))
            return true
        }

        // fee only drops from the algos.
        val balanceAfterTransaction =
            if (this is TransactionData.Send && assetInformation.isAlgo().not()) {
                balance - fee
            } else {
                balance - fee - amount
            }

        if (balanceAfterTransaction < minBalance) {
            if (this is TransactionData.AddAsset) {
                postResult(MinBalanceError(minBalance + fee))
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
        ledgerBleSearchManager.scan(
            newScanCallback = scanCallback,
            filteredAddress = ledgerAddress,
            coroutineScope = currentScope
        )
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
        groupedBytesArrayList: List<ByteArray>,
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
        signedBytesArrayList: List<ByteArray>
    ): List<SignedTransactionDetail>? {
        return mutableListOf<SignedTransactionDetail>().apply {
            for (index in transactionDataList.indices) {
                val signedTxn = signedBytesArrayList[index]
                add(transactionDataList[index].getSignedTransactionDetail(signedTxn))
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
