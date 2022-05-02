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

import com.algorand.android.utils.TWO_DECIMALS
import com.algorand.android.utils.formatAsDateAndTime
import com.algorand.android.utils.formatAsTwoDecimals
import com.algorand.android.utils.getZonedDateTimeFromTimeStamp
import com.google.gson.annotations.SerializedName
import java.math.BigDecimal
import java.math.BigDecimal.ZERO
import java.math.RoundingMode

data class CandleHistory(
    @SerializedName("timestamp") val timestampAsSec: Long?,
    @SerializedName("low") val low: BigDecimal?,
    @SerializedName("high") val high: BigDecimal?,
    @SerializedName("open") val open: BigDecimal?,
    @SerializedName("close") val close: BigDecimal?,
    @SerializedName("volume") val volume: Float?
) {

    val formattedTimestamp: String
        get() = timestampAsSec?.getZonedDateTimeFromTimeStamp()?.formatAsDateAndTime().orEmpty()

    val formattedDisplayPrice: String
        get() = displayPrice?.formatAsTwoDecimals().orEmpty()

    val displayPrice: BigDecimal?
        get() = high?.setScale(TWO_DECIMALS, RoundingMode.FLOOR)

    fun getCurrencyConvertedInstance(currencyToUsdRatio: BigDecimal): CandleHistory {
        return with(currencyToUsdRatio) {
            copy(
                low = multiply(low ?: ZERO),
                high = multiply(high ?: ZERO),
                open = multiply(open ?: ZERO),
                close = multiply(open ?: ZERO)
            )
        }
    }
}
