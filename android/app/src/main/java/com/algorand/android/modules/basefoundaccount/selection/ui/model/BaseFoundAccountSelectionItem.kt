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

package com.algorand.android.modules.basefoundaccount.selection.ui.model

import com.algorand.android.models.PluralAnnotatedString
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.utils.AccountDisplayName

sealed class BaseFoundAccountSelectionItem : RecyclerListItem {

    enum class ItemType {
        ICON_ITEM,
        TITLE_ITEM,
        DESCRIPTION_ITEM,
        ACCOUNT_ITEM
    }

    abstract val itemType: ItemType

    data class IconItem(
        val iconResId: Int
    ) : BaseFoundAccountSelectionItem() {

        override val itemType: ItemType
            get() = ItemType.ICON_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is IconItem && iconResId == other.iconResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is IconItem && this == other
        }
    }

    data class TitleItem(
        val titlePluralAnnotatedString: PluralAnnotatedString
    ) : BaseFoundAccountSelectionItem() {

        override val itemType: ItemType
            get() = ItemType.TITLE_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && titlePluralAnnotatedString == other.titlePluralAnnotatedString
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && this == other
        }
    }

    data class DescriptionItem(
        val descriptionPluralAnnotatedString: PluralAnnotatedString
    ) : BaseFoundAccountSelectionItem() {

        override val itemType: ItemType
            get() = ItemType.DESCRIPTION_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is DescriptionItem &&
                descriptionPluralAnnotatedString == other.descriptionPluralAnnotatedString
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is DescriptionItem && this == other
        }
    }

    data class AccountItem(
        val accountIconDrawablePreview: AccountIconDrawablePreview,
        val accountDisplayName: AccountDisplayName,
        val selectorDrawableRes: Int,
        val isSelected: Boolean
    ) : BaseFoundAccountSelectionItem() {

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
