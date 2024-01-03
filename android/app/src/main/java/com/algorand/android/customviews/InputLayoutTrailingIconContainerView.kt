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
import androidx.annotation.DrawableRes
import androidx.core.view.children
import androidx.core.view.isVisible
import androidx.core.view.marginBottom
import androidx.core.view.marginStart
import androidx.core.view.marginTop
import com.algorand.android.R
import com.algorand.android.utils.extensions.hide

class InputLayoutTrailingIconContainerView(
    context: Context,
    attrs: AttributeSet? = null
) : LinearLayout(context, attrs) {

    private val clearButton by lazy {
        getInflatedIconView().apply {
            id = generateViewId()
            addEndMargin(this)
            setBackgroundResource(R.drawable.ic_close)
            hide()
        }
    }

    fun changeClearButtonVisibility(isVisible: Boolean) {
        children.forEach { it.isVisible = !isVisible }
        clearButton.isVisible = isVisible
    }

    fun enableClearButton(onIconClick: () -> Unit) {
        addClearButtonIfNotAddedBefore()
        setClearButtonClickListener(onIconClick)
    }

    private fun setClearButtonClickListener(onIconClick: () -> Unit) {
        clearButton.setOnClickListener { onIconClick() }
    }

    private fun addClearButtonIfNotAddedBefore() {
        if (children.none { it.id == clearButton.id }) {
            addView(clearButton)
        }
    }

    fun addIconView(@DrawableRes drawableRes: Int, onIconClick: () -> Unit): View {
        return getInflatedIconView().apply {
            id = generateViewId()
            setOnClickListener { onIconClick.invoke() }
            addEndMargin(this)
            initAttributes(this, drawableRes)
        }.also { addView(it) }
    }

    private fun addEndMargin(iconView: View) {
        val startMargin = context.resources.getDimensionPixelSize(
            if (childCount == 0) R.dimen.spacing_zero else R.dimen.spacing_large
        )
        (iconView.layoutParams as? LayoutParams)?.setMargins(
            startMargin, iconView.marginTop, iconView.marginStart, iconView.marginBottom
        )
    }

    private fun initAttributes(view: View, drawableRes: Int) {
        view.setBackgroundResource(drawableRes)
    }

    private fun getInflatedIconView(): View {
        return LayoutInflater.from(context).inflate(R.layout.custom_icon_button, this, false)
    }
}
