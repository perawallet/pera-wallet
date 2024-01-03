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
import android.view.Gravity
import androidx.appcompat.content.res.AppCompatResources
import androidx.appcompat.widget.AppCompatTextView
import androidx.core.content.res.use
import com.algorand.android.R
import com.algorand.android.utils.setDrawable
import kotlin.properties.Delegates

class PeraRadioButton(context: Context, attrs: AttributeSet? = null) : AppCompatTextView(context, attrs) {

    var isChecked: Boolean by Delegates.observable(DEFAULT_CHECK_STATUS) { _, _, newValue ->
        isSelected = newValue
    }

    init {
        initRootView()
        initRadioButtonDrawable()
        initAttributes(attrs)
    }

    private fun initRootView() {
        gravity = Gravity.CENTER_VERTICAL
        compoundDrawablePadding = resources.getDimensionPixelSize(R.dimen.spacing_xsmall)
        minHeight = resources.getDimensionPixelSize(R.dimen.pera_radio_button_min_height)
    }

    private fun initAttributes(attrs: AttributeSet?) {
        context.obtainStyledAttributes(attrs, R.styleable.PeraRadioButton).use {
            isChecked = it.getBoolean(R.styleable.PeraRadioButton_android_checked, DEFAULT_CHECK_STATUS)
        }
    }

    private fun initRadioButtonDrawable() {
        setDrawable(end = AppCompatResources.getDrawable(context, R.drawable.selector_radio_button))
    }

    companion object {
        private const val DEFAULT_CHECK_STATUS = false
    }
}
