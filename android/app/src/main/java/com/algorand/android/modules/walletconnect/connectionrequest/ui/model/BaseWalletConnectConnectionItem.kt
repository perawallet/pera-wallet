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

package com.algorand.android.modules.walletconnect.connectionrequest.ui.model

import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.utils.AccountDisplayName

sealed class BaseWalletConnectConnectionItem : RecyclerListItem {

    enum class ItemType {
        DAPP_INFO_ITEM,
        ACCOUNTS_TITLE_ITEM,
        ACCOUNT_ITEM
    }

    abstract val itemType: ItemType

    data class DappInfoItem(
        val name: String,
        val url: String,
        val peerIconUri: String
    ) : BaseWalletConnectConnectionItem() {

        override val itemType: ItemType
            get() = ItemType.DAPP_INFO_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is DappInfoItem && name == other.name
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is DappInfoItem && this == other
        }
    }

    data class AccountsTitleItem(
        val accountCount: Int
    ) : BaseWalletConnectConnectionItem() {

        override val itemType: ItemType
            get() = ItemType.ACCOUNTS_TITLE_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountsTitleItem && accountCount == other.accountCount
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountsTitleItem && this == other
        }
    }

    data class AccountItem(
        val accountAddress: String,
        val accountIconResource: AccountIconResource?,
        val accountDisplayName: AccountDisplayName?,
        val buttonState: AccountAssetItemButtonState,
        var isChecked: Boolean
    ) : BaseWalletConnectConnectionItem() {

        override val itemType: ItemType
            get() = ItemType.ACCOUNT_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem && accountAddress == other.accountAddress
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem && this == other
        }
    }

    companion object {
        val excludedItemFromDivider = listOf(ItemType.DAPP_INFO_ITEM.ordinal, ItemType.ACCOUNTS_TITLE_ITEM.ordinal)
    }
}
