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
import com.algorand.android.models.DateFilter
import com.algorand.android.models.ui.DateFilterPreview
import com.algorand.android.models.ui.TransactionLoadStatePreview
import com.algorand.android.modules.accounts.domain.mapper.AccountValueMapper
import com.algorand.android.modules.accounts.domain.model.AccountValue
import com.algorand.android.modules.transactionhistory.ui.model.BaseTransactionItem
import com.algorand.android.modules.transactionhistory.ui.usecase.PendingTransactionsPreviewUseCase
import com.algorand.android.modules.transactionhistory.ui.usecase.TransactionHistoryPreviewUseCase
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged

class AccountHistoryUseCase @Inject constructor(
    private val transactionHistoryPreviewUseCase: TransactionHistoryPreviewUseCase,
    private val pendingTransactionsPreviewUseCase: PendingTransactionsPreviewUseCase,
    private val dateFilterUseCase: DateFilterUseCase,
    private val transactionLoadStateUseCase: TransactionLoadStateUseCase,
    private val getAccountTotalCollectibleValueUseCase: GetAccountTotalCollectibleValueUseCase,
    private val getAccountTotalAssetValueUseCase: GetAccountTotalAssetValueUseCase,
    private val accountValueMapper: AccountValueMapper
) : BaseUseCase() {

    val pendingTransactionDistinctUntilChangedListener
        get() = pendingTransactionsPreviewUseCase.pendingFlowDistinctUntilChangedListener

    fun getTransactionPaginationFlow(
        publicKey: String,
        coroutineScope: CoroutineScope
    ): Flow<PagingData<BaseTransactionItem>>? {
        return transactionHistoryPreviewUseCase.getTransactionHistoryPaginationFlow(publicKey, coroutineScope)
    }

    fun refreshAccountHistoryData() {
        transactionHistoryPreviewUseCase.refreshTransactionHistory()
    }

    fun getAccountTotalValueFlow(accountAddress: String): Flow<AccountValue> {
        return combine(
            getAccountAssetValueFlow(accountAddress).distinctUntilChanged(),
            getAccountCollectibleValueFlow(accountAddress).distinctUntilChanged()
        ) { assetValue, collectibleValue ->
            accountValueMapper.mapTo(
                primaryAccountValue = assetValue.primaryAccountValue + collectibleValue.primaryAccountValue,
                secondaryAccountValue = assetValue.secondaryAccountValue + collectibleValue.secondaryAccountValue,
                assetCount = assetValue.assetCount + collectibleValue.assetCount
            )
        }
    }

    private fun getAccountAssetValueFlow(publicKey: String): Flow<AccountValue> {
        return getAccountTotalAssetValueUseCase.getAccountTotalAssetValueFlow(publicKey)
    }

    private fun getAccountCollectibleValueFlow(accountAddress: String): Flow<AccountValue> {
        return getAccountTotalCollectibleValueUseCase.getAccountTotalCollectibleValueFlow(accountAddress)
    }

    suspend fun fetchPendingTransactions(publicKey: String): List<BaseTransactionItem> {
        return pendingTransactionsPreviewUseCase.getPendingTransactionItems(publicKey)
    }

    fun createDateFilterPreview(dateFilter: DateFilter): DateFilterPreview {
        return dateFilterUseCase.createDateFilterPreview(dateFilter)
    }

    suspend fun setDateFilter(dateFilter: DateFilter) {
        transactionHistoryPreviewUseCase.filterHistoryByDate(dateFilter)
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
}
