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

package com.algorand.android.modules.onboarding.registerwatchaccount.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.onboarding.registerwatchaccount.ui.model.WatchAccountRegistrationPreview
import com.algorand.android.modules.onboarding.registerwatchaccount.ui.usecase.WatchAccountRegistrationPreviewUseCase
import com.algorand.android.modules.tracking.onboarding.register.OnboardingWatchAccountVerifyEventTracker
import com.algorand.android.utils.getOrElse
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.launch

@HiltViewModel
class RegisterWatchAccountViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,

    private val onboardingWatchAccountVerifyEventTracker: OnboardingWatchAccountVerifyEventTracker,
    private val watchAccountRegistrationPreviewUseCase: WatchAccountRegistrationPreviewUseCase
) : BaseViewModel() {

    private val accountAddress: String = savedStateHandle.getOrElse(ACCOUNT_ADDRESS_KEY, "")

    private val _watchAccountRegistrationPreviewFlow = MutableStateFlow<WatchAccountRegistrationPreview?>(null)
    val watchAccountRegistrationPreviewFlow: StateFlow<WatchAccountRegistrationPreview?>
        get() = _watchAccountRegistrationPreviewFlow

    private val copiedMessageFlow = MutableStateFlow("")
    private val queryFlow = MutableStateFlow(accountAddress)

    val queriedAccountAddress: String
        get() = queryFlow.value

    private var selectedNfDomainName: String? = null

    init {
        combineLatestCopiedMessageAndQueryFlows()
    }

    fun onCreateAccountClick() {
        val currentPreview = _watchAccountRegistrationPreviewFlow.value ?: return
        viewModelScope.launch {
            val upcomingPreview = watchAccountRegistrationPreviewUseCase.updatePreviewAccordingAccountAddress(
                currentPreview = currentPreview,
                accountAddress = queriedAccountAddress,
                nfDomainName = selectedNfDomainName
            )
            _watchAccountRegistrationPreviewFlow.emit(upcomingPreview)
            logOnboardingVerifyWatchAccountClickEvent()
        }
    }

    fun onNfDomainSelected(nfDomainName: String, nfDomainAddress: String) {
        selectedNfDomainName = nfDomainName
        updateQueryFlow(nfDomainAddress)
    }

    fun onAccountSelected(accountAddress: String) {
        selectedNfDomainName = null
        updateQueryFlow(accountAddress)
    }

    fun updateQueryFlow(query: String) {
        viewModelScope.launch {
            queryFlow.emit(query.trim())
        }
    }

    fun updateCopiedMessageFlow(copiedMessage: String) {
        viewModelScope.launch {
            copiedMessageFlow.emit(copiedMessage.trim())
        }
    }

    private fun combineLatestCopiedMessageAndQueryFlows() {
        viewModelScope.launch {
            combine(copiedMessageFlow, queryFlow) { copiedMessage, query ->
                watchAccountRegistrationPreviewUseCase.initWatchAccountRegistrationPreviewFlow(
                    copiedMessage = copiedMessage,
                    query = query
                ).collectLatest { preview ->
                    _watchAccountRegistrationPreviewFlow.emit(preview)
                }
            }.collect()
        }
    }

    private fun logOnboardingVerifyWatchAccountClickEvent() {
        viewModelScope.launch {
            onboardingWatchAccountVerifyEventTracker.logOnboardingWatchAccountVerifyEvent()
        }
    }

    companion object {
        private const val ACCOUNT_ADDRESS_KEY = "accountAddress"
    }
}
