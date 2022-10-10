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

package com.algorand.android.modules.assets.profile.about.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.assets.profile.about.ui.model.AssetAboutPreview
import com.algorand.android.modules.assets.profile.about.ui.usecase.AssetAboutPreviewUseCase
import com.algorand.android.usecase.NetworkSlugUseCase
import com.algorand.android.utils.getOrElse
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class AssetAboutViewModel @Inject constructor(
    private val assetAboutPreviewUseCase: AssetAboutPreviewUseCase,
    private val networkSlugUseCase: NetworkSlugUseCase,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val assetId = savedStateHandle.getOrThrow<Long>(ASSET_ID_KEY)
    val isBottomPaddingNeeded = savedStateHandle.getOrElse(IS_BOTTOM_PADDING_NEEDED_KEY, false)

    private val _assetAboutPreviewFlow = MutableStateFlow<AssetAboutPreview?>(null)
    val assetAboutPreviewFlow: StateFlow<AssetAboutPreview?> get() = _assetAboutPreviewFlow

    init {
        cacheAssetDetailToAsaProfileLocalCache()
        initAssetAboutPreview()
    }

    fun getActiveNodeNetworkSlug(): String? {
        return networkSlugUseCase.getActiveNodeSlug()
    }

    fun clearAsaProfileLocalCache() {
        viewModelScope.launch {
            assetAboutPreviewUseCase.clearAsaProfileLocalCache()
        }
    }

    private fun cacheAssetDetailToAsaProfileLocalCache() {
        viewModelScope.launch {
            assetAboutPreviewUseCase.cacheAssetDetailToAsaProfileLocalCache(assetId)
        }
    }

    private fun initAssetAboutPreview() {
        viewModelScope.launch {
            assetAboutPreviewUseCase.getAssetAboutPreview(assetId).collect {
                _assetAboutPreviewFlow.emit(it)
            }
        }
    }

    companion object {
        const val ASSET_ID_KEY = "assetId"
        const val IS_BOTTOM_PADDING_NEEDED_KEY = "isBottomPaddingNeeded"
    }
}
