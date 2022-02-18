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
import com.algorand.android.mapper.CsvStatusPreviewMapper
import com.algorand.android.models.BaseTransactionItem
import com.algorand.android.models.CsvStatusPreview
import com.algorand.android.models.DateFilter
import com.algorand.android.models.DateRange
import com.algorand.android.models.Result
import com.algorand.android.models.ui.DateFilterPreview
import com.algorand.android.models.ui.TransactionLoadStatePreview
import java.io.File
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class AccountHistoryUseCase @Inject constructor(
    private val transactionUseCase: TransactionUseCase,
    private val pendingTransactionUseCase: PendingTransactionUseCase,
    private val dateFilterUseCase: DateFilterUseCase,
    private val transactionLoadStateUseCase: TransactionLoadStateUseCase,
    private val createCsvUseCase: CreateCsvUseCase,
    private val csvStatusPreviewMapper: CsvStatusPreviewMapper,
    private val accountTotalBalanceUseCase: AccountTotalBalanceUseCase
) : BaseUseCase() {

    val pendingTransactionDistinctUntilChangedListener
        get() = pendingTransactionUseCase.pendingFlowDistinctUntilChangedListener

    fun getTransactionPaginationFlow(publicKey: String): Flow<PagingData<BaseTransactionItem>>? {
        return transactionUseCase.getTransactionPaginationFlow(publicKey)
    }

    fun fetchAccountHistory(publicKey: String, cacheInScope: CoroutineScope) {
        transactionUseCase.fetchAccountTransactionHistory(publicKey, cacheInScope)
    }

    fun refreshAccountHistoryData() {
        transactionUseCase.refreshTransactionHistory()
    }

    fun getAccountBalanceFlow(publicKey: String) = accountTotalBalanceUseCase.getAccountBalanceFlow(publicKey)

    suspend fun fetchPendingTransactions(publicKey: String): Result<List<BaseTransactionItem>> {
        return pendingTransactionUseCase.fetchPendingTransactions(publicKey)
    }

    fun createDateFilterPreview(dateFilter: DateFilter): DateFilterPreview {
        return dateFilterUseCase.createDateFilterPreview(dateFilter)
    }

    suspend fun setDateFilter(dateFilter: DateFilter) {
        transactionUseCase.filterHistoryByDate(dateFilter)
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
        cacheDir: File,
        dateRange: DateRange?,
        publicKey: String,
        scope: CoroutineScope
    ): Flow<CsvStatusPreview> {
        return createCsvUseCase
            .createTransactionHistoryCsvFile(cacheDir, publicKey, dateRange, null, scope)
            .map { csvStatusPreviewMapper.mapToCsvStatus(it) }
    }
}
