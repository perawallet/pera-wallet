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

package com.algorand.android.modules.sorting.accountsorting.ui

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.sorting.accountsorting.domain.model.AccountSortingPreview
import com.algorand.android.modules.sorting.accountsorting.domain.model.AccountSortingType
import com.algorand.android.modules.sorting.accountsorting.domain.model.BaseAccountSortingListItem
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.AccountSortingPreviewUseCase
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class AccountSortViewModel @ViewModelInject constructor(
    private val accountSortingPreviewUseCase: AccountSortingPreviewUseCase
) : ViewModel() {

    private val selectedSortingPreferencesFlow = MutableStateFlow(AccountSortingType.getDefaultSortOption())

    private val _accountSortingPreviewFlow = MutableStateFlow(accountSortingPreviewUseCase.getInitialSortingPreview())
    val accountSortingPreviewFlow: StateFlow<AccountSortingPreview> = _accountSortingPreviewFlow

    init {
        initSelectedSortingPreferenceFlow()
        initAccountSortingPreview()
    }

    fun saveSortedAccountListIfSortedManually(baseAccountSortingList: List<BaseAccountSortingListItem>) {
        val currentSortingPreference = selectedSortingPreferencesFlow.value
        if (currentSortingPreference !is AccountSortingType.ManuallySort) return
        accountSortingPreviewUseCase.saveManuallySortedAccountList(
            baseAccountSortingList = baseAccountSortingList,
            sortingPreferences = currentSortingPreference
        )
    }

    fun onAccountItemMoved(fromPosition: Int, toPosition: Int) {
        val accountSortingPreview = accountSortingPreviewUseCase.swapItemsAndUpdateList(
            currentPreview = accountSortingPreviewFlow.value,
            fromPosition = fromPosition,
            toPosition = toPosition,
            sortingPreferences = selectedSortingPreferencesFlow.value
        )
        _accountSortingPreviewFlow.value = accountSortingPreview
    }

    fun onSortingPreferencesSelected(accountSortingType: AccountSortingType) {
        selectedSortingPreferencesFlow.value = accountSortingType
    }

    fun saveSortingPreferences() {
        viewModelScope.launch {
            accountSortingPreviewUseCase.saveSortingPreferences(selectedSortingPreferencesFlow.value)
        }
    }

    private fun initSelectedSortingPreferenceFlow() {
        viewModelScope.launch {
            viewModelScope.launch {
                selectedSortingPreferencesFlow.value = accountSortingPreviewUseCase.getAccountSortingPreference()
            }
        }
    }

    private fun initAccountSortingPreview() {
        viewModelScope.launch {
            selectedSortingPreferencesFlow.collectLatest { accountSortingType ->
                _accountSortingPreviewFlow.value = accountSortingPreviewUseCase.createSortingPreview(accountSortingType)
            }
        }
    }
}
