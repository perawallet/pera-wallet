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

package com.algorand.android.discover.urlviewer.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.discover.common.ui.BaseDiscoverViewModel
import com.algorand.android.discover.common.ui.model.DappFavoriteElement
import com.algorand.android.discover.urlviewer.ui.model.DiscoverUrlViewerPreview
import com.algorand.android.discover.urlviewer.ui.usecase.DiscoverUrlViewerPreviewUseCase
import com.algorand.android.discover.urlviewer.ui.usecase.DiscoverUrlViewerUseCase
import com.algorand.android.utils.getOrThrow
import com.algorand.android.utils.preference.ThemePreference
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class DiscoverUrlViewerViewModel @Inject constructor(
    private val discoverUrlViewerPreviewUseCase: DiscoverUrlViewerPreviewUseCase,
    private val discoverUrlViewerUseCase: DiscoverUrlViewerUseCase,
    savedStateHandle: SavedStateHandle
) : BaseDiscoverViewModel() {

    private val url = savedStateHandle.getOrThrow<String>(URL_KEY)

    private val _discoverUrlViewerPreviewFlow = MutableStateFlow(
        discoverUrlViewerPreviewUseCase.getInitialStatePreview(url)
    )
    val discoverUrlViewerPreviewFlow: StateFlow<DiscoverUrlViewerPreview>
        get() = _discoverUrlViewerPreviewFlow

    override fun onPageRequestedShouldOverrideUrlLoading(url: String): Boolean {
        viewModelScope.launch {
            _discoverUrlViewerPreviewFlow
                .emit(
                    discoverUrlViewerPreviewUseCase
                    .onPageRequestedShouldOverrideUrlLoading(_discoverUrlViewerPreviewFlow.value)
                )
        }
        return false
    }

    override fun onPageFinished(title: String?, url: String?) {
        viewModelScope.launch {
            _discoverUrlViewerPreviewFlow
                .emit(
                    discoverUrlViewerPreviewUseCase.onPageFinished(
                        _discoverUrlViewerPreviewFlow.value,
                        url
                    )
                )
        }
    }

    override fun onError() {
        viewModelScope.launch {
            _discoverUrlViewerPreviewFlow
                .emit(discoverUrlViewerPreviewUseCase.onError(_discoverUrlViewerPreviewFlow.value))
        }
    }

    override fun onHttpError() {
        viewModelScope.launch {
            _discoverUrlViewerPreviewFlow
                .emit(discoverUrlViewerPreviewUseCase.onHttpError(_discoverUrlViewerPreviewFlow.value))
        }
    }

    override fun getDiscoverThemePreference(): ThemePreference {
        return _discoverUrlViewerPreviewFlow.value.themePreference
    }

    fun pushDappViewerScreen(jsonEncodedPayload: String) {
        viewModelScope.launch {
            _discoverUrlViewerPreviewFlow
                .emit(
                    discoverUrlViewerPreviewUseCase.pushDappViewerScreen(
                        jsonEncodedPayload,
                        _discoverUrlViewerPreviewFlow.value
                    )
                )
        }
    }

    fun onFavoritesUpdate(favorite: DappFavoriteElement) {
        getWebView()?.let { webView ->
            webView.evaluateJavascript(
                discoverUrlViewerUseCase.getAddToFavoriteJSFunction(favorite),
                null
            )
            saveWebView(webView)
        }
    }

    fun pushNewScreen(jsonEncodedPayload: String) {
        viewModelScope.launch {
            _discoverUrlViewerPreviewFlow
                .emit(
                    discoverUrlViewerPreviewUseCase.pushNewScreen(
                        jsonEncodedPayload,
                        _discoverUrlViewerPreviewFlow.value
                    )
                )
        }
    }

    fun getPrimaryCurrencyId(): String {
        return discoverUrlViewerUseCase.getPrimaryCurrencyId()
    }

    companion object {
        private const val URL_KEY = "webUrl"
    }
}
