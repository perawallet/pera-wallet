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

package com.algorand.android.ui.register.registerintro

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.RegisterIntroPreview
import com.algorand.android.usecase.RegisterIntroPreviewUseCase
import com.algorand.android.usecase.RegistrationUseCase
import com.algorand.android.utils.getOrElse
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@HiltViewModel
class RegisterIntroViewModel @Inject constructor(
    private val registerIntroPreviewUseCase: RegisterIntroPreviewUseCase,
    private val registrationUseCase: RegistrationUseCase,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val accountAddress: String? = savedStateHandle.getOrElse(ACCOUNT_ADDRESS_KEY, null)
    private val isShowingCloseButton = savedStateHandle.getOrElse(IS_SHOWING_CLOSE_BUTTON_KEY, false)

    private val _registerIntroPreviewFlow = MutableStateFlow<RegisterIntroPreview?>(null)
    val registerIntroPreviewFlow: StateFlow<RegisterIntroPreview?> = _registerIntroPreviewFlow

    init {
        getRegisterIntroPreview()
    }

    fun setRegisterSkip() {
        registrationUseCase.setRegistrationSkipPreferenceAsSkipped()
    }

    fun getAccountAddress(): String? = accountAddress

    private fun getRegisterIntroPreview() {
        viewModelScope.launch {
            registerIntroPreviewUseCase.getRegisterIntroPreview(isShowingCloseButton).collectLatest {
                _registerIntroPreviewFlow.emit(it)
            }
        }
    }

    fun logOnboardingWelcomeAccountCreateClickEvent() {
        viewModelScope.launch {
            registerIntroPreviewUseCase.logOnboardingCreateNewAccountClickEvent()
        }
    }

    fun logOnboardingWelcomeAccountRecoverClickEvent() {
        viewModelScope.launch {
            registerIntroPreviewUseCase.logOnboardingWelcomeAccountRecoverClickEvent()
        }
    }

    fun logOnboardingCreateAccountSkipClickEvent() {
        viewModelScope.launch {
            registerIntroPreviewUseCase.logOnboardingCreateAccountSkipClickEvent()
        }
    }

    fun logOnboardingCreateWatchAccountClickEvent() {
        viewModelScope.launch {
            registerIntroPreviewUseCase.logOnboardingCreateWatchAccountClickEvent()
        }
    }

    companion object {
        private const val IS_SHOWING_CLOSE_BUTTON_KEY = "isShowingCloseButton"
        private const val ACCOUNT_ADDRESS_KEY = "accountAddress"
    }
}
