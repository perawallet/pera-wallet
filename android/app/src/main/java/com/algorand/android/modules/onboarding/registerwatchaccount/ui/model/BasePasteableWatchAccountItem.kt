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

package com.algorand.android.modules.onboarding.registerwatchaccount.ui.model

import com.algorand.android.models.RecyclerListItem

sealed class BasePasteableWatchAccountItem : RecyclerListItem {

    enum class ItemType {
        ACCOUNT_ADDRESS_ITEM,
        NFDOMAIN_ITEM
    }

    abstract val itemType: ItemType

    data class AccountAddressItem(
        val accountAddress: String,
        val shortenedAccountAddress: String
    ) : BasePasteableWatchAccountItem() {

        override val itemType: ItemType
            get() = ItemType.ACCOUNT_ADDRESS_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountAddressItem && accountAddress == other.accountAddress
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountAddressItem && this == other
        }
    }

    data class NfDomainItem(
        val nfDomainName: String,
        val nfDomainAccountAddress: String,
        val formattedNfDomainAccountAddress: String,
        val nfDomainLogoUrl: String?
    ) : BasePasteableWatchAccountItem() {

        override val itemType: ItemType
            get() = ItemType.NFDOMAIN_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is NfDomainItem && nfDomainAccountAddress == other.nfDomainAccountAddress
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is NfDomainItem && this == other
        }
    }
}
