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

import androidx.paging.CombinedLoadStates
import androidx.paging.PagingData
import com.algorand.android.core.BaseUseCase
import com.algorand.android.decider.DateFilterUseCase
import com.algorand.android.mapper.AssetDetailPreviewMapper
import com.algorand.android.mapper.CsvStatusPreviewMapper
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.BaseTransactionItem
import com.algorand.android.models.CsvStatusPreview
import com.algorand.android.models.DateFilter
import com.algorand.android.models.DateRange
import com.algorand.android.models.Result
import com.algorand.android.models.ui.AssetDetailPreview
import com.algorand.android.models.ui.DateFilterPreview
import com.algorand.android.models.ui.TransactionLoadStatePreview
import java.io.File
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@SuppressWarnings("LongParameterList")
class AssetDetailUseCase @Inject constructor(
    private val algoPriceUseCase: AlgoPriceUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val algoRewardUseCase: AlgoRewardUseCase,
    private val transactionUseCase: TransactionUseCase,
    private val pendingTransactionUseCase: PendingTransactionUseCase,
    private val dateFilterUseCase: DateFilterUseCase,
    private val assetDetailPreviewMapper: AssetDetailPreviewMapper,
    private val accountAlgoAmountUseCase: AccountAlgoAmountUseCase,
    private val accountAssetAmountUseCase: AccountAssetAmountUseCase,
    private val transactionLoadStateUseCase: TransactionLoadStateUseCase,
    private val createCsvUseCase: CreateCsvUseCase,
    private val csvStatusPreviewMapper: CsvStatusPreviewMapper,
    private val accountTotalBalanceUseCase: AccountTotalBalanceUseCase
) : BaseUseCase() {

    val pendingTransactionDistinctUntilChangedListener
        get() = pendingTransactionUseCase.pendingFlowDistinctUntilChangedListener

    fun getAssetDetailPreviewFlow(publicKey: String, assetId: Long): Flow<AssetDetailPreview?> {
        return combine(
            algoPriceUseCase.getAlgoPriceCacheFlow(),
            accountDetailUseCase.getAccountDetailCacheFlow(publicKey),
            simpleAssetDetailUseCase.getCachedAssetsFlow()
        ) { _, accountDetailCache, _ ->
            if (assetId == ALGORAND_ID) {
                createAssetDetailPreviewForAlgo(accountDetailCache?.data)
            } else {
                createAssetDetailPreviewForOtherAssets(accountDetailCache?.data, assetId)
            }
        }.distinctUntilChanged()
    }

    fun getAccountBalanceFlow(publicKey: String) = accountTotalBalanceUseCase.getAccountBalanceFlow(publicKey)

    fun getPendingRewards(publicKey: String): Long {
        return algoRewardUseCase.getPendingRewards(publicKey)
    }

    fun fetchAssetTransactionHistory(publicKey: String, cacheInScope: CoroutineScope, assetId: Long) {
        transactionUseCase.fetchAssetTransactionHistory(assetId, publicKey, cacheInScope)
    }

    fun getTransactionFlow(publicKey: String, assetIdFilter: Long): Flow<PagingData<BaseTransactionItem>>? {
        return transactionUseCase.getTransactionPaginationFlow(publicKey, assetIdFilter)
    }

    suspend fun setDateFilter(dateFilter: DateFilter) {
        transactionUseCase.filterHistoryByDate(dateFilter)
    }

    fun createDateFilterPreview(dateFilter: DateFilter): DateFilterPreview {
        return dateFilterUseCase.createDateFilterPreview(dateFilter)
    }

    fun createTransactionLoadStatePreview(
        combinedLoadStates: CombinedLoadStates,
        itemCount: Int,
        isLastStateError: Boolean
    ): TransactionLoadStatePreview {
        return transactionLoadStateUseCase.createTransactionLoadStatePreview(
            combinedLoadStates = combinedLoadStates,
            itemCount = itemCount,
            isLastStateError = isLastStateError
        )
    }

    fun refreshTransactionHistory() {
        transactionUseCase.refreshTransactionHistory()
    }

    fun createCsvFile(
        assetId: Long,
        cacheDir: File,
        dateRange: DateRange?,
        publicKey: String,
        scope: CoroutineScope
    ): Flow<CsvStatusPreview> {
        return createCsvUseCase
            .createTransactionHistoryCsvFile(cacheDir, publicKey, dateRange, assetId, scope)
            .map { csvStatusPreviewMapper.mapToCsvStatus(it) }
    }

    suspend fun fetchPendingTransactions(publicKey: String, assetId: Long): Result<List<BaseTransactionItem>> {
        return pendingTransactionUseCase.fetchPendingTransactions(publicKey, assetId)
    }

    private fun createAssetDetailPreviewForAlgo(accountDetail: AccountDetail?): AssetDetailPreview? {
        // TODO Find a better way to handling null & error cases
        if (accountDetail == null) return null

        val algoAmountData = accountAlgoAmountUseCase.getAccountAlgoAmount(accountDetail.account.address)
        val canAccountSignTransaction = accountDetailUseCase.canAccountSignTransaction(accountDetail.account.address)
        return assetDetailPreviewMapper.mapToAssetDetailPreview(
            algoAmountData,
            canAccountSignTransaction
        )
    }

    private fun createAssetDetailPreviewForOtherAssets(
        accountDetail: AccountDetail?,
        assetId: Long
    ): AssetDetailPreview? {
        // TODO Find a better way to handling null & error cases
        if (accountDetail == null) return null

        val assetHolding = accountDetail.accountInformation.assetHoldingList.firstOrNull { it.assetId == assetId }
            ?: return null
        val assetQueryItem = simpleAssetDetailUseCase.getCachedAssetDetail(assetId)?.data
            ?: return null

        val canAccountSignTransaction = accountDetailUseCase.canAccountSignTransaction(
            accountDetail.account.address
        )
        val assetData = accountAssetAmountUseCase.getAssetAmount(assetHolding, assetQueryItem)
        return assetDetailPreviewMapper.mapToAssetDetailPreview(assetData, canAccountSignTransaction)
    }
}
