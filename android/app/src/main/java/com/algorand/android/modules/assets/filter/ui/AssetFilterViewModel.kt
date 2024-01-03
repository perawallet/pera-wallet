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

package com.algorand.android.modules.assets.filter.ui

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.assets.filter.ui.model.AssetFilterPreview
import com.algorand.android.modules.assets.filter.ui.usecase.AssetFilterPreviewUseCase
import com.algorand.android.utils.Event
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@HiltViewModel
class AssetFilterViewModel @Inject constructor(
    private val assetFilterPreviewUseCase: AssetFilterPreviewUseCase
) : BaseViewModel() {

    private val _assetFilterPreviewFlow = MutableStateFlow<AssetFilterPreview?>(null)
    val assetFilterPreviewFlow: StateFlow<AssetFilterPreview?> get() = _assetFilterPreviewFlow

    init {
        initAssetFilterPreviewFlow()
    }

    fun onShowZeroBalanceAssetsSwitchCheckChanged(newValue: Boolean) {
        updatePreviewState {
            it.copy(hideZeroBalanceAssets = newValue)
        }
    }

    fun onDisplayNFTInAssetsSwitchCheckChanged(newValue: Boolean) {
        updatePreviewState {
            it.copy(
                displayNFTInAssets = newValue,
                isDisplayOptedInNFTInAssetsOptionActive = newValue,
                displayOptedInNFTInAssets = if (!newValue) false else it.displayOptedInNFTInAssets
            )
        }
    }

    fun onDisplayOptedInNFTInAssetsSwitchCheckChanged(newValue: Boolean) {
        updatePreviewState {
            it.copy(displayOptedInNFTInAssets = newValue)
        }
    }

    fun saveChanges() {
        with(_assetFilterPreviewFlow.value ?: return) {
            with(assetFilterPreviewUseCase) {
                viewModelScope.launch(Dispatchers.IO) {
                    saveFilterZeroBalanceAssetPreference(hideZeroBalanceAssets)
                    saveDisplayNFTInAssetsPreference(displayNFTInAssets)
                    saveDisplayOptedInNFTInAssetsPreference(displayOptedInNFTInAssets)
                    _assetFilterPreviewFlow.update { it?.copy(onNavigateBackEvent = Event(Unit)) }
                }
            }
        }
    }

    private fun initAssetFilterPreviewFlow() {
        viewModelScope.launch {
            _assetFilterPreviewFlow.emit(assetFilterPreviewUseCase.getAssetFilterPreview())
        }
    }

    private fun updatePreviewState(action: (AssetFilterPreview) -> AssetFilterPreview) {
        _assetFilterPreviewFlow.value = _assetFilterPreviewFlow.value?.run {
            action(this)
        }
    }
}
