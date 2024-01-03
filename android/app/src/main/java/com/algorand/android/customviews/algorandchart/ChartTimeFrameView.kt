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
import androidx.constraintlayout.widget.ConstraintLayout
import com.algorand.android.databinding.CustomChartTimeFrameBinding
import com.algorand.android.models.ChartTimeFrame
import com.algorand.android.models.ChartTimeFrame.AllTimeFrame
import com.algorand.android.models.ChartTimeFrame.DayTimeFrame
import com.algorand.android.models.ChartTimeFrame.MonthTimeFrame
import com.algorand.android.models.ChartTimeFrame.WeekTimeFrame
import com.algorand.android.models.ChartTimeFrame.YearTimeFrame
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.button.MaterialButton
import kotlin.properties.Delegates

class ChartTimeFrameView @JvmOverloads constructor(
    context: Context,
    attributeSet: AttributeSet? = null
) : ConstraintLayout(context, attributeSet) {

    private val binding = viewBinding(CustomChartTimeFrameBinding::inflate)

    private var listener: Listener? = null

    private var selectedTimeFrame: ChartTimeFrame by Delegates.observable(
        ChartTimeFrame.DEFAULT_TIME_FRAME
    ) { _, oldValue, newValue ->
        if (oldValue != newValue) {
            onTimeFrameSelected(oldValue, newValue)
        }
    }

    init {
        initTimeFrameButtons()
        setTimeFrameCheckedStatus(selectedTimeFrame, true)
    }

    fun setListener(listener: Listener) {
        this.listener = listener
    }

    private fun initTimeFrameButtons() {
        with(binding) {
            setOnTimeFrameClickListener(dayButton, DayTimeFrame)
            setOnTimeFrameClickListener(weekButton, WeekTimeFrame)
            setOnTimeFrameClickListener(monthButton, MonthTimeFrame)
            setOnTimeFrameClickListener(yearButton, YearTimeFrame)
            setOnTimeFrameClickListener(allButton, AllTimeFrame)
        }
    }

    private fun setOnTimeFrameClickListener(button: MaterialButton, timeFrame: ChartTimeFrame) {
        button.setOnClickListener {
            if (timeFrame == selectedTimeFrame) {
                button.isChecked = true
                return@setOnClickListener
            }
            selectedTimeFrame = timeFrame
        }
    }

    private fun onTimeFrameSelected(oldTimeFrame: ChartTimeFrame, newTimeFrame: ChartTimeFrame) {
        setTimeFrameCheckedStatus(oldTimeFrame, isChecked = false)
        setTimeFrameCheckedStatus(newTimeFrame, isChecked = true)
        listener?.onTimeFrameSelected(newTimeFrame)
    }

    private fun setTimeFrameCheckedStatus(timeFrame: ChartTimeFrame, isChecked: Boolean) {
        with(binding) {
            when (timeFrame) {
                DayTimeFrame -> dayButton.isChecked = isChecked
                WeekTimeFrame -> weekButton.isChecked = isChecked
                MonthTimeFrame -> monthButton.isChecked = isChecked
                YearTimeFrame -> yearButton.isChecked = isChecked
                AllTimeFrame -> allButton.isChecked = isChecked
            }
        }
    }

    fun interface Listener {
        fun onTimeFrameSelected(selectedTimeFrame: ChartTimeFrame)
    }
}
