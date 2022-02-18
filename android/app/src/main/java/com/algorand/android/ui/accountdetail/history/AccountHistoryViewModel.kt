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

package com.algorand.android.ui.accountdetail.history

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import androidx.paging.CombinedLoadStates
import androidx.paging.PagingData
import com.algorand.android.models.BaseTransactionItem
import com.algorand.android.models.CsvStatusPreview
import com.algorand.android.models.DateFilter
import com.algorand.android.models.ui.DateFilterPreview
import com.algorand.android.models.ui.TransactionLoadStatePreview
import com.algorand.android.usecase.AccountHistoryUseCase
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

class AccountHistoryViewModel @ViewModelInject constructor(
    private val accountHistoryUseCase: AccountHistoryUseCase
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

    init {
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

    fun startAccountBalanceFlow(publicKey: String) {
        viewModelScope.launch {
            accountHistoryUseCase.getAccountBalanceFlow(publicKey).distinctUntilChanged().collectLatest {
                refreshAccountHistoryData()
            }
        }
    }

    fun getAccountHistoryFlow(publicKey: String): Flow<PagingData<BaseTransactionItem>>? {
        return accountHistoryUseCase.getTransactionPaginationFlow(publicKey)
    }

    fun activatePendingTransaction(address: String) {
        activatePendingTransactionsPolling(address)
    }

    fun deactivatePendingTransaction() {
        pendingTransactionPolling?.cancel()
    }

    fun getAccountHistory(publicKey: String) {
        accountHistoryUseCase.fetchAccountHistory(publicKey, viewModelScope)
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

    fun createCsvFile(cacheDirectory: File, accountPublicKey: String) {
        viewModelScope.launch {
            val dateRange = getDateFilterValue().getDateRange()
            accountHistoryUseCase.createCsvFile(cacheDirectory, dateRange, accountPublicKey, this).collectLatest {
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

    private fun activatePendingTransactionsPolling(publicKey: String) {
        pendingTransactionPolling = viewModelScope.launch(Dispatchers.IO) {
            while (true) {
                accountHistoryUseCase.fetchPendingTransactions(publicKey).use(
                    onSuccess = { pendingList ->
                        synchronized(_pendingTransactionsFlow) {
                            _pendingTransactionsFlow.value = pendingList
                        }
                    }
                )
                delay(PENDING_TRANSACTION_DELAY)
            }
        }
    }

    private fun getDefaultDateFilterPreview(): DateFilterPreview {
        return accountHistoryUseCase.createDateFilterPreview(DateFilter.DEFAULT_DATE_FILTER)
    }

    companion object {
        private const val PENDING_TRANSACTION_DELAY = 800L
    }
}
