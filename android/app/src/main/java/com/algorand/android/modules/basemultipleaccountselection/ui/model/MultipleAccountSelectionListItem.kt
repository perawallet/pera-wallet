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

package com.algorand.android.modules.basemultipleaccountselection.ui.model

import androidx.annotation.PluralsRes
import androidx.annotation.StringRes
import com.algorand.android.customviews.TriStatesCheckBox
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.utils.AccountDisplayName

abstract class MultipleAccountSelectionListItem : RecyclerListItem {

    enum class ItemType {
        TITLE_ITEM,
        DESCRIPTION_ITEM,
        ACCOUNT_HEADER_ITEM,
        ACCOUNT_ITEM
    }

    abstract val itemType: ItemType

    data class TitleItem(
        @StringRes val textResId: Int
    ) : MultipleAccountSelectionListItem() {

        override val itemType
            get() = ItemType.TITLE_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && textResId == other.textResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && other == this
        }
    }

    data class DescriptionItem(
        val annotatedString: AnnotatedString
    ) : MultipleAccountSelectionListItem() {

        override val itemType
            get() = ItemType.DESCRIPTION_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is DescriptionItem && annotatedString == other.annotatedString
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is DescriptionItem && other == this
        }
    }

    data class AccountHeaderItem(
        @PluralsRes val titleRes: Int,
        val accountCount: Int,
        val checkboxState: TriStatesCheckBox.CheckBoxState,
    ) : MultipleAccountSelectionListItem() {

        override val itemType
            get() = ItemType.ACCOUNT_HEADER_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountHeaderItem && titleRes == other.titleRes
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountHeaderItem && other == this
        }
    }

    data class AccountItem(
        val accountDisplayName: AccountDisplayName,
        val accountIconResource: AccountIconResource,
        val accountViewButtonState: AccountAssetItemButtonState
    ) : MultipleAccountSelectionListItem() {

        override val itemType
            get() = ItemType.ACCOUNT_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem &&
                accountDisplayName.getRawAccountAddress() == other.accountDisplayName.getRawAccountAddress()
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem && other == this
        }
    }
}
