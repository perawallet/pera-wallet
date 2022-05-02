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

package com.algorand.android.usecase

import androidx.paging.PagingData
import androidx.paging.PagingSource
import androidx.paging.filter
import androidx.paging.insertSeparators
import androidx.paging.map
import com.algorand.android.core.BaseUseCase
import com.algorand.android.decider.TransactionUserUseCase
import com.algorand.android.mapper.AccountHistoryFeeItemMapper
import com.algorand.android.mapper.AccountHistoryHeaderMapper
import com.algorand.android.mapper.AccountHistoryRewardItemMapper
import com.algorand.android.mapper.AccountHistoryTransferItemMapper
import com.algorand.android.mapper.TransactionItemTypeMapper
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.models.BaseTransactionItem
import com.algorand.android.models.DateFilter
import com.algorand.android.models.DateRange
import com.algorand.android.models.Result
import com.algorand.android.models.Transaction
import com.algorand.android.models.TransactionItemType
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.repository.TransactionHistoryPaginationHelper
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.utils.formatAsDate
import com.algorand.android.utils.formatAsRFC3339Version
import com.algorand.android.utils.getZonedDateTimeFromTimeStamp
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.map

@SuppressWarnings("LongParameterList")
class TransactionUseCase @Inject constructor(
    private val transactionsRepository: TransactionsRepository,
    private val transactionHistoryPaginationHelper: TransactionHistoryPaginationHelper,
    private val accountHistoryRewardItemMapper: AccountHistoryRewardItemMapper,
    private val accountHistoryHeaderMapper: AccountHistoryHeaderMapper,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val transactionUserUseCase: TransactionUserUseCase,
    private val accountHistoryTransferItemMapper: AccountHistoryTransferItemMapper,
    private val accountHistoryFeeItemMapper: AccountHistoryFeeItemMapper,
    private val transactionItemTypeMapper: TransactionItemTypeMapper,
    private val algoRewardUseCase: AlgoRewardUseCase,
    private val collectibleUseCase: SimpleCollectibleUseCase
) : BaseUseCase() {

    private val isRewardsActivated = algoRewardUseCase.isRewardActivated()
    private val dateFilterQuery = MutableStateFlow<DateFilter>(DateFilter.AllTime)

    private val headerSeparator: suspend (
        BaseTransactionItem.TransactionItem?,
        BaseTransactionItem.TransactionItem?
    ) -> BaseTransactionItem.StringTitleItem? = { firstTxnItem, secondTxnItem ->
        if (shouldAddDateSeparator(firstTxnItem, secondTxnItem)) {
            val transactionDate = secondTxnItem?.zonedDateTime?.formatAsDate()
            accountHistoryHeaderMapper.mapTo(transactionDate)
        } else {
            null
        }
    }

    private val rewardSeparator: suspend (
        BaseTransactionItem.TransactionItem?,
        BaseTransactionItem.TransactionItem?
    ) -> BaseTransactionItem.TransactionItem? = { firstTxnItem, _ ->
        if (shouldAddRewardSeparator(firstTxnItem?.isAlgorand)) {
            val assetId = firstTxnItem?.assetId ?: ALGORAND_ID
            val otherPublicKey = if (firstTxnItem?.otherPublicKey == firstTxnItem?.accountPublicKey) {
                firstTxnItem?.accountPublicKey
            } else {
                firstTxnItem?.otherPublicKey
            }
            accountHistoryRewardItemMapper.mapTo(
                transaction = firstTxnItem,
                assetDetail = getAssetDetail(assetId),
                accountPublicKey = firstTxnItem?.accountPublicKey.orEmpty(),
                transactionTargetUser = transactionUserUseCase.getTransactionTargetUser(otherPublicKey)
            )
        } else {
            null
        }
    }

    fun fetchAccountTransactionHistory(publicKey: String, cacheInScope: CoroutineScope) {
        transactionHistoryPaginationHelper.fetchTransactionHistory(cacheInScope) { params ->
            onLoadTransactions(publicKey, params, cacheInScope)
        }
    }

    fun fetchAssetTransactionHistory(assetId: Long, publicKey: String, cacheInScope: CoroutineScope) {
        transactionHistoryPaginationHelper.fetchTransactionHistory(cacheInScope) { params ->
            onLoadTransactions(publicKey, params, cacheInScope, assetId)
        }
    }

    private suspend fun onLoadTransactions(
        publicKey: String,
        params: PagingSource.LoadParams<String>,
        coroutineScope: CoroutineScope,
        assetId: Long? = null
    ): PagingSource.LoadResult<String, Transaction> {
        val response = transactionsRepository.getTransactionHistory(
            assetId,
            publicKey,
            fromDate = dateFilterQuery.value.getDateRange()?.from.formatAsRFC3339Version(),
            toDate = dateFilterQuery.value.getDateRange()?.to.formatAsRFC3339Version(),
            nextToken = params.key,
        )
        return try {
            when (response) {
                is Result.Error -> PagingSource.LoadResult.Error(response.exception)
                is Result.Success -> {
                    val dateFilteredTransactionList = getDateFilteredTransactionList(
                        response.data.transactionList,
                        dateFilterQuery.value.getDateRange()
                    )
                    val assetIds = dateFilteredTransactionList.mapNotNull { it.getAssetId() }.toSet()
                    simpleAssetDetailUseCase.cacheIfThereIsNonCachedAsset(assetIds, coroutineScope)
                    PagingSource.LoadResult.Page(
                        data = dateFilteredTransactionList,
                        prevKey = null,
                        nextKey = response.data.nextToken,
                    )
                }
            }
        } catch (exception: Exception) {
            PagingSource.LoadResult.Error(exception)
        }
    }

    fun getTransactionPaginationFlow(
        publicKey: String,
        assetIdFilter: Long? = null
    ): Flow<PagingData<BaseTransactionItem>>? {
        return transactionHistoryPaginationHelper.transactionPaginationFlow?.map { pagingData ->
            pagingData.filter { transaction ->
                assetIdFilter?.let { shouldIncludeInTransactionFlow(transaction, it) } ?: true
            }.map { transaction ->
                val assetId = transaction.getAssetId() ?: ALGORAND_ID
                val asset = getAssetDetail(assetId)
                val receiverAddress = transaction.getReceiverAddress()
                val otherPublicKey = if (receiverAddress == publicKey) {
                    transaction.senderAddress.orEmpty()
                } else {
                    receiverAddress
                }
                val transactionTargetUser = transactionUserUseCase.getTransactionTargetUser(otherPublicKey)
                if (isFeeTransaction(transaction)) {
                    accountHistoryFeeItemMapper.mapTo(transaction, asset, publicKey, transactionTargetUser)
                } else {
                    accountHistoryTransferItemMapper.mapTo(
                        transaction,
                        asset,
                        publicKey,
                        transactionTargetUser,
                        otherPublicKey
                    )
                }
            }
                .insertSeparators(rewardSeparator)
                .insertSeparators(headerSeparator)
        }
    }

    fun refreshTransactionHistory() {
        transactionHistoryPaginationHelper.refreshTransactionHistoryData()
    }

    // Remove this check when the indexer issue has been fixed
    // Issue: https://github.com/algorand/indexer/issues/458
    private fun getDateFilteredTransactionList(
        transactionList: List<Transaction>,
        dateRange: DateRange?
    ): List<Transaction> {
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

    private fun shouldAddDateSeparator(
        firstTxnItem: BaseTransactionItem.TransactionItem?,
        secondTxnItem: BaseTransactionItem.TransactionItem?
    ): Boolean {
        return when {
            secondTxnItem == null -> false
            firstTxnItem == null -> true
            firstTxnItem.zonedDateTime?.dayOfMonth == secondTxnItem.zonedDateTime?.dayOfMonth -> false
            else -> true
        }
    }

    private fun shouldAddRewardSeparator(isAlgorand: Boolean?): Boolean {
        return isRewardsActivated && isAlgorand == true
    }

    private fun getAssetDetail(assetId: Long?): BaseAssetDetail? {
        if (assetId == null) return null
        return simpleAssetDetailUseCase.getCachedAssetDetail(assetId)?.data
            ?: collectibleUseCase.getCachedCollectibleById(assetId)?.data
    }

    private fun shouldIncludeInTransactionFlow(transaction: Transaction, assetIdFilter: Long): Boolean {
        return if (assetIdFilter == ALGORAND_ID) {
            transaction.isAlgorand() || isFeeTransaction(transaction)
        } else {
            isFeeTransaction(transaction).not()
        }
    }

    private fun isFeeTransaction(transaction: Transaction): Boolean {
        return when (transactionItemTypeMapper.mapTo(transaction)) {
            TransactionItemType.ASSET_CREATION,
            TransactionItemType.ASSET_REMOVAL,
            TransactionItemType.REKEY -> true
            else -> false
        }
    }
}
