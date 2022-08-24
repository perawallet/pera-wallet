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

package com.algorand.android.modules.assets.assetsort.ui.assetsortpreference

import androidx.hilt.lifecycle.ViewModelInject
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.assets.assetsort.ui.assetsortpreference.model.AssetSortPreferencePreview
import com.algorand.android.modules.assets.assetsort.ui.assetsortpreference.usecase.AssetSortPreferencePreviewUseCase
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

class AssetSortPreferenceViewModel @ViewModelInject constructor(
    private val assetSortPreferencePreviewUseCase: AssetSortPreferencePreviewUseCase
) : BaseViewModel() {

    private val _assetSortPreferencePreviewFlow = MutableStateFlow<AssetSortPreferencePreview>(
        assetSortPreferencePreviewUseCase.getAssetSortPreferencePreview()
    )
    val assetSortPreferencePreviewFlow: StateFlow<AssetSortPreferencePreview>
        get() = _assetSortPreferencePreviewFlow

    fun savePreferenceChanges() {
        assetSortPreferencePreviewUseCase.saveAssetSortSelectedPreference(_assetSortPreferencePreviewFlow.value)
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
        _assetSortPreferencePreviewFlow.value = assetSortPreferencePreviewUseCase
            .getUpdatedPreviewForBalanceDescending()
    }
}
