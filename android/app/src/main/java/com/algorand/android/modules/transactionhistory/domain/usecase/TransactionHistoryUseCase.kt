/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.modules.transactionhistory.domain.usecase

import androidx.paging.PagingData
import androidx.paging.PagingSource
import androidx.paging.insertSeparators
import com.algorand.android.core.BaseUseCase
import com.algorand.android.models.DateFilter
import com.algorand.android.models.DateRange
import com.algorand.android.models.Result
import com.algorand.android.modules.transaction.common.domain.model.TransactionDTO
import com.algorand.android.modules.transaction.common.domain.model.TransactionTypeDTO.APP_TRANSACTION
import com.algorand.android.modules.transaction.common.domain.model.TransactionTypeDTO.ASSET_CONFIGURATION
import com.algorand.android.modules.transaction.common.domain.model.TransactionTypeDTO.ASSET_TRANSACTION
import com.algorand.android.modules.transaction.common.domain.model.TransactionTypeDTO.PAY_TRANSACTION
import com.algorand.android.modules.transactionhistory.domain.mapper.BaseTransactionMapper
import com.algorand.android.modules.transactionhistory.domain.model.BaseTransaction
import com.algorand.android.modules.transactionhistory.domain.pagination.TransactionHistoryPaginationHelper
import com.algorand.android.modules.transactionhistory.domain.repository.TransactionHistoryRepository
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.formatAsDate
import com.algorand.android.utils.formatAsRFC3339Version
import com.algorand.android.utils.getZonedDateTimeFromTimeStamp
import com.algorand.android.utils.isGreaterThan
import com.algorand.android.utils.sendErrorLog
import java.math.BigInteger
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.map

