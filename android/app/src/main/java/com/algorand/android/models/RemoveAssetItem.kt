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

import androidx.annotation.StringRes
import java.math.BigInteger

data class RemoveAssetItem(
    val id: Long,
    val name: String?,
    val shortName: String?,
    val isVerified: Boolean,
    val isAlgo: Boolean,
    val decimals: Int,
    val creatorPublicKey: String?,
    val amount: BigInteger,
    val formattedAmount: String,
    val formattedSelectedCurrencyValue: String,
    val isAmountInSelectedCurrencyVisible: Boolean,
    @StringRes
    val notAvailableResId: Int
) : RecyclerListItem {
    override fun areItemsTheSame(other: RecyclerListItem): Boolean {
        return other is RemoveAssetItem && id == other.id
    }

    override fun areContentsTheSame(other: RecyclerListItem): Boolean {
        return other is RemoveAssetItem && shortName == other.shortName && name == other.name
    }
}
