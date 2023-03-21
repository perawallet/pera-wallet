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

package com.algorand.android.modules.parity.utils

import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import com.algorand.android.utils.toBigDecimalOrZero
import java.math.BigDecimal
import java.math.RoundingMode

object ParityUtils {

    fun getUsdValuePerAsset(
        assetAmount: String?,
        assetDecimal: Int?,
        totalAssetAmountInUsdValue: String?
    ): BigDecimal {
        val assetOutAmountAsBigDecimal = assetAmount.toBigDecimalOrZero()

        if (assetOutAmountAsBigDecimal == BigDecimal.ZERO) {
            return BigDecimal.ZERO
        }

        val safeAssetDecimal = assetDecimal ?: DEFAULT_ASSET_DECIMAL

        return totalAssetAmountInUsdValue
            .toBigDecimalOrZero()
            .divide(assetOutAmountAsBigDecimal.movePointLeft(safeAssetDecimal), safeAssetDecimal, RoundingMode.DOWN)
    }
}
