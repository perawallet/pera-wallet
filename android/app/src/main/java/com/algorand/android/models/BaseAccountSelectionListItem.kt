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
 */

package com.algorand.android.models

import android.net.Uri
import androidx.annotation.StringRes

abstract class BaseAccountSelectionListItem : RecyclerListItem {

    data class HeaderItem(@StringRes val titleRes: Int) : BaseAccountSelectionListItem() {

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is HeaderItem && titleRes == other.titleRes
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is HeaderItem && other == this
        }
    }

    data class PasteItem(val publicKey: String) : BaseAccountSelectionListItem() {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is PasteItem && publicKey == other.publicKey
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is PasteItem && this == other
        }
    }

    sealed class BaseAccountItem : BaseAccountSelectionListItem() {
        abstract val displayName: String
        abstract val publicKey: String

        data class ContactItem(
            override val displayName: String,
            override val publicKey: String,
            val imageUri: Uri?
        ) : BaseAccountItem() {
            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is ContactItem && publicKey == other.publicKey
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is ContactItem && displayName == other.displayName && imageUri == other.imageUri
            }
        }

        data class AccountItem(
            override val displayName: String,
            override val publicKey: String,
            val accountIcon: AccountIcon,
            val showAssetCount: Boolean,
            val assetCount: Int,
            val collectibleCount: Int,
            val showHoldings: Boolean,
            val formattedHoldings: String,
        ) : BaseAccountItem() {
            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is AccountItem && other.publicKey == publicKey
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is AccountItem &&
                    other.displayName == displayName &&
                    other.accountIcon == accountIcon &&
                    other.formattedHoldings == formattedHoldings
            }
        }

        data class AccountErrorItem(
            override val displayName: String,
            override val publicKey: String,
            val accountIcon: AccountIcon,
            val isErrorIconVisible: Boolean
        ) : BaseAccountItem() {
            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is AccountErrorItem && other.publicKey == publicKey
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is AccountErrorItem && this == other
            }
        }
    }
}
