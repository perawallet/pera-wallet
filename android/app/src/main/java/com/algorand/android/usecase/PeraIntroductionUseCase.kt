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

package com.algorand.android.usecase

import com.algorand.android.core.AccountManager
import com.algorand.android.repository.PeraIntroductionRepository
import com.algorand.android.sharedpref.PeraIntroductionLocalSource.Companion.DEFAULT_PERA_INTRODUCTION_PREFERENCE
import javax.inject.Inject

class PeraIntroductionUseCase @Inject constructor(
    private val accountManager: AccountManager,
    private val peraIntroductionRepository: PeraIntroductionRepository
) {

    fun initializePeraIntroductionSharedPref() {
        val introductionSharedPrefValue = peraIntroductionRepository.getPeraIntroductionPreference()
        val hasLocalAccounts = accountManager.getAccounts().isNotEmpty()

        val shouldShowPeraIntroduction = introductionSharedPrefValue == null && hasLocalAccounts
        peraIntroductionRepository.setPeraIntroductionPreference(shouldShowPeraIntroduction)
    }

    fun setPeraIntroductionShowed() {
        peraIntroductionRepository.setPeraIntroductionPreference(shouldShowIntroduction = false)
    }

    fun shouldShowPeraIntroduction(): Boolean {
        return peraIntroductionRepository.getPeraIntroductionPreference(DEFAULT_PERA_INTRODUCTION_PREFERENCE)
    }
}
