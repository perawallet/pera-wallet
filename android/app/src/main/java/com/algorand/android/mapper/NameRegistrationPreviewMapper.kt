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

package com.algorand.android.mapper

import com.algorand.android.models.AccountCreation
import com.algorand.android.models.ui.NameRegistrationPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class NameRegistrationPreviewMapper @Inject constructor() {

    fun mapToInitialPreview(): NameRegistrationPreview {
        return NameRegistrationPreview(
            accountAlreadyExistsEvent = null,
            updateWatchAccountEvent = null,
            createAccountEvent = null,
            handleNextNavigationEvent = null
        )
    }

    fun mapToCreateAccountPreview(accountCreation: AccountCreation): NameRegistrationPreview {
        return NameRegistrationPreview(
            accountAlreadyExistsEvent = null,
            updateWatchAccountEvent = null,
            createAccountEvent = Event(accountCreation),
            handleNextNavigationEvent = Event(Unit)
        )
    }

    fun mapToUpdateWatchAccountPreview(accountCreation: AccountCreation): NameRegistrationPreview {
        return NameRegistrationPreview(
            accountAlreadyExistsEvent = null,
            updateWatchAccountEvent = Event(accountCreation),
            createAccountEvent = null,
            handleNextNavigationEvent = null
        )
    }

    fun mapToAccountAlreadyExistsPreview(): NameRegistrationPreview {
        return NameRegistrationPreview(
            accountAlreadyExistsEvent = Event(Unit),
            updateWatchAccountEvent = null,
            createAccountEvent = null,
            handleNextNavigationEvent = null
        )
    }

    fun mapToWatchAccountUpdatedPreview(): NameRegistrationPreview {
        return NameRegistrationPreview(
            accountAlreadyExistsEvent = null,
            updateWatchAccountEvent = null,
            createAccountEvent = null,
            handleNextNavigationEvent = Event(Unit)
        )
    }
}
