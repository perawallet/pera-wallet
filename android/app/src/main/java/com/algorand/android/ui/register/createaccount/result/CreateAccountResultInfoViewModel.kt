/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.ui.register.createaccount.result

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.tracking.onboarding.register.createaccountresultinfo.CreateAccountResultInfoFragmentEventTracker
import com.algorand.android.usecase.CreateAccountResultInfoUseCase
import com.algorand.android.usecase.LockPreferencesUseCase
import kotlinx.coroutines.launch

class CreateAccountResultInfoViewModel @ViewModelInject constructor(
    createAccountResultInfoUseCase: CreateAccountResultInfoUseCase,
    private val lockPreferencesUseCase: LockPreferencesUseCase,
    private val createAccountResultInfoFragmentEventTracker: CreateAccountResultInfoFragmentEventTracker
) : ViewModel() {

    private val createAccountResultInfoPreview = createAccountResultInfoUseCase.getCreateAccountResultInfoPreview()

    fun shouldForceLockNavigation(): Boolean {
        return lockPreferencesUseCase.shouldNavigateLockNavigation()
    }

    fun getPreviewTitle(): Int {
        return createAccountResultInfoPreview.titleTextRes
    }

    fun getPreviewDescription(): Int {
        return createAccountResultInfoPreview.descriptionTextRes
    }

    fun getPreviewFirstButtonText(): Int {
        return createAccountResultInfoPreview.firstButtonTextRes
    }

    fun getPreviewSecondButtonText(): Int {
        return createAccountResultInfoPreview.secondButtonTextRes
    }

    fun logOnboardingBuyAlgoClickEvent() {
        viewModelScope.launch {
            createAccountResultInfoFragmentEventTracker.logOnboardingAccountVerifiedBuyAlgoEvent()
        }
    }

    fun logOnboardingStartUsingPeraClickEvent() {
        viewModelScope.launch {
            createAccountResultInfoFragmentEventTracker.logOnboardingAccountVerifiedStartPeraEvent()
        }
    }
}
