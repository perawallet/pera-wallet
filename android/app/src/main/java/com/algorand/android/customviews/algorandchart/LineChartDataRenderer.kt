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

import android.graphics.Canvas
import com.github.mikephil.charting.animation.ChartAnimator
import com.github.mikephil.charting.charts.LineChart
import com.github.mikephil.charting.renderer.LineChartRenderer
import com.github.mikephil.charting.utils.ViewPortHandler

class LineChartDataRenderer(
    private val dataProvider: LineChart,
    viewPortHandler: ViewPortHandler,
    private val animator: ChartAnimator
) : LineChartRenderer(dataProvider, animator, viewPortHandler) {

    private var listener: Listener? = null

    override fun drawValues(canvas: Canvas?) {
        super.drawValues(canvas)
        ChartValuePositionMapper.create(dataProvider, animator, mXBounds.min, mXBounds.max)?.let { chartDataMapper ->
            listener?.onChartDataPositionMapperUpdated(chartDataMapper)
        }
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    fun interface Listener {
        fun onChartDataPositionMapperUpdated(chartValuePositionMapper: ChartValuePositionMapper)
    }
}
