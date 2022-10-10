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

package com.algorand.android.modules.walletconnectfallbackbrowser.ui

import android.content.pm.PackageManager
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.walletconnectfallbackbrowser.ui.model.FallbackBrowserSelectionPreview
import com.algorand.android.modules.walletconnectfallbackbrowser.ui.usecase.FallbackBrowserSelectionPreviewUseCase
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class FallbackBrowserSelectionViewModel @Inject constructor(
    private val fallbackBrowserSelectionPreviewUseCase: FallbackBrowserSelectionPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    val fallbackBrowserSelectionPreviewFlow: Flow<FallbackBrowserSelectionPreview>
        get() = _fallbackBrowserSelectionPreviewFlow
    private val _fallbackBrowserSelectionPreviewFlow = MutableStateFlow(getInitialLoadingPreview())

    private val browserGroup = savedStateHandle.getOrThrow<String>(BROWSER_GROUP_KEY)

    fun updatePreviewWithBrowserList(packageManager: PackageManager?) {
        viewModelScope.launch {
            _fallbackBrowserSelectionPreviewFlow.emit(
                fallbackBrowserSelectionPreviewUseCase.getFallbackBrowserPreview(
                    browserGroupResponse = browserGroup,
                    packageManager = packageManager
                )
            )
        }
    }

    private fun getInitialLoadingPreview(): FallbackBrowserSelectionPreview {
        return fallbackBrowserSelectionPreviewUseCase.getInitialLoadingPreview()
    }

    companion object {
        private const val BROWSER_GROUP_KEY = "browserGroup"
    }
}
