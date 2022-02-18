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

import android.os.Parcelable
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import java.math.BigInteger
import kotlinx.parcelize.Parcelize

@Parcelize
data class WalletConnectAssetInformation(
    val assetId: Long,
    val isVerified: Boolean = false,
    val shortName: String? = null,
    val fullName: String? = null,
    val decimal: Int,
    val amount: BigInteger? = null,
    val formattedSelectedCurrencyValue: String? = null,
) : Parcelable {
    val isAlgorand: Boolean
        get() = assetId == ALGORAND_ID

    companion object {
        fun create(
            assetInformation: AssetInformation?,
            formattedSelectedCurrencyValue: String? = null
        ): WalletConnectAssetInformation? {
            with(assetInformation) {
                if (this == null) return null
                return WalletConnectAssetInformation(
                    assetId,
                    isVerified,
                    shortName,
                    fullName,
                    decimals,
                    amount,
                    formattedSelectedCurrencyValue = formattedSelectedCurrencyValue
                )
            }
        }
    }
}
