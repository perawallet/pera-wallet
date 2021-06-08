/*
 * Copyright 2019 Algorand, Inc.
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
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.view.doOnLayout
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.databinding.CustomCompactChartBinding
import com.algorand.android.models.ChartTimeFrame
import com.algorand.android.models.LineChartTheme
import com.algorand.android.models.ValuePosition
import com.algorand.android.utils.getSafePriceTagXAxisPosition
import com.algorand.android.utils.viewbinding.viewBinding
import com.github.mikephil.charting.data.Entry
import com.github.mikephil.charting.data.LineData
import com.github.mikephil.charting.highlight.Highlight
import com.github.mikephil.charting.listener.OnChartValueSelectedListener

class CompactChartView @JvmOverloads constructor(
    context: Context,
    attributeSet: AttributeSet? = null
) : ConstraintLayout(context, attributeSet) {

    private val binding = viewBinding(CustomCompactChartBinding::inflate)
    private var listener: Listener? = null
    private var isChartValueSelected: Boolean = false
    private var selectedCurrencyValue = ""

    private val onChartValueSelectedListener = object : OnChartValueSelectedListener {
        override fun onValueSelected(entry: Entry?, highlight: Highlight?) {
            listener?.onChartValueSelected(entry, highlight)
            isChartValueSelected = true
            binding.lineChartView.changeLineColorAlpha(isValueSelected = true)
        }

        override fun onNothingSelected() {
            listener?.onNothingSelected()
        }
    }

    private val onTimeFrameSelectedListener = ChartTimeFrameView.Listener { selectedTimeFrame ->
        listener?.onTimeFrameSelected(selectedTimeFrame)
    }

    private val chartDataPositionMapperListener = LineChartDataRenderer.Listener { positionMapper ->
        val tagOffset = resources.getDimensionPixelSize(R.dimen.chart_price_tag_offset)
        val padding = resources.getDimensionPixelOffset(R.dimen.chart_vertical_padding)
        setMinimumPriceTag(positionMapper.getMinValuePosition(), tagOffset, padding)
        setMaximumPriceTag(positionMapper.getMaxValuePosition(), tagOffset, padding)
    }

    init {
        initRootLayout()
        initUi()
    }

    fun setSelectedCurrencyId(currencyId: String) {
        selectedCurrencyValue = currencyId
    }

    fun setChartData(chartEntryList: List<Entry>, lineChartTheme: LineChartTheme) {
        binding.noDataTextView.isVisible = chartEntryList.isEmpty()
        if (chartEntryList.isEmpty()) return
        binding.lineChartView.setChartData(chartEntryList, lineChartTheme)
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    fun showProgress() {
        hideError()
        binding.progressBar.isVisible = true
    }

    fun showError() {
        binding.noDataTextView.visibility = View.VISIBLE
        clearChartData()
        hidePriceTags()
    }

    fun hideError() {
        binding.noDataTextView.visibility = View.GONE
    }

    fun hideProgress() {
        binding.progressBar.isVisible = false
    }

    fun clearHighlights() {
        binding.lineChartView.highlightValues(null)
    }

    fun clearChartData() {
        binding.lineChartView.clear()
    }

    fun getChartData(): LineData? = binding.lineChartView.data

    private fun initUi() {
        with(binding) {
            timeFrameView.setListener(onTimeFrameSelectedListener)
            lineChartView.apply {
                setOnChartValueSelectedListener(onChartValueSelectedListener)
                onTouchListener = ::onChartTouch
                setChartDataMapperListener(chartDataPositionMapperListener)
            }
        }
    }

    private fun onChartTouch(hasFocus: Boolean) {
        if (!hasFocus) {
            isChartValueSelected = false
            binding.lineChartView.apply {
                highlightValue(null)
                changeLineColorAlpha(false)
            }
        }
        listener?.onLineChartTouch(hasFocus)
    }

    private fun initRootLayout() {
        val verticalPadding = resources.getDimensionPixelSize(R.dimen.chart_vertical_padding)
        setPadding(paddingLeft, verticalPadding, paddingRight, verticalPadding)
        clipToPadding = false
    }

    private fun setMinimumPriceTag(valuePosition: ValuePosition?, tagOffset: Int, padding: Int) {
        valuePosition?.run {
            with(binding.minPriceTextView) {
                isVisible = !isChartValueSelected
                if (isChartValueSelected) return
                val parentWidth = this@CompactChartView.width
                text = getFormattedSignedPriceText(this@run)
                doOnLayout {
                    x = getSafePriceTagXAxisPosition(valuePosition.x, width, parentWidth)
                    y = valuePosition.y + tagOffset + padding
                }
            }
        }
    }

    private fun setMaximumPriceTag(valuePosition: ValuePosition?, tagOffset: Int, padding: Int) {
        valuePosition?.run {
            with(binding.maxPriceTextView) {
                isVisible = !isChartValueSelected
                if (isChartValueSelected) return
                val parentWidth = this@CompactChartView.width
                text = getFormattedSignedPriceText(this@run)
                doOnLayout {
                    x = getSafePriceTagXAxisPosition(valuePosition.x, width, parentWidth)
                    y = valuePosition.y - tagOffset - height + padding
                }
            }
        }
    }

    private fun hidePriceTags() {
        with(binding) {
            minPriceTextView.visibility = View.GONE
            maxPriceTextView.visibility = View.GONE
        }
    }

    private fun getFormattedSignedPriceText(valuePosition: ValuePosition): String {
        return resources.getString(
            R.string.title_and_value_format,
            selectedCurrencyValue,
            valuePosition.getFormattedPriceValue()
        )
    }

    interface Listener {
        fun onChartValueSelected(entry: Entry?, highlight: Highlight?) {}
        fun onNothingSelected() {}
        fun onLineChartTouch(hasFocus: Boolean) {}
        fun onTimeFrameSelected(selectedTimeFrame: ChartTimeFrame) {}
    }
}
