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

import androidx.annotation.PluralsRes
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.utils.AccountDisplayName

sealed class BaseWalletConnectConnectionItem : RecyclerListItem {

    enum class ItemType {
        DAPP_INFO_ITEM,
        TITLE_ITEM,
        ACCOUNT_ITEM,
        REQUESTED_PERMISSION_ITEM,
        NETWORK_ITEM,
        EVENT_ITEM
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

    data class TitleItem(
        @PluralsRes val titleTextResId: Int,
        val memberCount: Int
    ) : BaseWalletConnectConnectionItem() {

        override val itemType: ItemType
            get() = ItemType.TITLE_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && titleTextResId == other.titleTextResId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is TitleItem && this == other
        }
    }

    data class AccountItem(
        val accountAddress: String,
        val accountIconDrawablePreview: AccountIconDrawablePreview,
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

    data class NetworkItem(
        val networkCount: Int,
        val networkList: List<WalletConnectConnectionNetworkItem>,
    ) : BaseWalletConnectConnectionItem() {

        override val itemType: ItemType
            get() = ItemType.NETWORK_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is NetworkItem && networkList == other.networkList
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is NetworkItem && this == other
        }
    }

    data class EventItem(
        val eventCount: Int,
        val eventList: List<String>
    ) : BaseWalletConnectConnectionItem() {

        override val itemType: ItemType
            get() = ItemType.EVENT_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is EventItem && eventList == other.eventList
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is EventItem && this == other
        }
    }

    companion object {
        val excludedItemFromDivider = listOf(
            ItemType.DAPP_INFO_ITEM.ordinal,
            ItemType.TITLE_ITEM.ordinal,
            ItemType.EVENT_ITEM.ordinal,
            ItemType.NETWORK_ITEM.ordinal
        )
    }
}
