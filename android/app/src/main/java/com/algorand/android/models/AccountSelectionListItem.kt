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
import kotlinx.parcelize.Parcelize

sealed class AccountSelectionListItem : RecyclerListItem, Parcelable {

    @Parcelize
    data class InstructionItem(val accountCount: Int) : AccountSelectionListItem() {
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
        var isSelected: Boolean = false
    ) : AccountSelectionListItem() {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem && account.address == other.account.address && isSelected == other.isSelected
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AccountItem && this == other
        }
    }
}
