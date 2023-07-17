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

package com.algorand.android.modules.basesingleaccountselection.ui.model

import androidx.annotation.StringRes
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.utils.AccountDisplayName

sealed class SingleAccountSelectionListItem : RecyclerListItem {

    enum class ItemType {
        ACCOUNT_ITEM,
        TITLE_ITEM,
        DESCRIPTION_ITEM
    }

    abstract val itemType: ItemType

    data class TitleItem(
        @StringRes val textResId: Int
    ) : SingleAccountSelectionListItem() {

        override val itemType: ItemType
            get() = ItemType.TITLE_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && textResId == other.textResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && this == other
        }
    }

    data class DescriptionItem(
        val descriptionAnnotatedString: AnnotatedString
    ) : SingleAccountSelectionListItem() {

        override val itemType: ItemType
            get() = ItemType.DESCRIPTION_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is DescriptionItem && descriptionAnnotatedString == other.descriptionAnnotatedString
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is DescriptionItem && this == other
        }
    }

    data class AccountItem(
        val accountDisplayName: AccountDisplayName,
        val accountIconDrawablePreview: AccountIconDrawablePreview,
        val accountFormattedPrimaryValue: String?,
        val accountFormattedSecondaryValue: String?
    ) : SingleAccountSelectionListItem() {

        override val itemType: ItemType
            get() = ItemType.ACCOUNT_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem &&
                accountDisplayName.getRawAccountAddress() == other.accountDisplayName.getRawAccountAddress()
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem && this == other
        }
    }
}
