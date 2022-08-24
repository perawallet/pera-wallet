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
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.models.DateFilter
import com.algorand.android.models.ui.AssetDetailPreview
import com.algorand.android.models.ui.DateFilterPreview
import com.algorand.android.models.ui.TransactionLoadStatePreview
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.modules.transaction.common.domain.model.TransactionTypeDTO
import com.algorand.android.modules.transactionhistory.ui.model.BaseTransactionItem
import com.algorand.android.modules.transactionhistory.ui.usecase.PendingTransactionsPreviewUseCase
import com.algorand.android.modules.transactionhistory.ui.usecase.TransactionHistoryPreviewUseCase
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged

@SuppressWarnings("LongParameterList")
class AssetDetailUseCase @Inject constructor(
    private val parityUseCase: ParityUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val transactionHistoryPreviewUseCase: TransactionHistoryPreviewUseCase,
    private val pendingTransactionsPreviewUseCase: PendingTransactionsPreviewUseCase,
    private val dateFilterUseCase: DateFilterUseCase,
    private val assetDetailPreviewMapper: AssetDetailPreviewMapper,
    private val accountAlgoAmountUseCase: AccountAlgoAmountUseCase,
    private val accountAssetAmountUseCase: AccountAssetAmountUseCase,
    private val transactionLoadStateUseCase: TransactionLoadStateUseCase,
    private val accountTotalBalanceUseCase: AccountTotalBalanceUseCase
) : BaseUseCase() {

    val pendingTransactionDistinctUntilChangedListener
        get() = pendingTransactionsPreviewUseCase.pendingFlowDistinctUntilChangedListener

    fun getAssetDetailPreviewFlow(publicKey: String, assetId: Long): Flow<AssetDetailPreview?> {
        return combine(
            parityUseCase.getSelectedCurrencyDetailCacheFlow(),
            accountDetailUseCase.getAccountDetailCacheFlow(publicKey),
            simpleAssetDetailUseCase.getCachedAssetsFlow()
        ) { _, accountDetailCache, _ ->
            if (assetId == ALGO_ID) {
                createAssetDetailPreviewForAlgo(accountDetailCache?.data)
            } else {
                createAssetDetailPreviewForOtherAssets(accountDetailCache?.data, assetId)
            }
        }.distinctUntilChanged()
    }

    fun getAccountBalanceFlow(publicKey: String) = accountTotalBalanceUseCase.getAccountBalanceFlow(publicKey)

    fun getTransactionFlow(
        publicKey: String,
        assetIdFilter: Long,
        cacheInScope: CoroutineScope
    ): Flow<PagingData<BaseTransactionItem>>? {
        return transactionHistoryPreviewUseCase.getTransactionHistoryPaginationFlow(
            publicKey,
            cacheInScope,
            assetIdFilter,
            TransactionTypeDTO.PAY_TRANSACTION.takeIf { assetIdFilter == ALGO_ID }?.value
        )
    }

    suspend fun setDateFilter(dateFilter: DateFilter) {
        transactionHistoryPreviewUseCase.filterHistoryByDate(dateFilter)
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
        transactionHistoryPreviewUseCase.refreshTransactionHistory()
    }

    suspend fun fetchPendingTransactions(publicKey: String, assetId: Long): List<BaseTransactionItem> {
        return pendingTransactionsPreviewUseCase.getPendingTransactionItems(publicKey, assetId)
    }

    private fun createAssetDetailPreviewForAlgo(accountDetail: AccountDetail?): AssetDetailPreview? {
        // TODO Find a better way to handling null & error cases
        if (accountDetail == null) return null

        val algoAmountData = accountAlgoAmountUseCase.getAccountAlgoAmount(accountDetail.account.address)
        val canAccountSignTransaction = accountDetailUseCase.canAccountSignTransaction(accountDetail.account.address)
        return assetDetailPreviewMapper.mapToAssetDetailPreview(
            assetData = algoAmountData,
            canSignTransaction = canAccountSignTransaction,
            formattedAssetBalance = algoAmountData.formattedAmount
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
        return assetDetailPreviewMapper.mapToAssetDetailPreview(
            assetData,
            canAccountSignTransaction,
            assetData.formattedAmount
        )
    }
}
