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

import com.algorand.android.R
import com.algorand.android.utils.formatAsTwoDecimals
import com.algorand.android.utils.isGreaterThan
import com.algorand.android.utils.isLesserThan
import com.algorand.android.utils.percentageChangeOf
import com.github.mikephil.charting.data.Entry
import java.math.BigDecimal
import java.math.BigDecimal.ZERO

data class ChartEntryData(
    val entryList: List<Entry>,
    val priceChangePercentage: BigDecimal
) {

    val latestFormattedPrice: String
        get() = (entryList.lastOrNull()?.data as? CandleHistory)?.displayPrice?.formatAsTwoDecimals().orEmpty()

    val percentageChangeTextColorResId: Int
        get() = if (priceChangePercentage isGreaterThan ZERO) R.color.positive else R.color.negative

    val percentageChangeArrowResId: Int
        get() {
            return if (priceChangePercentage isGreaterThan ZERO) {
                R.drawable.ic_arrow_up_line_positive_small
            } else {
                R.drawable.ic_arrow_down_line_negative_small
            }
        }

    val lineChartTheme: LineChartTheme
        get() {
            return when {
                priceChangePercentage isGreaterThan ZERO -> LineChartTheme.GREEN
                priceChangePercentage isLesserThan ZERO -> LineChartTheme.RED
                else -> LineChartTheme.GRAY
            }
        }

    companion object {
        fun create(entryList: List<Entry>): ChartEntryData? {
            val firstPriceOpening = (entryList.firstOrNull()?.data as? CandleHistory)?.open ?: return null
            val lastPrice = (entryList.lastOrNull()?.data as? CandleHistory)?.displayPrice ?: return null
            val priceChangePercentage = firstPriceOpening percentageChangeOf lastPrice
            return ChartEntryData(entryList, priceChangePercentage)
        }
    }
}
