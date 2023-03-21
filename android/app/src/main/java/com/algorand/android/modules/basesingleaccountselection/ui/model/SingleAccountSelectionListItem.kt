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

import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.utils.AccountDisplayName

sealed class SingleAccountSelectionListItem : RecyclerListItem {

    enum class ItemType {
        ACCOUNT_ITEM
    }

    abstract val itemType: ItemType

    data class AccountItem(
        val accountDisplayName: AccountDisplayName,
        val accountIconResource: AccountIconResource,
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
