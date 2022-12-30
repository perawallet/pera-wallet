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

package com.algorand.android.modules.accountdetail.assets.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.accountdetail.assets.ui.AccountAssetsFragment.Companion.ADDRESS_KEY
import com.algorand.android.modules.accountdetail.assets.ui.domain.AccountAssetsPreviewUseCase
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem
import com.algorand.android.modules.tracking.accountdetail.accountassets.AccountAssetsFragmentEventTracker
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.launch

@HiltViewModel
class AccountAssetsViewModel @Inject constructor(
    private val accountAssetsPreviewUseCase: AccountAssetsPreviewUseCase,
    private val accountAssetsFragmentEventTracker: AccountAssetsFragmentEventTracker,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val accountAddress: String = savedStateHandle.getOrThrow(ADDRESS_KEY)

    val accountAssetsFlow: StateFlow<List<AccountDetailAssetsItem>?> get() = _accountAssetsFlow
    private val _accountAssetsFlow = MutableStateFlow<List<AccountDetailAssetsItem>?>(null)

    private val searchQueryFlow = MutableStateFlow("")

    private var searchQueryFlowJob: Job? = null

    fun initAccountAssetsFlow() {
        searchQueryFlowJob?.cancel()

        searchQueryFlowJob = viewModelScope.launch(Dispatchers.IO) {
            searchQueryFlow
                .debounce(QUERY_DEBOUNCE)
                .distinctUntilChanged()
                .flatMapLatest { query ->
                    accountAssetsPreviewUseCase.fetchAccountDetail(accountAddress, query)
                }.collectLatest { list -> _accountAssetsFlow.emit(list) }
        }
    }

    fun updateSearchQuery(query: String) {
        searchQueryFlow.value = query
    }

    fun logAccountAssetsAddAssetEvent() {
        viewModelScope.launch(Dispatchers.IO) {
            accountAssetsFragmentEventTracker.logAccountAssetsAddAssetEvent()
        }
    }

    fun logAccountAssetsManageAssetsEvent() {
        viewModelScope.launch(Dispatchers.IO) {
            accountAssetsFragmentEventTracker.logAccountAssetsManageAssetsEvent()
        }
    }

    fun logAccountAssetsBuyAlgoTapEventTracker() {
        viewModelScope.launch(Dispatchers.IO) {
            accountAssetsFragmentEventTracker.logAccountAssetsBuyAlgoTapEvent()
        }
    }

    fun canAccountSignTransactions(): Boolean {
        return accountAssetsPreviewUseCase.canAccountSignTransactions(accountAddress)
    }

    companion object {
        private const val QUERY_DEBOUNCE = 400L
    }
}
