/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.usecase

import com.algorand.android.core.AccountManager
import com.algorand.android.core.BaseUseCase
import com.algorand.android.models.Account
import com.algorand.android.modules.fetchnameservices.domain.usecase.UpdateLocalAccountNameServicesUseCase
import com.algorand.android.utils.analytics.CreationType
import com.algorand.android.utils.analytics.logRegisterEvent
import com.google.firebase.analytics.FirebaseAnalytics
import javax.inject.Inject

class AccountAdditionUseCase @Inject constructor(
    private val accountManager: AccountManager,
    private val firebaseAnalytics: FirebaseAnalytics,
    private val registrationUseCase: RegistrationUseCase,
    private val updateLocalAccountNameServicesUseCase: UpdateLocalAccountNameServicesUseCase
) : BaseUseCase() {

    suspend fun addNewAccount(tempAccount: Account, creationType: CreationType?) {
        if (tempAccount.isRegistrationCompleted()) {
            firebaseAnalytics.logRegisterEvent(creationType)
            accountManager.addNewAccount(tempAccount)
            updateLocalAccountNameServicesUseCase.invoke()
            if (!registrationUseCase.getRegistrationSkipped()) {
                registrationUseCase.setRegistrationSkipPreferenceAsSkipped()
            }
        }
    }
}
