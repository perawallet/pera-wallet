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

package com.algorand.android.modules.banner.ui

import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.perawebview.ui.BasePeraWebViewViewModel
import com.algorand.android.modules.banner.ui.model.BannerPreview
import com.algorand.android.modules.banner.ui.usecase.BannerPreviewUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class BannerViewModel @Inject constructor(
    private val bannerPreviewUseCase: BannerPreviewUseCase
) : BasePeraWebViewViewModel() {

    private val _bannerPreviewFlow = MutableStateFlow(bannerPreviewUseCase.getInitialStatePreview())
    val bannerPreviewFlow: StateFlow<BannerPreview>
        get() = _bannerPreviewFlow

    fun reloadPage() {
        clearLastError()
        viewModelScope.launch {
            _bannerPreviewFlow.emit(bannerPreviewUseCase.getInitialStatePreview())
        }
    }

    fun onHomeNavButtonClicked() {
        viewModelScope.launch {
            _bannerPreviewFlow.emit(
                bannerPreviewUseCase.requestLoadHomepage(_bannerPreviewFlow.value)
            )
        }
    }

    fun onPreviousNavButtonClicked() {
        viewModelScope.launch {
            _bannerPreviewFlow.emit(
                bannerPreviewUseCase.onPreviousNavButtonClicked(_bannerPreviewFlow.value)
            )
        }
    }

    fun onNextNavButtonClicked() {
        viewModelScope.launch {
            _bannerPreviewFlow.emit(
                bannerPreviewUseCase.onNextNavButtonClicked(_bannerPreviewFlow.value)
            )
        }
    }

    override fun onPageRequestedShouldOverrideUrlLoading(url: String): Boolean {
        viewModelScope.launch {
            _bannerPreviewFlow.emit(
                bannerPreviewUseCase.onPageRequested(_bannerPreviewFlow.value)
            )
        }
        return false
    }

    override fun onPageFinished(title: String?, url: String?) {
        viewModelScope.launch {
            _bannerPreviewFlow.emit(
                bannerPreviewUseCase.onPageFinished(_bannerPreviewFlow.value)
            )
        }
    }

    override fun onError() {
        viewModelScope.launch {
            _bannerPreviewFlow.emit(
                bannerPreviewUseCase.onError(_bannerPreviewFlow.value)
            )
        }
    }

    override fun onHttpError() {
        viewModelScope.launch {
            _bannerPreviewFlow.emit(
                bannerPreviewUseCase.onHttpError(_bannerPreviewFlow.value)
            )
        }
    }

    override fun onPageUrlChanged() {
        viewModelScope.launch {
            _bannerPreviewFlow.emit(
                bannerPreviewUseCase.onPageUrlChanged(_bannerPreviewFlow.value)
            )
        }
    }
}
