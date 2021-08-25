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

package com.algorand.android.core

import android.bluetooth.BluetoothDevice
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.coroutineScope
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
import com.algorand.android.models.TransactionData
import com.algorand.android.models.TransactionManagerResult
import com.algorand.android.models.TransactionParams
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Event
import com.algorand.android.utils.LifecycleScopedCoroutineOwner
import com.algorand.android.utils.formatAsAlgoString
import com.algorand.android.utils.getTxFee
import com.algorand.android.utils.makeAddAssetTx
import com.algorand.android.utils.makeRekeyTx
import com.algorand.android.utils.makeRemoveAssetTx
import com.algorand.android.utils.makeTx
import com.algorand.android.utils.minBalancePerAssetAsBigInteger
import com.algorand.android.utils.signTx
import com.google.firebase.crashlytics.FirebaseCrashlytics
import java.math.BigInteger
import java.net.ConnectException
import java.net.SocketException
import javax.inject.Inject
import kotlinx.coroutines.cancelChildren
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class TransactionManager @Inject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val ledgerBleSearchManager: LedgerBleSearchManager,
    private val transactionsRepository: TransactionsRepository,
    private val ledgerBleOperationManager: LedgerBleOperationManager
) : LifecycleScopedCoroutineOwner() {

    val transactionManagerResultLiveData = MutableLiveData<Event<TransactionManagerResult>?>()

    private var transactionParams: TransactionParams? = null
    private var currentTransactionData: TransactionData? = null

    private val scanCallback = object : CustomScanCallback() {
        override fun onLedgerScanned(device: BluetoothDevice) {
            ledgerBleSearchManager.stop()
            currentScope.launch {
                currentTransactionData?.run {
                    ledgerBleOperationManager.startLedgerOperation(TransactionOperation(device, this))
                }
            }
        }

        override fun onScanError(errorMessageResId: Int, titleResId: Int) {
            postResult(TransactionManagerResult.Error.Defined(AnnotatedString(errorMessageResId), titleResId))
        }
    }

    private val operationManagerCollectorAction: (suspend (Event<LedgerBleResult>?) -> Unit) = { ledgerBleResultEvent ->
        ledgerBleResultEvent?.consume()?.run {
            when (this) {
                is LedgerBleResult.LedgerWaitingForApproval -> {
                    postResult(TransactionManagerResult.LedgerWaitingForApproval)
                }
                is LedgerBleResult.SignedTransactionResult -> {
                    processSignedTransactionData(transactionByteArray)
                }
                is LedgerBleResult.LedgerErrorResult -> {
                    postResult(TransactionManagerResult.Error.Api(errorMessage))
                }
                is LedgerBleResult.AppErrorResult -> {
                    postResult(TransactionManagerResult.Error.Defined(AnnotatedString(errorMessageId), titleResId))
                }
                is LedgerBleResult.OperationCancelledResult -> {
                    postResult(
                        TransactionManagerResult.Error.Defined(
                            AnnotatedString(R.string.error_cancelled_message),
                            R.string.error_cancelled_title
                        )
                    )
                }
            }
        }
    }

    fun setup(lifecycle: Lifecycle) {
        assignToLifecycle(lifecycle)
        setupLedgerOperationManager(lifecycle)
    }

    private fun setupLedgerOperationManager(lifecycle: Lifecycle) {
        ledgerBleOperationManager.setup(lifecycle)
        lifecycle.coroutineScope.launch {
            ledgerBleOperationManager.ledgerBleResultFlow.collect(action = operationManagerCollectorAction)
        }
    }

    fun signTransaction(transactionData: TransactionData) {
        currentScope.launch {
            postResult(TransactionManagerResult.Loading)
            currentTransactionData = transactionData.apply {
                createTransaction()
            }
            transactionData.accountCacheData.account.detail?.let {
                currentTransactionData?.process(it)
            }
        }
    }

    private fun TransactionData.process(accountDetail: Account.Detail, checkIfRekeyed: Boolean = true) {
        if (checkIfRekeyed && accountCacheData.isRekeyedToAnotherAccount()) {
            when (accountDetail) {
                is Account.Detail.RekeyedAuth -> {
                    accountDetail.rekeyedAuthDetail[accountCacheData.authAddress].let { rekeyedAuthDetail ->
                        if (rekeyedAuthDetail != null) {
                            process(rekeyedAuthDetail, checkIfRekeyed = false)
                        } else {
                            processWithCheckingOtherAccounts()
                        }
                    }
                }
                else -> {
                    processWithCheckingOtherAccounts()
                }
            }
        } else {
            when (accountDetail) {
                is Account.Detail.Ledger -> {
                    sendTransactionWithLedger(accountDetail)
                }
                is Account.Detail.RekeyedAuth -> {
                    if (accountDetail.authDetail != null) {
                        process(accountDetail.authDetail, checkIfRekeyed = false)
                    } else {
                        TransactionManagerResult.Error.Defined(AnnotatedString(stringResId = R.string.this_account_has))
                    }
                }
                is Account.Detail.Standard -> {
                    processSignedTransactionData(transactionByteArray?.signTx(accountDetail.secretKey))
                }
                else -> {
                    val exceptionMessage = "${accountCacheData.account.type} cannot sign by itself."
                    FirebaseCrashlytics.getInstance().recordException(Exception(exceptionMessage))
                    postResult(
                        TransactionManagerResult.Error.Defined(AnnotatedString(stringResId = R.string.an_error_occured))
                    )
                }
            }
        }
    }

    private fun TransactionData.processWithCheckingOtherAccounts() {
        when (val authAccountDetail = accountCacheManager.getCacheData(accountCacheData.authAddress)?.account?.detail) {
            is Account.Detail.Standard -> {
                processSignedTransactionData(transactionByteArray?.signTx(authAccountDetail.secretKey))
            }
            is Account.Detail.Ledger -> {
                sendTransactionWithLedger(authAccountDetail)
            }
            else -> {
                postResult(
                    TransactionManagerResult.Error.Defined(AnnotatedString(stringResId = R.string.this_account_has))
                )
            }
        }
    }

    private suspend fun TransactionData.createTransaction(): ByteArray? {
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
                    accountCacheData.account.address,
                    targetUser.publicKey,
                    amount,
                    assetInformation.assetId,
                    isMax,
                    note
                )
            }
            is TransactionData.AddAsset -> {
                transactionParams.makeAddAssetTx(accountCacheData.account.address, assetInformation.assetId)
            }
            is TransactionData.RemoveAsset -> {
                transactionParams.makeRemoveAssetTx(
                    accountCacheData.account.address,
                    creatorPublicKey,
                    assetInformation.assetId
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
                            TransactionManagerResult.Error.Defined(AnnotatedString(R.string.the_internet_connection))
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

    private fun processSignedTransactionData(signedTransactionData: ByteArray?) {
        currentScope.launch {
            if (signedTransactionData == null) {
                postResult(TransactionManagerResult.Error.Defined(AnnotatedString(R.string.unknown_error)))
                return@launch
            }

            currentTransactionData?.run {
                calculatedFee = transactionParams?.getTxFee(signedTransactionData)

                if (this is TransactionData.Send && projectedFee != calculatedFee) {
                    signTransaction(this)
                    return@launch
                }

                if (isMinimumLimitViolated()) {
                    return@launch
                }

                postResult(TransactionManagerResult.Success(getSignedTransactionDetail(signedTransactionData)))
            }
        }
    }

    private fun sendCurrentTransaction(bluetoothDevice: BluetoothDevice) {
        currentTransactionData?.run {
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
        val calculatedAmount = if (isMax && assetId == AssetInformation.ALGORAND_ID) {
            if (accountCacheData.isRekeyedToAnotherAccount()) {
                projectedAmount - fee.toBigInteger() - accountCacheData.getMinBalance()
            } else {
                projectedAmount - fee.toBigInteger()
            }
        } else {
            projectedAmount
        }

        if (calculatedAmount < BigInteger.ZERO) {
            if (accountCacheData.isRekeyedToAnotherAccount()) {
                val errorMinBalance = AnnotatedString(
                    stringResId = R.string.the_transaction_cannot_be,
                    replacementList = listOf("min_balance" to accountCacheData.getMinBalance().formatAsAlgoString())
                )
                postResult(TransactionManagerResult.Error.Defined(errorMinBalance))
            } else {
                postResult(TransactionManagerResult.Error.Defined(AnnotatedString(R.string.transaction_amount_results)))
            }
            return null
        }

        return calculatedAmount
    }

    private fun isTransactionMax(amount: BigInteger, publicKey: String, assetId: Long): Boolean {
        if (assetId != AssetInformation.ALGORAND_ID) {
            return false
        } else {
            accountCacheManager.getAssetInformation(publicKey, assetId)?.let { assetBalanceInformation ->
                return amount == assetBalanceInformation.amount
            }
            return false
        }
    }

    private fun TransactionData.isCloseToSameAccount(): Boolean {
        if (this is TransactionData.Send && isMax && accountCacheData.account.address == targetUser.publicKey) {
            postResult(TransactionManagerResult.Error.Defined(AnnotatedString(R.string.you_cannot_send)))
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
            AssetInformation.ALGORAND_ID
        )?.amount ?: return true

        val fee = calculatedFee?.toBigInteger() ?: return true

        // fee only drops from the algos.
        val balanceAfterTransaction =
            if (this is TransactionData.Send && assetInformation.isAlgorand().not()) {
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
                postResult(TransactionManagerResult.Error.Defined(description))
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
        currentTransactionData = null
    }
}
