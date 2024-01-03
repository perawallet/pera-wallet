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

package com.algorand.android.modules.dapp.transak.ui.browser

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.dapp.transak.ui.browser.model.TransakBrowserPreview
import com.algorand.android.modules.dapp.transak.ui.browser.usecase.TransakBrowserPreviewUseCase
import com.algorand.android.modules.perawebview.ui.BasePeraWebViewViewModel
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class TransakBrowserViewModel @Inject constructor(
    private val transakBrowserPreviewUseCase: TransakBrowserPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BasePeraWebViewViewModel() {

    private val title = savedStateHandle.getOrThrow<String>(TITLE_KEY)
    private val url = savedStateHandle.getOrThrow<String>(URL_KEY)

    private val _transakBrowserPreviewFlow = MutableStateFlow(
        transakBrowserPreviewUseCase.getInitialStatePreview(title, url)
    )
    val transakBrowserPreviewFlow: StateFlow<TransakBrowserPreview>
        get() = _transakBrowserPreviewFlow

    fun reloadPage() {
        clearLastError()
        viewModelScope.launch {
            _transakBrowserPreviewFlow
                .emit(transakBrowserPreviewUseCase.getInitialStatePreview(title, url))
        }
    }

    fun onHomeNavButtonClicked() {
        viewModelScope.launch {
            _transakBrowserPreviewFlow
                .emit(transakBrowserPreviewUseCase.requestLoadHomepage(_transakBrowserPreviewFlow.value, title, url))
        }
    }

    fun onPreviousNavButtonClicked() {
        viewModelScope.launch {
            _transakBrowserPreviewFlow
                .emit(transakBrowserPreviewUseCase.onPreviousNavButtonClicked(_transakBrowserPreviewFlow.value))
        }
    }

    fun onNextNavButtonClicked() {
        viewModelScope.launch {
            _transakBrowserPreviewFlow
                .emit(transakBrowserPreviewUseCase.onNextNavButtonClicked(_transakBrowserPreviewFlow.value))
        }
    }

    override fun onPageFinished(title: String?, url: String?) {
        viewModelScope.launch {
            _transakBrowserPreviewFlow
                .emit(
                    transakBrowserPreviewUseCase.onPageFinished(
                        previousState = _transakBrowserPreviewFlow.value,
                        title = title,
                        url = url
                    )
                )
        }
    }

    override fun onError() {
        viewModelScope.launch {
            _transakBrowserPreviewFlow
                .emit(transakBrowserPreviewUseCase.onError(_transakBrowserPreviewFlow.value))
        }
    }

    override fun onHttpError() {
        viewModelScope.launch {
            _transakBrowserPreviewFlow
                .emit(transakBrowserPreviewUseCase.onHttpError(_transakBrowserPreviewFlow.value))
        }
    }

    override fun onPageUrlChanged() {
        viewModelScope.launch {
            _transakBrowserPreviewFlow
                .emit(transakBrowserPreviewUseCase.onPageUrlChanged(_transakBrowserPreviewFlow.value))
        }
    }

    companion object {
        private const val TITLE_KEY = "title"
        private const val URL_KEY = "url"
    }
}
