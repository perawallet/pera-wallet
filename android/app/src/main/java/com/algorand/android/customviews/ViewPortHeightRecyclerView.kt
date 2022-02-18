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

package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import androidx.core.content.res.use
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.utils.getDisplaySize

class ViewPortHeightRecyclerView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet?,
) : RecyclerView(context, attrs) {

    private var heightOffset = 0

    init {
        loadAttrs(attrs)
    }

    private fun loadAttrs(attrs: AttributeSet?) {
        context?.obtainStyledAttributes(attrs, R.styleable.ViewPortHeightRecyclerView)?.use { attrs ->
            attrs.getDimensionPixelSize(R.styleable.ViewPortHeightRecyclerView_heightOffset, -1).let { size ->
                if (size != -1) {
                    heightOffset = size
                }
            }
        }
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {

        with(resources) {
            val toolbarHeightInPx = getDimensionPixelSize(R.dimen.default_toolbar_height)
            val params = (layoutParams as? MarginLayoutParams)
            val marginsHeight = (params?.topMargin ?: 0) + (params?.bottomMargin ?: 0)
            val viewportHeightSpec = context.getDisplaySize().y - toolbarHeightInPx - marginsHeight - heightOffset
            val viewPortHeightMeasureSpec = MeasureSpec.makeMeasureSpec(viewportHeightSpec, MeasureSpec.AT_MOST)
            super.onMeasure(widthMeasureSpec, viewPortHeightMeasureSpec)
        }
    }
}
