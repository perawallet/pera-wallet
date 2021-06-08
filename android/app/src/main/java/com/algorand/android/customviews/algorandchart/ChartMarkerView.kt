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
import android.graphics.Canvas
import androidx.core.view.isVisible
import com.algorand.android.databinding.LayoutChartMarkerViewBinding
import com.algorand.android.utils.viewbinding.viewBinding
import com.github.mikephil.charting.components.MarkerView
import com.github.mikephil.charting.data.Entry
import com.github.mikephil.charting.highlight.Highlight

class ChartMarkerView @JvmOverloads constructor(
    context: Context?,
    layoutResource: Int,
    markerBackgroundResId: Int
) : MarkerView(context, layoutResource) {

    private val binding = viewBinding(LayoutChartMarkerViewBinding::inflate)

    init {
        binding.chartMarkViewPointView.setBackgroundResource(markerBackgroundResId)
    }

    override fun refreshContent(e: Entry, highlight: Highlight?) {
        binding.chartMarkViewPointView.isVisible = highlight?.x == e.x
    }

    override fun draw(canvas: Canvas?, posX: Float, posY: Float) {
        val offsetPosX = posX - (width / 2)
        val offsetPosY = posY - (height / 2)
        super.draw(canvas, offsetPosX, offsetPosY)
    }
}