class TransactionHistoryUseCase @Inject constructor(
    @Named(TransactionHistoryRepository.INJECTION_NAME)
    private val transactionHistoryRepository: TransactionHistoryRepository,
    private val transactionHistoryPaginationHelper: TransactionHistoryPaginationHelper,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val baseTransactionMapper: BaseTransactionMapper
) : BaseUseCase() {

    private val dateFilterQuery = MutableStateFlow<DateFilter>(DateFilter.AllTime)

    fun getTransactionPaginationFlow(
        publicKey: String,
        assetIdFilter: Long? = null,
        coroutineScope: CoroutineScope,
        txnType: String? = null
    ): Flow<PagingData<BaseTransaction>>? {
        transactionHistoryPaginationHelper.fetchTransactionHistory(coroutineScope) { params ->
            onLoadTransactions(publicKey, params, coroutineScope, assetIdFilter, txnType)
        }
        return transactionHistoryPaginationHelper.transactionPaginationFlow?.map { pagingData ->
            pagingData.insertSeparators { txn1: BaseTransaction.Transaction?, txn2: BaseTransaction.Transaction? ->
                if (shouldAddDateSeparator(txn1, txn2)) {
                    val transactionDate = txn2?.zonedDateTime?.formatAsDate()
                    baseTransactionMapper.mapToTransactionDateTitle(transactionDate.orEmpty())
                } else {
                    null
                }
            }
        }
    }

    fun refreshTransactionHistory() {
        transactionHistoryPaginationHelper.refreshTransactionHistoryData()
    }

    private suspend fun onLoadTransactions(
        publicKey: String,
        nextKey: String?,
        coroutineScope: CoroutineScope,
        assetId: Long? = null,
        txnType: String? = null
    ): PagingSource.LoadResult<String, BaseTransaction.Transaction> {
        val response = transactionHistoryRepository.getTransactionHistory(
            assetId = assetId,
            publicKey = publicKey,
            fromDate = dateFilterQuery.value.getDateRange()?.from.formatAsRFC3339Version(),
            toDate = dateFilterQuery.value.getDateRange()?.to.formatAsRFC3339Version(),
            nextToken = nextKey,
            txnType = txnType
        )
        return try {
            when (response) {
                is Result.Error -> PagingSource.LoadResult.Error(response.exception)
                is Result.Success -> {
                    val dateFilteredTransactionList = getDateFilteredTransactionList(
                        transactionList = response.data.transactionList,
                        dateRange = dateFilterQuery.value.getDateRange()
                    )
                    val baseTransactionList = dateFilteredTransactionList.mapNotNull { txn ->
                        when (txn.transactionType) {
                            PAY_TRANSACTION -> createPayTransaction(txn, publicKey)
                            ASSET_TRANSACTION -> createAssetTransaction(txn, publicKey)
                            ASSET_CONFIGURATION -> baseTransactionMapper.mapToAssetConfiguration(txn)
                            APP_TRANSACTION -> baseTransactionMapper.mapToApplicationCall(txn)
                            else -> baseTransactionMapper.mapToUndefined(txn)
                        }
                    }
                    val assetIds = getAssetIdsFromTransactions(baseTransactionList)
                    if (assetIds.isNotEmpty()) {
                        simpleAssetDetailUseCase.cacheIfThereIsNonCachedAsset(
                            assetIdList = assetIds,
                            coroutineScope = coroutineScope,
                            includeDeleted = true
                        )
                    }
                    PagingSource.LoadResult.Page(
                        data = baseTransactionList,
                        prevKey = null,
                        nextKey = response.data.nextToken,
                    )
                }
            }
        } catch (exception: Exception) {
            PagingSource.LoadResult.Error(exception)
        }
    }

    private fun getAssetIdsFromTransactions(transactionList: List<BaseTransaction.Transaction>): Set<Long> {
        return mutableSetOf<Long>().apply {
            transactionList.forEach {
                when (it) {
                    is BaseTransaction.Transaction.ApplicationCall -> addAll(it.foreignAssetIds.orEmpty())
                    is BaseTransaction.Transaction.AssetConfiguration -> it.assetId?.let { safeId -> add(safeId) }
                    is BaseTransaction.Transaction.AssetTransfer -> add(it.assetId)
                    else -> {
                        sendErrorLog("Unhandled else case in TransactionHistoryUseCase.getAssetIdsFromTransactions")
                    }
                }
            }
        }
    }

    // Remove this check when the indexer issue has been fixed
    // Issue: https://github.com/algorand/indexer/issues/458
    private fun getDateFilteredTransactionList(
        transactionList: List<TransactionDTO>,
        dateRange: DateRange?
    ): List<TransactionDTO> {
        return if (dateRange?.to == null || dateRange.from == null) {
            transactionList
        } else {
            transactionList.filter { txn ->
                val timestampAsZonedDateTime = txn.roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp()
                return@filter timestampAsZonedDateTime?.isAfter(dateRange.from) ?: true &&
                    timestampAsZonedDateTime?.isBefore(dateRange.to) ?: true
            }
        }
    }

    suspend fun filterHistoryByDate(dateFilter: DateFilter) {
        dateFilterQuery.emit(dateFilter)
        refreshTransactionHistory()
    }

    private fun isReceiveTransaction(
        accountPublicKey: String,
        closeToAddress: String?,
        receiverAddress: String?
    ): Boolean {
        return receiverAddress == accountPublicKey || closeToAddress == accountPublicKey
    }

    private fun isSelfOptInTransaction(
        accountPublicKey: String,
        senderAddress: String?,
        receiverAddress: String?,
        amount: BigInteger
    ): Boolean {
        return isSelfTransaction(accountPublicKey, senderAddress, receiverAddress) && amount == BigInteger.ZERO
    }

    private fun isSelfTransaction(accountPublicKey: String, senderAddress: String?, receiverAddress: String?): Boolean {
        return senderAddress == accountPublicKey && receiverAddress == accountPublicKey
    }

    private fun shouldAddDateSeparator(
        firstTxnItem: BaseTransaction.Transaction?,
        secondTxnItem: BaseTransaction.Transaction?
    ): Boolean {
        return when {
            secondTxnItem == null -> false
            firstTxnItem == null -> true
            firstTxnItem.zonedDateTime?.dayOfMonth == secondTxnItem.zonedDateTime?.dayOfMonth -> false
            else -> true
        }
    }

    private fun createPayTransaction(
        transactionDTO: TransactionDTO,
        publicKey: String
    ): BaseTransaction.Transaction.Pay {
        val closeToAddress = transactionDTO.payment?.closeToAddress
        val receiverAddress = transactionDTO.payment?.receiverAddress
        val senderAddress = transactionDTO.senderAddress
        return when {
            isSelfTransaction(publicKey, senderAddress, receiverAddress) -> {
                baseTransactionMapper.mapToPayTransactionSelf(transaction = transactionDTO)
            }
            isReceiveTransaction(publicKey, closeToAddress, receiverAddress) -> {
                baseTransactionMapper.mapToPayTransactionReceive(transaction = transactionDTO)
            }
            else -> {
                baseTransactionMapper.mapToPayTransactionSend(transaction = transactionDTO)
            }
        }
    }

    private fun createAssetTransaction(
        transactionDTO: TransactionDTO,
        publicKey: String
    ): BaseTransaction.Transaction.AssetTransfer? {
        val closeToAddress = transactionDTO.assetTransfer?.closeTo
        val receiverAddress = transactionDTO.assetTransfer?.receiverAddress
        val senderAddress = transactionDTO.senderAddress
        val amount = transactionDTO.assetTransfer?.amount ?: BigInteger.ZERO
        return with(baseTransactionMapper) {
            when {
                !closeToAddress.isNullOrBlank() && closeToAddress == publicKey -> {
                    mapToAssetTransactionReceiveOptOut(transaction = transactionDTO)
                }
                !closeToAddress.isNullOrBlank() && amount.isGreaterThan(BigInteger.ZERO) -> {
                    mapToAssetTransactionSendOptOut(closeToAddress = closeToAddress, transaction = transactionDTO)
                }
                !closeToAddress.isNullOrBlank() -> {
                    mapToAssetTransactionOptOut(closeToAddress = closeToAddress, transaction = transactionDTO)
                }
                isSelfOptInTransaction(publicKey, senderAddress, receiverAddress, amount) -> {
                    mapToAssetTransactionSelfOptIn(transaction = transactionDTO)
                }
                isSelfTransaction(publicKey, senderAddress, receiverAddress) -> {
                    mapToAssetTransactionSelf(transaction = transactionDTO)
                }
                isReceiveTransaction(publicKey, closeToAddress, receiverAddress) -> {
                    mapToAssetTransactionReceive(transaction = transactionDTO)
                }
                else -> mapToAssetTransactionSend(transactionDTO)
            }
        }
    }
}
