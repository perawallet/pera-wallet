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

package com.algorand.android.modules.dapp.bidali.ui.intro

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.dapp.bidali.ui.intro.model.BidaliIntroPreview
import com.algorand.android.modules.dapp.bidali.ui.intro.usecase.BidaliIntroPreviewUseCase
import com.algorand.android.utils.getOrElse
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

@HiltViewModel
class BidaliIntroViewModel @Inject constructor(
    private val bidaliIntroPreviewUseCase: BidaliIntroPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    val accountAddress = savedStateHandle.getOrElse<String?>(ACCOUNT_ADDRESS_KEY, null)

    private val _bidaliIntroPreviewFlow = MutableStateFlow(
        bidaliIntroPreviewUseCase.getInitialStatePreview()
    )
    val bidaliIntroPreviewFlow: StateFlow<BidaliIntroPreview>
        get() = _bidaliIntroPreviewFlow

    fun onBuyGiftCardsButtonClick() {
        updatePreviewWithNextNavigation(accountAddress)
    }

    private fun updatePreviewWithNextNavigation(accountAddress: String?) {
        viewModelScope.launchIO {
            _bidaliIntroPreviewFlow.emit(
                bidaliIntroPreviewUseCase.getNavigateToNextScreenUpdatedPreview(
                    previousState = _bidaliIntroPreviewFlow.value,
                    accountAddress = accountAddress
                )
            )
        }
    }

    companion object {
        private const val ACCOUNT_ADDRESS_KEY = "accountAddress"
    }
}
