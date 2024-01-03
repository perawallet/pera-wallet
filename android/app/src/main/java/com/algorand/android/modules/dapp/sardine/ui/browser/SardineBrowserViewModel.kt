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

package com.algorand.android.modules.dapp.sardine.ui.browser

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.dapp.sardine.ui.browser.model.SardineBrowserPreview
import com.algorand.android.modules.dapp.sardine.ui.browser.usecase.SardineBrowserPreviewUseCase
import com.algorand.android.modules.perawebview.ui.BasePeraWebViewViewModel
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class SardineBrowserViewModel @Inject constructor(
    private val sardineBrowserPreviewUseCase: SardineBrowserPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BasePeraWebViewViewModel() {

    private val title = savedStateHandle.getOrThrow<String>(TITLE_KEY)
    private val url = savedStateHandle.getOrThrow<String>(URL_KEY)

    private val _sardineBrowserPreviewFlow = MutableStateFlow(
        sardineBrowserPreviewUseCase.getInitialStatePreview(title, url)
    )
    val sardineBrowserPreviewFlow: StateFlow<SardineBrowserPreview>
        get() = _sardineBrowserPreviewFlow

    fun reloadPage() {
        clearLastError()
        viewModelScope.launch {
            _sardineBrowserPreviewFlow
                .emit(sardineBrowserPreviewUseCase.getInitialStatePreview(title, url))
        }
    }

    fun onHomeNavButtonClicked() {
        viewModelScope.launch {
            _sardineBrowserPreviewFlow
                .emit(sardineBrowserPreviewUseCase.requestLoadHomepage(_sardineBrowserPreviewFlow.value, title, url))
        }
    }

    fun onPreviousNavButtonClicked() {
        viewModelScope.launch {
            _sardineBrowserPreviewFlow
                .emit(sardineBrowserPreviewUseCase.onPreviousNavButtonClicked(_sardineBrowserPreviewFlow.value))
        }
    }

    fun onNextNavButtonClicked() {
        viewModelScope.launch {
            _sardineBrowserPreviewFlow
                .emit(sardineBrowserPreviewUseCase.onNextNavButtonClicked(_sardineBrowserPreviewFlow.value))
        }
    }

    override fun onPageFinished(title: String?, url: String?) {
        viewModelScope.launch {
            _sardineBrowserPreviewFlow
                .emit(
                    sardineBrowserPreviewUseCase.onPageFinished(
                        previousState = _sardineBrowserPreviewFlow.value,
                        title = title,
                        url = url
                    )
                )
        }
    }

    override fun onError() {
        viewModelScope.launch {
            _sardineBrowserPreviewFlow
                .emit(sardineBrowserPreviewUseCase.onError(_sardineBrowserPreviewFlow.value))
        }
    }

    override fun onHttpError() {
        viewModelScope.launch {
            _sardineBrowserPreviewFlow
                .emit(sardineBrowserPreviewUseCase.onHttpError(_sardineBrowserPreviewFlow.value))
        }
    }

    override fun onPageUrlChanged() {
        viewModelScope.launch {
            _sardineBrowserPreviewFlow
                .emit(sardineBrowserPreviewUseCase.onPageUrlChanged(_sardineBrowserPreviewFlow.value))
        }
    }

    companion object {
        private const val TITLE_KEY = "title"
        private const val URL_KEY = "url"
    }
}
