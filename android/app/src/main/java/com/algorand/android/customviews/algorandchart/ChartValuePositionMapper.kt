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

package com.algorand.android.customviews.algorandchart

import com.algorand.android.models.CandleHistory
import com.algorand.android.models.ValuePosition
import com.algorand.android.utils.partitionIndexed
import com.github.mikephil.charting.animation.ChartAnimator
import com.github.mikephil.charting.charts.LineChart
import com.github.mikephil.charting.data.LineData
import com.github.mikephil.charting.utils.Transformer
import java.math.BigDecimal.ZERO

data class ChartValuePositionMapper(val valuePositions: List<ValuePosition>) {

    fun getMinValuePosition(): ValuePosition? {
        return valuePositions.maxByOrNull { it.y }
    }

    fun getMaxValuePosition(): ValuePosition? {
        return valuePositions.asReversed().minByOrNull { it.y }
    }

    companion object {
        fun create(
            chart: LineChart,
            animator: ChartAnimator,
            xBoundMin: Int,
            xBoundMax: Int
        ): ChartValuePositionMapper? {
            if (!shouldCreateChartValuePositionMapper(chart.data)) return null
            val dataSet = chart.data.dataSets.first()
            val transformer: Transformer = chart.getTransformer(dataSet.axisDependency)
            val positions = with(animator) {
                transformer.generateTransformedValuesLine(dataSet, phaseX, phaseY, xBoundMin, xBoundMax)
            }
            val (xAxisPositions, yAxisPositions) = positions.partitionIndexed { index, _ ->
                index % 2 == 0
            }
            val valuePositionList = xAxisPositions.mapIndexed { index, xAxisValue ->
                val displayPrice = (dataSet?.getEntryForIndex(index)?.data as? CandleHistory)?.displayPrice ?: ZERO
                ValuePosition(displayPrice, xAxisValue, yAxisPositions[index])
            }
            return ChartValuePositionMapper(valuePositionList)
        }

        private fun shouldCreateChartValuePositionMapper(data: LineData?): Boolean {
            return data?.run {
                dataSets?.isNotEmpty() == false || dataSets?.firstOrNull()?.entryCount ?: 0 > 0
            } ?: false
        }
    }
}
