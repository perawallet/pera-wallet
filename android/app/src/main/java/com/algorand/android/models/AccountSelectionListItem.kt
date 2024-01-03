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

package com.algorand.android.models

import android.os.Parcelable
import androidx.annotation.DrawableRes
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.modules.baseledgeraccountselection.accountselection.ui.model.SearchType
import com.algorand.android.utils.AccountDisplayName
import kotlinx.parcelize.Parcelize

sealed class AccountSelectionListItem : RecyclerListItem, Parcelable {

    enum class ItemType {
        INSTRUCTION_ITEM,
        ACCOUNT_ITEM
    }

    abstract val itemType: ItemType

    @Parcelize
    data class InstructionItem(
        val accountCount: Int,
        val searchType: SearchType
    ) : AccountSelectionListItem() {

        override val itemType: ItemType
            get() = ItemType.INSTRUCTION_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is InstructionItem && accountCount == other.accountCount
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is InstructionItem && this == other
        }
    }

    @Parcelize
    data class AccountItem(
        val account: Account,
        val accountInformation: AccountInformation,
        val assetInformationList: List<AssetInformation>,
        val accountDisplayName: AccountDisplayName,
        val accountIconDrawablePreview: AccountIconDrawablePreview,
        var isSelected: Boolean = false,
        @DrawableRes val selectorDrawableRes: Int
    ) : AccountSelectionListItem() {

        override val itemType: ItemType
            get() = ItemType.ACCOUNT_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem && account.address == other.account.address && isSelected == other.isSelected
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem && this == other
        }
    }
}
