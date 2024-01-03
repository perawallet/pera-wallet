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

package com.algorand.android.modules.dapp.bidali.ui.browser

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.TransactionData
import com.algorand.android.modules.dapp.bidali.BIDALI_FAILED_TRANSACTION_JAVASCRIPT
import com.algorand.android.modules.dapp.bidali.BIDALI_SUCCESSFUL_TRANSACTION_JAVASCRIPT
import com.algorand.android.modules.dapp.bidali.domain.model.BidaliPaymentRequestDTO
import com.algorand.android.modules.dapp.bidali.ui.browser.model.BidaliBrowserPreview
import com.algorand.android.modules.dapp.bidali.ui.browser.usecase.BidaliBrowserPreviewUseCase
import com.algorand.android.modules.dapp.bidali.ui.browser.usecase.BidaliBrowserUseCase
import com.algorand.android.modules.perawebview.ui.BasePeraWebViewViewModel
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@HiltViewModel
class BidaliBrowserViewModel @Inject constructor(
    private val bidaliBrowserPreviewUseCase: BidaliBrowserPreviewUseCase,
    private val bidaliBrowserUseCase: BidaliBrowserUseCase,
    savedStateHandle: SavedStateHandle
) : BasePeraWebViewViewModel() {

    private val accountAddress = savedStateHandle.getOrThrow<String>(ACCOUNT_ADDRESS_KEY)
    private val title = savedStateHandle.getOrThrow<String>(TITLE_KEY)
    private val url = savedStateHandle.getOrThrow<String>(URL_KEY)

    private val _bidaliBrowserPreviewFlow = MutableStateFlow(
        bidaliBrowserPreviewUseCase.getInitialStatePreview(title, url)
    )
    val bidaliBrowserPreviewFlow: StateFlow<BidaliBrowserPreview>
        get() = _bidaliBrowserPreviewFlow

    fun reloadPage() {
        clearLastError()
        viewModelScope.launch {
            _bidaliBrowserPreviewFlow
                .emit(bidaliBrowserPreviewUseCase.getInitialStatePreview(title, url))
        }
    }

    fun onHomeNavButtonClicked() {
        viewModelScope.launch {
            _bidaliBrowserPreviewFlow
                .emit(bidaliBrowserPreviewUseCase.requestLoadHomepage(_bidaliBrowserPreviewFlow.value, title, url))
        }
    }

    fun onPreviousNavButtonClicked() {
        viewModelScope.launch {
            _bidaliBrowserPreviewFlow
                .emit(bidaliBrowserPreviewUseCase.onPreviousNavButtonClicked(_bidaliBrowserPreviewFlow.value))
        }
    }

    fun onNextNavButtonClicked() {
        viewModelScope.launch {
            _bidaliBrowserPreviewFlow
                .emit(bidaliBrowserPreviewUseCase.onNextNavButtonClicked(_bidaliBrowserPreviewFlow.value))
        }
    }

    fun generateBidaliJavascript(): String {
        return bidaliBrowserUseCase.generateBidaliJavascript(accountAddress)
    }

    fun generateTransactionSuccessfulJavascript(): String {
        return BIDALI_SUCCESSFUL_TRANSACTION_JAVASCRIPT
    }

    fun generateUpdatedBalancesJavascript() {
        viewModelScope.launch {
            bidaliBrowserPreviewUseCase
                .generateUpdatedBalancesJavascript(_bidaliBrowserPreviewFlow.value, accountAddress, viewModelScope)
                .collectLatest {
                    _bidaliBrowserPreviewFlow
                        .emit(it)
            }
        }
    }

    fun generateTransactionFailedJavascript(): String {
        return BIDALI_FAILED_TRANSACTION_JAVASCRIPT
    }

    fun getTransactionDataFromPaymentRequest(paymentRequest: BidaliPaymentRequestDTO): TransactionData.Send? {
        return bidaliBrowserUseCase.getTransactionDataFromPaymentRequest(paymentRequest, accountAddress)
    }

    override fun onPageStarted() {
        viewModelScope.launch {
            _bidaliBrowserPreviewFlow
                .emit(bidaliBrowserPreviewUseCase.onPageStarted(_bidaliBrowserPreviewFlow.value))
        }
    }

    override fun onPageFinished(title: String?, url: String?) {
        viewModelScope.launch {
            _bidaliBrowserPreviewFlow
                .emit(
                    bidaliBrowserPreviewUseCase.onPageFinished(
                        previousState = _bidaliBrowserPreviewFlow.value,
                        title = title,
                        url = url
                    )
                )
        }
    }

    override fun onError() {
        viewModelScope.launch {
            _bidaliBrowserPreviewFlow
                .emit(bidaliBrowserPreviewUseCase.onError(_bidaliBrowserPreviewFlow.value))
        }
    }

    override fun onHttpError() {
        viewModelScope.launch {
            _bidaliBrowserPreviewFlow
                .emit(bidaliBrowserPreviewUseCase.onHttpError(_bidaliBrowserPreviewFlow.value))
        }
    }

    override fun onPageUrlChanged() {
        viewModelScope.launch {
            _bidaliBrowserPreviewFlow
                .emit(bidaliBrowserPreviewUseCase.onPageUrlChanged(_bidaliBrowserPreviewFlow.value))
        }
    }

    fun onPaymentRequest(data: String) {
        viewModelScope.launch {
            _bidaliBrowserPreviewFlow
                .emit(bidaliBrowserPreviewUseCase.onPaymentRequest(data, _bidaliBrowserPreviewFlow.value))
        }
    }

    fun openUrl(data: String) {
        viewModelScope.launch {
            _bidaliBrowserPreviewFlow
                .emit(bidaliBrowserPreviewUseCase.openUrl(data, _bidaliBrowserPreviewFlow.value))
        }
    }

    companion object {
        private const val ACCOUNT_ADDRESS_KEY = "accountAddress"
        private const val TITLE_KEY = "title"
        private const val URL_KEY = "url"
    }
}
