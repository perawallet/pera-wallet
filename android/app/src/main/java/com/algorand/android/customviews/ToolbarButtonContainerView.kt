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
import android.view.LayoutInflater
import android.view.View
import android.widget.LinearLayout
import androidx.annotation.LayoutRes
import androidx.core.view.marginBottom
import androidx.core.view.marginStart
import androidx.core.view.marginTop
import com.algorand.android.R
import com.algorand.android.models.BaseToolbarButton

class ToolbarButtonContainerView(context: Context, attrs: AttributeSet? = null) : LinearLayout(context, attrs) {

    fun addButton(baseButton: BaseToolbarButton) {
        getInflatedButton(baseButton.layoutResId).apply {
            id = generateViewId()
            setOnClickListener { baseButton.onClick() }
            addEndMargin(this)
            baseButton.initAttributes(this)
        }.also {
            addView(it)
        }
    }

    private fun addEndMargin(button: View) {
        val endMargin = context.resources.getDimensionPixelSize(
            if (childCount == 0) R.dimen.spacing_large else R.dimen.spacing_small
        )

        (button.layoutParams as? LayoutParams)?.setMargins(
            button.marginStart, button.marginTop, endMargin, button.marginBottom
        )
    }

    private fun getInflatedButton(@LayoutRes layoutResId: Int): View {
        return LayoutInflater.from(context).inflate(layoutResId, this, false)
    }
}
