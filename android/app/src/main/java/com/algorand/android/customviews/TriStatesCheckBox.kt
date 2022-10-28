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
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.appcompat.widget.AppCompatCheckBox
import com.algorand.android.R
import com.algorand.android.customviews.TriStatesCheckBox.CheckBoxState.CHECKED
import com.algorand.android.customviews.TriStatesCheckBox.CheckBoxState.UNCHECKED
import kotlin.properties.Delegates

class TriStatesCheckBox @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : AppCompatCheckBox(context, attrs) {

    private var checkBoxState: CheckBoxState by Delegates.observable(DEFAULT_CHECKBOX_STATE) { _, oldValue, newValue ->
        if (newValue != oldValue) updateUi()
    }

    init {
        setTextColor(context.getColor(R.color.link_primary))
        buttonDrawable = null
        compoundDrawablePadding = resources.getDimensionPixelSize(R.dimen.spacing_small)
        checkBoxState = if (isChecked) CHECKED else UNCHECKED
        isClickable = false
    }

    fun getState(): CheckBoxState {
        return checkBoxState
    }

    fun setState(state: CheckBoxState) {
        this.checkBoxState = state
    }

    private fun updateUi() {
        text = context.getString(checkBoxState.titleResId)
        setCompoundDrawablesWithIntrinsicBounds(0, 0, checkBoxState.drawableResId, 0)
    }

    enum class CheckBoxState(@DrawableRes val drawableResId: Int, @StringRes val titleResId: Int) {
        UNCHECKED(R.drawable.ic_checkbox_unselected, R.string.select_all),
        PARTIAL_CHECKED(R.drawable.ic_checkbox_partially_selected, R.string.select_all),
        CHECKED(R.drawable.ic_checkbox_selected, R.string.unselect_all)
    }

    companion object {
        private val DEFAULT_CHECKBOX_STATE = UNCHECKED
    }
}
