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

package com.algorand.android.modules.registration.watchaccount.ui.model

import androidx.annotation.StringRes
import com.algorand.android.models.AccountCreation
import com.algorand.android.utils.Event

data class WatchAccountRegistrationPreview(
    val pasteableAccounts: List<BasePasteableWatchAccountItem>,
    val isActionButtonEnabled: Boolean,
    @StringRes val errorMessageResId: Int?,
    val showAccountAlreadyExistErrorEvent: Event<Unit>?,
    val showAccountIsNotValidErrorEvent: Event<Unit>?,
    val navToNameRegistrationEvent: Event<AccountCreation>?
)
