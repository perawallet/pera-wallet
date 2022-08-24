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

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.AccountDetailAssetsItem
import com.algorand.android.modules.accountdetail.assets.ui.AccountAssetsFragment.Companion.ADDRESS_KEY
import com.algorand.android.modules.tracking.accountdetail.accountassets.AccountAssetsFragmentEventTracker
import com.algorand.android.usecase.AccountAssetsPreviewUseCase
import com.algorand.android.utils.getOrThrow
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.launch

class AccountAssetsViewModel @ViewModelInject constructor(
    private val accountAssetsPreviewUseCase: AccountAssetsPreviewUseCase,
    @Assisted private val savedStateHandle: SavedStateHandle,
    private val accountAssetsFragmentEventTracker: AccountAssetsFragmentEventTracker
) : ViewModel() {

    val accountAssetsFlow: StateFlow<List<AccountDetailAssetsItem>?>
        get() = _accountAssetsFlow
    private val _accountAssetsFlow = MutableStateFlow<List<AccountDetailAssetsItem>?>(null)

    private val searchQueryFlow = MutableStateFlow("")

    private var updateQueryJob: Job? = null

    private val accountAddress: String = savedStateHandle.getOrThrow(ADDRESS_KEY)

    fun initAccountAssetsFlow() {
        viewModelScope.launch {
            searchQueryFlow
                .debounce(QUERY_DEBOUNCE)
                .distinctUntilChanged()
                .flatMapLatest { query ->
                    accountAssetsPreviewUseCase.fetchAccountDetail(accountAddress, query)
                }.collectLatest { list -> _accountAssetsFlow.emit(list) }
        }
    }

    fun updateSearchQuery(query: String) {
        updateQueryJob?.cancel()
        updateQueryJob = viewModelScope.launch { searchQueryFlow.emit(query) }
    }

    fun logAccountAssetsAddAssetEvent() {
        viewModelScope.launch {
            accountAssetsFragmentEventTracker.logAccountAssetsAddAssetEvent()
        }
    }

    fun logAccountAssetsManageAssetsEvent() {
        viewModelScope.launch {
            accountAssetsFragmentEventTracker.logAccountAssetsManageAssetsEvent()
        }
    }

    fun logAccountAssetsBuyAlgoTapEventTracker() {
        viewModelScope.launch {
            accountAssetsFragmentEventTracker.logAccountAssetsBuyAlgoTapEvent()
        }
    }

    fun canAccountSignTransactions(): Boolean {
        return accountAssetsPreviewUseCase.canAccountSignTransactions(savedStateHandle.getOrThrow(ADDRESS_KEY))
    }

    companion object {
        private const val QUERY_DEBOUNCE = 400L
    }
}
