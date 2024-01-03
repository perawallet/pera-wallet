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

package com.algorand.android.modules.sorting.assetsorting.ui

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.sorting.assetsorting.ui.model.AssetSortPreferencePreview
import com.algorand.android.modules.sorting.assetsorting.ui.usecase.AssetSortPreferencePreviewUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class AssetSortPreferenceViewModel @Inject constructor(
    private val assetSortPreferencePreviewUseCase: AssetSortPreferencePreviewUseCase
) : BaseViewModel() {

    private val _assetSortPreferencePreviewFlow = MutableStateFlow<AssetSortPreferencePreview?>(null)
    val assetSortPreferencePreviewFlow: StateFlow<AssetSortPreferencePreview?>
        get() = _assetSortPreferencePreviewFlow

    init {
        viewModelScope.launch {
            _assetSortPreferencePreviewFlow.value = getInitialPreview()
        }
    }

    fun savePreferenceChanges() {
        viewModelScope.launch {
            val selectedPreference = _assetSortPreferencePreviewFlow.value ?: return@launch
            assetSortPreferencePreviewUseCase.saveAssetSortSelectedPreference(selectedPreference)
        }
    }

    fun onAlphabeticallyAscendingSelected() {
        _assetSortPreferencePreviewFlow.value = assetSortPreferencePreviewUseCase
            .getUpdatedPreviewForAlphabeticallyAscending()
    }

    fun onAlphabeticallyDescendingSelected() {
        _assetSortPreferencePreviewFlow.value = assetSortPreferencePreviewUseCase
            .getUpdatedPreviewForAlphabeticallyDescending()
    }

    fun onBalanceAscendingSelected() {
        _assetSortPreferencePreviewFlow.value = assetSortPreferencePreviewUseCase.getUpdatedPreviewForBalanceAscending()
    }

    fun onBalanceDescendingSelected() {
        _assetSortPreferencePreviewFlow.value =
            assetSortPreferencePreviewUseCase.getUpdatedPreviewForBalanceDescending()
    }

    private suspend fun getInitialPreview(): AssetSortPreferencePreview {
        return assetSortPreferencePreviewUseCase.getAssetSortPreferencePreview()
    }
}
