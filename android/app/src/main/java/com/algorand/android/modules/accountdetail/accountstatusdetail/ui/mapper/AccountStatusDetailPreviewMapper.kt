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

package com.algorand.android.modules.accountdetail.accountstatusdetail.ui.mapper

import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.modules.accountdetail.accountstatusdetail.ui.model.AccountStatusDetailPreview
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.Event
import javax.inject.Inject

class AccountStatusDetailPreviewMapper @Inject constructor() {

    @SuppressWarnings("LongParameterList")
    fun mapToAccountStatusDetailPreview(
        titleString: String,
        accountOriginalTypeDisplayName: AccountDisplayName,
        accountOriginalTypeIconDrawablePreview: AccountIconDrawablePreview,
        accountOriginalActionButton: AccountAssetItemButtonState,
        authAccountDisplayName: AccountDisplayName?,
        authAccountIconDrawablePreview: AccountIconDrawablePreview?,
        authAccountActionButton: AccountAssetItemButtonState?,
        accountTypeDrawablePreview: AccountIconDrawablePreview,
        accountTypeString: String,
        descriptionAnnotatedString: AnnotatedString,
        isRekeyToLedgerAccountAvailable: Boolean,
        isRekeyToStandardAccountAvailable: Boolean,
        copyAccountAddressToClipboardEvent: Event<Unit>? = null,
        navToUndoRekeyNavigationEvent: Event<Unit>? = null
    ): AccountStatusDetailPreview {
        return AccountStatusDetailPreview(
            titleString = titleString,
            accountOriginalTypeDisplayName = accountOriginalTypeDisplayName,
            accountOriginalTypeIconDrawablePreview = accountOriginalTypeIconDrawablePreview,
            accountOriginalActionButton = accountOriginalActionButton,
            authAccountDisplayName = authAccountDisplayName,
            authAccountIconDrawablePreview = authAccountIconDrawablePreview,
            authAccountActionButton = authAccountActionButton,
            accountTypeDrawablePreview = accountTypeDrawablePreview,
            accountTypeString = accountTypeString,
            descriptionAnnotatedString = descriptionAnnotatedString,
            isRekeyToLedgerAccountVisible = isRekeyToLedgerAccountAvailable,
            isRekeyToStandardAccountVisible = isRekeyToStandardAccountAvailable,
            copyAccountAddressToClipboardEvent = copyAccountAddressToClipboardEvent,
            navToUndoRekeyNavigationEvent = navToUndoRekeyNavigationEvent
        )
    }
}
