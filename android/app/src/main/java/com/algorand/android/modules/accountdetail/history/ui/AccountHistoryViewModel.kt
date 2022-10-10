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

package com.algorand.android.modules.accountdetail.history.ui

import javax.inject.Inject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.paging.CombinedLoadStates
import androidx.paging.PagingData
import com.algorand.android.models.DateFilter
import com.algorand.android.models.ui.DateFilterPreview
import com.algorand.android.models.ui.TransactionLoadStatePreview
import com.algorand.android.modules.tracking.accountdetail.accounthistory.AccountHistoryFragmentEventTracker
import com.algorand.android.modules.transaction.csv.ui.model.CsvStatusPreview
import com.algorand.android.modules.transaction.csv.ui.usecase.CsvStatusPreviewUseCase
import com.algorand.android.modules.transactionhistory.ui.model.BaseTransactionItem
import com.algorand.android.usecase.AccountHistoryUseCase
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import java.io.File
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch

@HiltViewModel
class AccountHistoryViewModel @Inject constructor(
    private val accountHistoryUseCase: AccountHistoryUseCase,
    private val csvStatusPreviewUseCase: CsvStatusPreviewUseCase,
    private val accountHistoryFragmentEventTracker: AccountHistoryFragmentEventTracker,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val dateFilterFlow = MutableStateFlow<DateFilter>(DateFilter.AllTime)

    private val _dateFilterPreviewFlow = MutableStateFlow(getDefaultDateFilterPreview())
    val dateFilterPreviewFlow: Flow<DateFilterPreview>
        get() = _dateFilterPreviewFlow

    private var pendingTransactionPolling: Job? = null

    private val _pendingTransactionsFlow = MutableStateFlow<List<BaseTransactionItem>?>(null)
    val pendingTransactionsFlow: Flow<List<BaseTransactionItem>?>
        get() = _pendingTransactionsFlow
            .distinctUntilChanged(accountHistoryUseCase.pendingTransactionDistinctUntilChangedListener)

    val csvStatusPreview: Flow<CsvStatusPreview?>
        get() = _csvStatusPreviewFlow
    private val _csvStatusPreviewFlow = MutableStateFlow<CsvStatusPreview?>(null)

    val accountAddress = savedStateHandle.getOrThrow<String>(PUBLIC_KEY)

    init {
        startAccountBalanceFlow()
        initDateFilterFlow()
    }

    fun getDateFilterValue(): DateFilter {
        return dateFilterFlow.value
    }

    fun setDateFilter(dateFilter: DateFilter) {
        viewModelScope.launch {
            dateFilterFlow.emit(dateFilter)
            _dateFilterPreviewFlow.emit(accountHistoryUseCase.createDateFilterPreview(dateFilter))
        }
    }

    fun getAccountHistoryFlow(): Flow<PagingData<BaseTransactionItem>>? {
        return accountHistoryUseCase.getTransactionPaginationFlow(accountAddress, viewModelScope)
    }

    fun activatePendingTransaction() {
        activatePendingTransactionsPolling()
    }

    fun deactivatePendingTransaction() {
        pendingTransactionPolling?.cancel()
    }

    fun createTransactionLoadStatePreview(
        combinedLoadStates: CombinedLoadStates,
        itemCount: Int,
        isLastStateError: Boolean
    ): TransactionLoadStatePreview {
        return accountHistoryUseCase.createTransactionLoadStatePreview(combinedLoadStates, itemCount, isLastStateError)
    }

    fun refreshTransactionHistory() {
        accountHistoryUseCase.refreshTransactionHistory()
    }

    fun createCsvFile(cacheDirectory: File) {
        viewModelScope.launch {
            val dateRange = getDateFilterValue().getDateRange()
            csvStatusPreviewUseCase.createCsvFile(
                cacheDir = cacheDirectory,
                dateRange = dateRange,
                publicKey = accountAddress
            ).collectLatest {
                _csvStatusPreviewFlow.emit(it)
            }
        }
    }

    private fun initDateFilterFlow() {
        dateFilterFlow
            .onEach { accountHistoryUseCase.setDateFilter(it) }
            .distinctUntilChanged()
            .flowOn(Dispatchers.Default)
            .launchIn(viewModelScope)
    }

    private fun refreshAccountHistoryData() {
        accountHistoryUseCase.refreshAccountHistoryData()
    }

    private fun activatePendingTransactionsPolling() {
        pendingTransactionPolling = viewModelScope.launch(Dispatchers.IO) {
            while (true) {
                val pendingTransactions = accountHistoryUseCase.fetchPendingTransactions(accountAddress)
                synchronized(_pendingTransactionsFlow) {
                    _pendingTransactionsFlow.value = pendingTransactions
                }
                delay(PENDING_TRANSACTION_DELAY)
            }
        }
    }

    private fun getDefaultDateFilterPreview(): DateFilterPreview {
        return accountHistoryUseCase.createDateFilterPreview(DateFilter.DEFAULT_DATE_FILTER)
    }

    private fun startAccountBalanceFlow() {
        viewModelScope.launch {
            accountHistoryUseCase.getAccountTotalValueFlow(accountAddress).distinctUntilChanged().collectLatest {
                refreshAccountHistoryData()
            }
        }
    }

    fun logAccountHistoryFilterEventTracker() {
        viewModelScope.launch {
            accountHistoryFragmentEventTracker.logAccountHistoryFilterEvent()
        }
    }

    fun logAccountHistoryExportCsvEventTracker() {
        viewModelScope.launch {
            accountHistoryFragmentEventTracker.logAccountHistoryExportCsvEvent()
        }
    }

    companion object {
        const val PUBLIC_KEY = "public_key"
        private const val PENDING_TRANSACTION_DELAY = 800L
    }
}
