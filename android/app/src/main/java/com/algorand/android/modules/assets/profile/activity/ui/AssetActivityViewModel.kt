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

package com.algorand.android.modules.assets.profile.activity.ui

import javax.inject.Inject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import androidx.paging.CombinedLoadStates
import androidx.paging.PagingData
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.DateFilter
import com.algorand.android.models.ui.DateFilterPreview
import com.algorand.android.models.ui.TransactionLoadStatePreview
import com.algorand.android.modules.transaction.csv.ui.model.CsvStatusPreview
import com.algorand.android.modules.transaction.csv.ui.usecase.CsvStatusPreviewUseCase
import com.algorand.android.modules.transactionhistory.ui.model.BaseTransactionItem
import com.algorand.android.usecase.AssetDetailUseCase
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
class AssetActivityViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val assetDetailUseCase: AssetDetailUseCase,
    private val csvStatusPreviewUseCase: CsvStatusPreviewUseCase
) : BaseViewModel() {

    private val accountPublicKey = savedStateHandle.getOrThrow<String>(ADDRESS_KEY)
    private val assetId = savedStateHandle.getOrThrow<Long>(ASSET_ID_KEY)

    private val dateFilterFlow = MutableStateFlow<DateFilter>(DateFilter.AllTime)
    private val _dateFilterPreviewFlow = MutableStateFlow(getDefaultDateFilterPreview())
    val dateFilterPreviewFlow: Flow<DateFilterPreview>
        get() = _dateFilterPreviewFlow

    private var pendingTransactionPolling: Job? = null

    private val _pendingTransactionsFlow = MutableStateFlow<List<BaseTransactionItem>?>(null)
    val pendingTransactionsFlow: Flow<List<BaseTransactionItem>?>
        get() = _pendingTransactionsFlow
            .distinctUntilChanged(assetDetailUseCase.pendingTransactionDistinctUntilChangedListener)

    val transactionPaginationFlow: Flow<PagingData<BaseTransactionItem>>?
        get() = assetDetailUseCase.getTransactionFlow(accountPublicKey, assetId, viewModelScope)

    val csvStatusPreview: Flow<CsvStatusPreview?>
        get() = _csvStatusPreviewFlow
    private val _csvStatusPreviewFlow = MutableStateFlow<CsvStatusPreview?>(null)

    init {
        initRefreshTransactionsFlow()
        initDateFilterFlow()
    }

    fun getDateFilterValue(): DateFilter {
        return dateFilterFlow.value
    }

    fun setDateFilter(dateFilter: DateFilter) {
        viewModelScope.launch {
            dateFilterFlow.emit(dateFilter)
            _dateFilterPreviewFlow.emit(assetDetailUseCase.createDateFilterPreview(dateFilter))
        }
    }

    fun activatePendingTransaction() {
        activatePendingTransactionsPolling(accountPublicKey)
    }

    fun deactivatePendingTransaction() {
        pendingTransactionPolling?.cancel()
    }

    fun createTransactionLoadStatePreview(
        combinedLoadStates: CombinedLoadStates,
        itemCount: Int,
        isLastStateError: Boolean
    ): TransactionLoadStatePreview {
        return assetDetailUseCase.createTransactionLoadStatePreview(combinedLoadStates, itemCount, isLastStateError)
    }

    fun refreshTransactionHistory() {
        assetDetailUseCase.refreshTransactionHistory()
    }

    fun createCsvFile(cacheDirectory: File) {
        viewModelScope.launch {
            val dateRange = getDateFilterValue().getDateRange()
            csvStatusPreviewUseCase.createCsvFile(
                cacheDir = cacheDirectory,
                dateRange = dateRange,
                publicKey = accountPublicKey,
                assetId = assetId
            ).collectLatest {
                _csvStatusPreviewFlow.emit(it)
            }
        }
    }

    private fun initRefreshTransactionsFlow() {
        viewModelScope.launch {
            assetDetailUseCase.getAccountBalanceFlow(accountPublicKey).distinctUntilChanged().collectLatest {
                assetDetailUseCase.refreshTransactionHistory()
            }
        }
    }

    private fun activatePendingTransactionsPolling(publicKey: String) {
        pendingTransactionPolling = viewModelScope.launch(Dispatchers.IO) {
            while (true) {
                val pendingTransactions = assetDetailUseCase.fetchPendingTransactions(publicKey, assetId)
                synchronized(_pendingTransactionsFlow) {
                    _pendingTransactionsFlow.value = pendingTransactions
                }
                delay(PENDING_TRANSACTION_DELAY)
            }
        }
    }

    private fun initDateFilterFlow() {
        dateFilterFlow
            .onEach { assetDetailUseCase.setDateFilter(it) }
            .distinctUntilChanged()
            .flowOn(Dispatchers.Default)
            .launchIn(viewModelScope)
    }

    private fun getDefaultDateFilterPreview(): DateFilterPreview {
        return assetDetailUseCase.createDateFilterPreview(DateFilter.DEFAULT_DATE_FILTER)
    }

    companion object {
        const val ADDRESS_KEY = "accountAddress"
        const val ASSET_ID_KEY = "assetId"
        private const val PENDING_TRANSACTION_DELAY = 800L
    }
}
