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

package com.algorand.android.modules.collectibles.util.deciders

import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import com.algorand.android.utils.formatAmountByCollectibleFractionalDigit
import java.math.BigDecimal
import java.math.BigInteger
import javax.inject.Inject

class NFTAmountFormatDecider @Inject constructor() {

    fun decideNFTAmountFormat(
        nftAmount: BigInteger?,
        fractionalDecimal: Int?,
        formattedAmount: String?,
        formattedCompactAmount: String?
    ): String {
        val safeAmount = nftAmount?.toBigDecimal(fractionalDecimal ?: DEFAULT_ASSET_DECIMAL) ?: BigDecimal.ZERO
        return when {
            fractionalDecimal == 0 -> formattedCompactAmount.orEmpty()
            safeAmount < BigDecimal.ONE -> formattedAmount.orEmpty()
            else -> formattedCompactAmount.orEmpty()
        }
    }

    fun decideNFTAmountFormat(
        nftAmount: BigDecimal?,
        fractionalDecimal: Int?,
    ): String {
        val safeAmount = nftAmount ?: BigDecimal.ZERO
        val safeFractionalDecimal = fractionalDecimal ?: DEFAULT_ASSET_DECIMAL
        return when {
            fractionalDecimal == 0 -> {
                safeAmount.formatAmountByCollectibleFractionalDigit(decimals = fractionalDecimal, isCompact = true)
            }
            safeAmount < BigDecimal.ONE -> {
                safeAmount.formatAmountByCollectibleFractionalDigit(decimals = safeFractionalDecimal, isCompact = false)
            }
            else -> {
                safeAmount.formatAmountByCollectibleFractionalDigit(decimals = safeFractionalDecimal, isCompact = true)
            }
        }
    }
}
