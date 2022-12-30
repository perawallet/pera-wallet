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

package com.algorand.android.modules.accountdetail.nftfilter.ui

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.accountdetail.nftfilter.ui.model.AccountNFTFilterPreview
import com.algorand.android.modules.accountdetail.nftfilter.ui.usecase.AccountNFTFilterPreviewUseCase
import com.algorand.android.utils.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@HiltViewModel
class AccountNFTFilterViewModel @Inject constructor(
    private val accountNFTFilterPreviewUseCase: AccountNFTFilterPreviewUseCase
) : BaseViewModel() {

    private val _accountNFTFilterPreviewFlow = MutableStateFlow<AccountNFTFilterPreview?>(null)
    val accountNFTFilterPreviewFlow get() = _accountNFTFilterPreviewFlow

    init {
        initAccountNFTFilterPreviewFlow()
    }

    private fun initAccountNFTFilterPreviewFlow() {
        viewModelScope.launch {
            _accountNFTFilterPreviewFlow.emit(accountNFTFilterPreviewUseCase.getCollectibleFiltersPreviewFlow())
        }
    }

    fun onDisplayOptedInNFTsSwitchChanged(isChecked: Boolean) {
        updatePreviewState {
            it.copy(displayOptedInNFTsPreference = isChecked)
        }
    }

    fun saveChanges() {
        with(_accountNFTFilterPreviewFlow.value ?: return) {
            with(accountNFTFilterPreviewUseCase) {
                viewModelScope.launch(Dispatchers.IO) {
                    saveDisplayOptedInNFTsPreference(displayOptedInNFTsPreference)
                    _accountNFTFilterPreviewFlow.update { it?.copy(onNavigateBackEvent = Event(Unit)) }
                }
            }
        }
    }

    private fun updatePreviewState(action: (AccountNFTFilterPreview) -> AccountNFTFilterPreview) {
        _accountNFTFilterPreviewFlow.value = _accountNFTFilterPreviewFlow.value?.run {
            action(this)
        }
    }
}
