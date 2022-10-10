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

package com.algorand.android.modules.transaction.detail.ui.applicationcallassets

import javax.inject.Inject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.transaction.detail.ui.model.ApplicationCallAssetInformation
import com.algorand.android.modules.transaction.detail.domain.model.ApplicationCallAssetInformationPreview
import com.algorand.android.modules.transaction.detail.domain.usecase.ApplicationCallAssetsPreviewUseCase
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class ApplicationCallAssetsViewModel @Inject constructor(
    private val applicationCallAssetsPreviewUseCase: ApplicationCallAssetsPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val assetInformationList = savedStateHandle.getOrThrow<Array<ApplicationCallAssetInformation>>(
        ASSET_INFORMATION_LIST_KEY
    )

    private val _assetItemConfigurationFlow = MutableStateFlow<ApplicationCallAssetInformationPreview?>(null)
    val assetItemConfigurationFlow: StateFlow<ApplicationCallAssetInformationPreview?>
        get() = _assetItemConfigurationFlow

    init {
        initPreviewFlow()
    }

    private fun initPreviewFlow() {
        viewModelScope.launch {
            _assetItemConfigurationFlow.emit(
                applicationCallAssetsPreviewUseCase.initApplicationCallAssetInformationPreview(assetInformationList)
            )
        }
    }

    companion object {
        private const val ASSET_INFORMATION_LIST_KEY = "assetInformationList"
    }
}
