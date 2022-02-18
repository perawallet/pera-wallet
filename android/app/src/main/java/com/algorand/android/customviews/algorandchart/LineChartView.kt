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

import android.content.Context
import android.util.AttributeSet
import android.view.KeyEvent
import android.view.MotionEvent
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.models.LineChartTheme
import com.algorand.android.utils.dpToPX
import com.github.mikephil.charting.charts.LineChart
import com.github.mikephil.charting.data.DataSet
import com.github.mikephil.charting.data.Entry
import com.github.mikephil.charting.data.LineData
import com.github.mikephil.charting.data.LineDataSet

class LineChartView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : LineChart(context, attrs) {

    var onTouchListener: ((Boolean) -> Unit)? = null

    private val lineChartRenderer = LineChartDataRenderer(this, viewPortHandler, animator)

    init {
        setDrawBorders(false)
        isDoubleTapToZoomEnabled = false
        setPinchZoom(false)
        setScaleEnabled(false)
        xAxis.setDrawGridLines(false)
        xAxis.setDrawLabels(false)
        xAxis.setDrawAxisLine(false)
        axisLeft.isEnabled = false
        axisRight.isEnabled = false
        legend.isEnabled = false
        description.isEnabled = false
        setNoDataText("")
        setChartOffset()
        renderer = lineChartRenderer
    }

    override fun onTouchEvent(event: MotionEvent?): Boolean {
        if (hasMultiplePointer(event)) return true
        return when (event?.action) {
            KeyEvent.ACTION_DOWN -> {
                onTouchListener?.invoke(true)
                highlightTouchPointValue(event)
                true
            }
            KeyEvent.ACTION_UP -> {
                onTouchListener?.invoke(false)
                true
            }
            else -> super.onTouchEvent(event)
        }
    }

    private fun hasMultiplePointer(event: MotionEvent?): Boolean {
        return event?.pointerCount ?: 0 > 1
    }

    private fun setChartOffset() {
        minOffset = 0f
        setExtraOffsets(HORIZONTAL_OFFSET_AS_PX, extraTopOffset, HORIZONTAL_OFFSET_AS_PX, extraBottomOffset)
    }

    private fun highlightTouchPointValue(event: MotionEvent) {
        val closestEntry = getClosestEntry(event) ?: return
        highlightValue(closestEntry.x, 0)
    }

    private fun getClosestEntry(event: MotionEvent): Entry? {
        val dataSet = data?.dataSets?.firstOrNull() ?: return null
        if (dataSet.entryCount == 0) return null
        val horizontalOffsetAsDp = HORIZONTAL_OFFSET_AS_PX.dpToPX(resources)
        val shiftedTouchPoint = (event.x - horizontalOffsetAsDp)
        val chartWidthWithoutOffset = (width - 2 * horizontalOffsetAsDp)
        val calculatedXValue = (dataSet.entryCount - 1) * shiftedTouchPoint / chartWidthWithoutOffset
        return dataSet.getEntryForXValue(calculatedXValue, 0f, DataSet.Rounding.CLOSEST)
    }

    fun setChartData(entries: List<Entry>, lineChartTheme: LineChartTheme) {
        highlightValue(null)
        val lineColor = ContextCompat.getColor(context, lineChartTheme.lineColorResId)
        val lineData = LineDataSet(entries, null).apply {
            setDrawValues(false)
            setDrawCircles(false)
            setDrawHorizontalHighlightIndicator(false)
            highLightColor = lineColor
            highlightLineWidth = 2f
            setDrawFilled(false)
            color = lineColor
            marker = ChartMarkerView(context, R.layout.layout_chart_marker_view, lineChartTheme.markerDrawableResId)
            lineWidth = CHART_LINE_WIDTH
        }
        data = LineData(lineData)
        invalidate()
    }

    fun changeLineColorAlpha(isValueSelected: Boolean) {
        if (data == null) return
        (data.dataSets.firstOrNull() as? LineDataSet)?.apply {
            setColor(color, if (isValueSelected) TOUCH_LINE_ALPHA else NON_TOUCH_LINE_ALPHA)
        }
        invalidate()
    }

    fun setChartDataMapperListener(listener: LineChartDataRenderer.Listener) {
        lineChartRenderer.setListener(listener)
    }

    companion object {
        private const val CHART_LINE_WIDTH = 1.5f
        private const val TOUCH_LINE_ALPHA = 80
        private const val NON_TOUCH_LINE_ALPHA = 255
        private const val HORIZONTAL_OFFSET_AS_PX = 20f
    }
}
