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

package com.algorand.android.modules.onboarding.registerwatchaccount.ui.mapper

import androidx.annotation.StringRes
import com.algorand.android.models.AccountCreation
import com.algorand.android.modules.onboarding.registerwatchaccount.ui.model.BasePasteableWatchAccountItem
import com.algorand.android.modules.onboarding.registerwatchaccount.ui.model.WatchAccountRegistrationPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class WatchAccountRegistrationPreviewMapper @Inject constructor() {

    fun mapToWatchAccountRegistrationPreview(
        pasteableAccounts: List<BasePasteableWatchAccountItem>,
        isActionButtonEnabled: Boolean,
        @StringRes errorMessageResId: Int?,
        showAccountAlreadyExistErrorEvent: Event<Unit>? = null,
        showAccountIsNotValidErrorEvent: Event<Unit>? = null,
        navToNameRegistrationEvent: Event<AccountCreation>? = null
    ): WatchAccountRegistrationPreview {
        return WatchAccountRegistrationPreview(
            pasteableAccounts = pasteableAccounts,
            isActionButtonEnabled = isActionButtonEnabled,
            errorMessageResId = errorMessageResId,
            showAccountAlreadyExistErrorEvent = showAccountAlreadyExistErrorEvent,
            showAccountIsNotValidErrorEvent = showAccountIsNotValidErrorEvent,
            navToNameRegistrationEvent = navToNameRegistrationEvent
        )
    }
}
