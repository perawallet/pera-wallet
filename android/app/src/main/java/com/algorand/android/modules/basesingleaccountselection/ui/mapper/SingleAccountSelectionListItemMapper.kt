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

package com.algorand.android.modules.basesingleaccountselection.ui.mapper

import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.modules.basesingleaccountselection.ui.model.SingleAccountSelectionListItem
import com.algorand.android.utils.AccountDisplayName
import javax.inject.Inject

class SingleAccountSelectionListItemMapper @Inject constructor() {

    fun mapToTitleItem(textResId: Int): SingleAccountSelectionListItem.TitleItem {
        return SingleAccountSelectionListItem.TitleItem(textResId)
    }

    fun mapToDescriptionItem(
        descriptionAnnotatedString: AnnotatedString
    ): SingleAccountSelectionListItem.DescriptionItem {
        return SingleAccountSelectionListItem.DescriptionItem(descriptionAnnotatedString)
    }

    fun mapToAccountItem(
        accountDisplayName: AccountDisplayName,
        accountIconDrawablePreview: AccountIconDrawablePreview,
        accountFormattedPrimaryValue: String?,
        accountFormattedSecondaryValue: String?
    ): SingleAccountSelectionListItem.AccountItem {
        return SingleAccountSelectionListItem.AccountItem(
            accountDisplayName = accountDisplayName,
            accountIconDrawablePreview = accountIconDrawablePreview,
            accountFormattedPrimaryValue = accountFormattedPrimaryValue,
            accountFormattedSecondaryValue = accountFormattedSecondaryValue
        )
    }
}
