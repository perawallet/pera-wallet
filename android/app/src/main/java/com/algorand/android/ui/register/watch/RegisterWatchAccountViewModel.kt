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

package com.algorand.android.ui.register.watch

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.AccountManager
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.tracking.onboarding.register.OnboardingWatchAccountVerifyEventTracker
import com.algorand.android.utils.getOrElse
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class RegisterWatchAccountViewModel @ViewModelInject constructor(
    private val accountManager: AccountManager,
    @Assisted private val savedStateHandle: SavedStateHandle,
    private val onboardingWatchAccountVerifyEventTracker: OnboardingWatchAccountVerifyEventTracker
) : BaseViewModel() {

    private val accountAddress: String? = savedStateHandle.getOrElse(ACCOUNT_ADDRESS_KEY, null)
    private val _copiedMessageFlow = MutableStateFlow<String?>(null)
    val copiedMessageFlow: StateFlow<String?> = _copiedMessageFlow

    fun setCopiedMessage(newMessage: String) {
        viewModelScope.launch {
            _copiedMessageFlow.emit(newMessage)
        }
    }

    fun getCopiedMessage(): String {
        return copiedMessageFlow.value.orEmpty()
    }

    fun getAccountAddress(): String? = accountAddress

    fun isThereAccountWithAddress(address: String): Boolean {
        return accountManager.getAccount(address) != null
    }

    fun logOnboardingVerifyWatchAccountClickEvent() {
        viewModelScope.launch {
            onboardingWatchAccountVerifyEventTracker.logOnboardingWatchAccountVerifyEvent()
        }
    }

    companion object {
        private const val ACCOUNT_ADDRESS_KEY = "accountAddress"
    }
}
