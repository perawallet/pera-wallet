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

package com.algorand.android.discover.detail.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.discover.common.ui.BaseDiscoverViewModel
import com.algorand.android.discover.detail.ui.model.DiscoverDetailPreview
import com.algorand.android.discover.detail.ui.usecase.DiscoverDetailPreviewUseCase
import com.algorand.android.discover.home.domain.model.TokenDetailInfo
import com.algorand.android.modules.currency.domain.usecase.CurrencyUseCase
import com.algorand.android.utils.getOrThrow
import com.algorand.android.utils.preference.ThemePreference
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class DiscoverDetailViewModel @Inject constructor(
    private val discoverDetailPreviewUseCase: DiscoverDetailPreviewUseCase,
    private val currencyUseCase: CurrencyUseCase,
    savedStateHandle: SavedStateHandle
) : BaseDiscoverViewModel() {

    private val tokenDetail = savedStateHandle.getOrThrow<TokenDetailInfo>(TOKEN_DETAIL_KEY)

    private val _discoverDetailPreviewFlow = MutableStateFlow(
        discoverDetailPreviewUseCase.getInitialStatePreview(tokenDetail)
    )
    val discoverDetailPreviewFlow: StateFlow<DiscoverDetailPreview>
        get() = _discoverDetailPreviewFlow

    fun reloadPage() {
        clearLastError()
        viewModelScope.launch {
            _discoverDetailPreviewFlow
                .emit(discoverDetailPreviewUseCase.getInitialStatePreview(tokenDetail))
        }
    }

    fun getPrimaryCurrencyId(): String {
        return currencyUseCase.getPrimaryCurrencyId()
    }

    override fun onPageRequestedShouldOverrideUrlLoading(url: String): Boolean {
        viewModelScope.launch {
            _discoverDetailPreviewFlow
                .emit(
                    discoverDetailPreviewUseCase.onPageRequestedShouldOverrideUrlLoading(
                        previousState = _discoverDetailPreviewFlow.value,
                        url = url
                    )
                )
        }
        return true
    }

    override fun onPageFinished(title: String?, url: String?) {
        viewModelScope.launch {
            _discoverDetailPreviewFlow
                .emit(discoverDetailPreviewUseCase.onPageFinished(_discoverDetailPreviewFlow.value))
        }
    }

    override fun onError() {
        viewModelScope.launch {
            _discoverDetailPreviewFlow
                .emit(discoverDetailPreviewUseCase.onError(_discoverDetailPreviewFlow.value))
        }
    }

    override fun onHttpError() {
        viewModelScope.launch {
            _discoverDetailPreviewFlow
                .emit(discoverDetailPreviewUseCase.onHttpError(_discoverDetailPreviewFlow.value))
        }
    }

    fun handleTokenDetailActionButtonClick(jsonEncodedPayload: String) {
        viewModelScope.launch {
            discoverDetailPreviewUseCase.logTokenDetailActionButtonClick(jsonEncodedPayload)
            _discoverDetailPreviewFlow
                .emit(
                    discoverDetailPreviewUseCase.handleTokenDetailActionButtonClick(
                        jsonEncodedPayload,
                        _discoverDetailPreviewFlow.value
                    )
                )
        }
    }

    fun getRedirectUrlFromJson(openSystemBrowserRequestJson: String): String? {
        return discoverDetailPreviewUseCase.getOpenSystemBrowserRequestFromJson(openSystemBrowserRequestJson)?.url
    }

    fun getDeviceId() {
        viewModelScope.launch {
            val webView = getWebView()
            webView?.url?.let { webViewUrl ->
                val sendDeviceIdJSFunction = discoverDetailPreviewUseCase.getSendDeviceIdJSFunctionOrNull(webViewUrl)
                if (sendDeviceIdJSFunction != null) {
                    webView.evaluateJavascript(sendDeviceIdJSFunction, null)
                }
            }
        }
    }

    override fun getDiscoverThemePreference(): ThemePreference {
        return discoverDetailPreviewFlow.value.themePreference
    }

    companion object {
        private const val TOKEN_DETAIL_KEY = "tokenDetail"
    }
}
