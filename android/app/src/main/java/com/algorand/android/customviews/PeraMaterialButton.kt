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
import android.content.res.ColorStateList
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.widget.FrameLayout
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.content.ContextCompat
import androidx.core.content.res.use
import com.algorand.android.R
import com.algorand.android.databinding.CustomPeraMaterialButtonBinding
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.viewbinding.viewBinding
import kotlin.properties.Delegates

class PeraMaterialButton(
    context: Context,
    attrs: AttributeSet? = null
) : FrameLayout(context, attrs) {

    private val binding = viewBinding(CustomPeraMaterialButtonBinding::inflate)

    private var buttonText: String by Delegates.observable("") { _, oldValue, newValue ->
        if (oldValue != newValue) {
            binding.button.text = newValue
        }
    }

    private var isButtonEnabled: Boolean by Delegates.observable(true) { _, oldValue, newValue ->
        if (oldValue != newValue) {
            binding.button.isClickable = newValue
        }
    }

    private var buttonIconDrawable: Drawable? by Delegates.observable(null) { _, _, newValue ->
        binding.button.icon = newValue
    }

    private var buttonStrokeColor: ColorStateList? by Delegates.observable(null) { _, _, newValue ->
        binding.button.strokeColor = newValue
    }

    private var buttonIconTintColor: Int? by Delegates.observable<Int?>(null) { _, _, newValue ->
        binding.button.apply {
            if (newValue == null) {
                iconTint = null
            } else {
                setIconTintResource(newValue)
            }
        }
    }

    private var buttonBackgroundColor: ColorStateList? by Delegates.observable(null) { _, _, newValue ->
        binding.button.backgroundTintList = newValue
    }

    private var buttonTextColor: ColorStateList? by Delegates.observable(null) { _, _, newValue ->
        binding.button.setTextColor(newValue)
    }

    init {
        initAttributes(attrs)
    }

    fun setOnClickListener(onClick: () -> Unit) {
        binding.button.setOnClickListener { onClick() }
    }

    fun setText(text: String) {
        buttonText = text
    }

    fun setText(@StringRes textResId: Int) {
        buttonText = context.getString(textResId)
    }

    fun setIconDrawable(@DrawableRes iconResourceId: Int?) {
        buttonIconDrawable = if (iconResourceId == null) {
            null
        } else {
            AppCompatResources.getDrawable(context, iconResourceId)
        }
    }

    fun setIconTint(@ColorRes iconTintResId: Int?) {
        buttonIconTintColor = iconTintResId
    }

    fun setIconDrawable(drawable: Drawable?) {
        buttonIconDrawable = drawable
    }

    fun setButtonStroke(@ColorRes colorResId: Int?) {
        buttonStrokeColor = if (colorResId == null) {
            null
        } else {
            ColorStateList.valueOf(ContextCompat.getColor(context, colorResId))
        }
        if (buttonStrokeColor != null) {
            binding.button.setStrokeWidthResource(R.dimen.button_stroke_width)
        }
    }

    fun setBackgroundColor(@ColorRes colorResId: Int?) {
        buttonBackgroundColor = if (colorResId == null) {
            null
        } else {
            ColorStateList.valueOf(ContextCompat.getColor(context, colorResId))
        }
    }

    fun setButtonTextColor(@ColorRes colorResId: Int?) {
        buttonTextColor = if (colorResId == null) {
            null
        } else {
            ColorStateList.valueOf(ContextCompat.getColor(context, colorResId))
        }
    }

    fun showProgress() {
        binding.progressBar.show()
        isButtonEnabled = false
        clearButtonAttributes()
    }

    fun hideProgress() {
        binding.progressBar.hide()
        isButtonEnabled = true
        recoverButtonAttributes()
    }

    private fun clearButtonAttributes() {
        binding.button.apply {
            text = ""
            setDrawable(null)
            strokeColor = null
        }
    }

    private fun recoverButtonAttributes() {
        binding.button.apply {
            text = buttonText
            setDrawable(buttonIconDrawable)
            strokeColor = buttonStrokeColor
        }
    }

    private fun initAttributes(attrs: AttributeSet?) {
        context.obtainStyledAttributes(attrs, R.styleable.PeraMaterialButton).use {
            buttonText = it.getString(R.styleable.PeraMaterialButton_text).orEmpty()
        }
    }
}
