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

package com.algorand.android.modules.onboarding.recoverypassphrase.rekeyedaccountselection.selection.ui.mapper

import com.algorand.android.models.AccountCreation
import com.algorand.android.modules.basefoundaccount.selection.ui.model.BaseFoundAccountSelectionItem
import com.algorand.android.modules.onboarding.recoverypassphrase.rekeyedaccountselection.selection.ui.model.RekeyedAccountSelectionPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class RekeyedAccountSelectionPreviewMapper @Inject constructor() {

    fun mapToRekeyedAccountSelectionPreview(
        isLoading: Boolean,
        foundAccountSelectionListItem: List<BaseFoundAccountSelectionItem>,
        primaryButtonTextResId: Int?,
        secondaryButtonTextResId: Int?,
        isPrimaryButtonEnable: Boolean,
        navToNameRegistrationEvent: Event<AccountCreation>? = null,
        showAccountCountExceedErrorEvent: Event<Unit>? = null
    ): RekeyedAccountSelectionPreview {
        return RekeyedAccountSelectionPreview(
            isLoading = isLoading,
            foundAccountSelectionListItem = foundAccountSelectionListItem,
            primaryButtonTextResId = primaryButtonTextResId,
            secondaryButtonTextResId = secondaryButtonTextResId,
            isPrimaryButtonEnable = isPrimaryButtonEnable,
            navToNameRegistrationEvent = navToNameRegistrationEvent,
            showAccountCountExceedErrorEvent = showAccountCountExceedErrorEvent
        )
    }
}
