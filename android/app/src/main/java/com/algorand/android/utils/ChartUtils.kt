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

package com.algorand.android.utils

import com.algorand.android.models.CandleHistory
import com.github.mikephil.charting.data.Entry
import java.math.BigDecimal
import java.math.RoundingMode
import kotlinx.coroutines.Dispatchers.Default
import kotlinx.coroutines.withContext

/**
 * Since we don't have an API for Algo history in selected currency,
 * we handle manually by following steps below;
 * 1. Fetch Algo - USD History
 * 2. Fetch Algo - Selected Currency Value
 * 3. Calculate USD - Selected Currency Value
 * 4. Apply difference to history data
 *
 * Formula is;
 *      SelectedCurrencyValue / CurrentUsdPrice * ChartData
 *      Example;
 *          1 Algo = 7.66 ₺
 *          1 Algo = 0.9 $
 *          SelectedCurrencyValue / CurrentUsdPrice = 7.66 / 0.9 = 8.5 ₺ = 1 $
 *          Then we can multiply historic data with that value which is 8.5₺
 */
fun getCurrencyConvertedHistoryList(
    selectedCurrencyValueOfPerAlgo: BigDecimal,
    usdSelectedIntervalHistory: List<CandleHistory>,
    usdLastFiveMinInterval: CandleHistory
): List<CandleHistory> {
    val currentUsdPrice = usdLastFiveMinInterval.close ?: BigDecimal.ZERO
    val usdToSelectedCurrencyRatio = selectedCurrencyValueOfPerAlgo.divide(currentUsdPrice, RoundingMode.FLOOR)
    val currencyConvertedHistoryList = usdSelectedIntervalHistory.map {
        it.getCurrencyConvertedInstance(usdToSelectedCurrencyRatio)
    }
    val currencyConvertedLastFiveMinInterval = usdLastFiveMinInterval.getCurrencyConvertedInstance(
        usdToSelectedCurrencyRatio
    )
    return mutableListOf<CandleHistory>().apply {
        addAll(currencyConvertedHistoryList)
        val hasSameInterval =
            currencyConvertedHistoryList.last().timestampAsSec == currencyConvertedLastFiveMinInterval.timestampAsSec
        if (!hasSameInterval) add(currencyConvertedLastFiveMinInterval)
    }
}

suspend fun createChartEntryList(candleHistoryList: List<CandleHistory>): List<Entry> = withContext(Default) {
    return@withContext candleHistoryList
        .sortedBy { it.timestampAsSec }
        .filter { it.displayPrice != null }
        .mapIndexed { index, candleHistory ->
            Entry(index.toFloat(), candleHistory.displayPrice!!.toFloat(), candleHistory)
        }
}

fun getSafePriceTagXAxisPosition(xPosition: Float, textViewWidth: Int, parentWidth: Int): Float {
    val halfOfTextViewWidth = textViewWidth / 2f
    val isPriceTagOutOfChartRightBound = xPosition > parentWidth - halfOfTextViewWidth
    val isPriceTagOutOfChartLeftBound = xPosition < halfOfTextViewWidth

    return when {
        isPriceTagOutOfChartLeftBound -> 0f
        isPriceTagOutOfChartRightBound -> parentWidth - textViewWidth.toFloat()
        else -> xPosition - halfOfTextViewWidth
    }
}
