/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.models

import androidx.annotation.StringRes

sealed class BaseReceiverAccount : RecyclerListItem {

    data class HeaderItem(@StringRes val titleRes: Int) : BaseReceiverAccount() {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is HeaderItem && titleRes == other.titleRes
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is HeaderItem && other == this
        }
    }

    data class ContactItem(val user: User) : BaseReceiverAccount() {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is ContactItem && user.publicKey == other.user.publicKey
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is ContactItem && user == other.user
        }
    }

    data class AccountItem(val accountCacheData: AccountCacheData) : BaseReceiverAccount() {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem && other.accountCacheData.account.address == accountCacheData.account.address
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem &&
                other.accountCacheData.account.name == accountCacheData.account.name &&
                other.accountCacheData.authAddress == accountCacheData.authAddress &&
                other.accountCacheData.account.type == accountCacheData.account.type
        }
    }

    data class PasteItem(val address: String) : BaseReceiverAccount() {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is PasteItem && address == other.address
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is PasteItem && this == other
        }
    }
}
