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
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.View
import androidx.annotation.IdRes
import androidx.annotation.StringRes
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.core.view.doOnPreDraw
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.databinding.CustomToolbarBinding
import com.algorand.android.models.BaseToolbarButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.getDisplaySize
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.viewbinding.viewBinding
import kotlin.math.max

class CustomToolbar @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomToolbarBinding::inflate)

    init {
        initRootView()
    }

    fun configure(toolbarConfiguration: ToolbarConfiguration?) {
        if (toolbarConfiguration == null) {
            hide()
            return
        }
        binding.buttonContainerView.removeAllViews()
        with(toolbarConfiguration) {
            initBackground(backgroundColor)
            initTitle(titleResId, titleColor)
            initSubtitle(subtitleResId)
            configureStartButton(startIconResId, startIconClick, startIconColor)
            initTitleDrawables(textStartDrawable, textEndDrawable)
            initCenterDrawable(centerDrawable)
            clearSubtitleStartDrawable()
        }
        show()
    }

    private fun initTitleDrawables(leftDrawable: Drawable?, rightDrawable: Drawable?) {
        setStartDrawable(leftDrawable)
        setEndDrawable(rightDrawable)
    }

    private fun initTitle(titleResId: Int?, titleColor: Int? = null) {
        with(binding.toolbarTitleTextView) {
            isVisible = titleResId != null
            if (titleResId != null) setText(titleResId)
            if (titleColor != null) setTextColor(ContextCompat.getColor(context, titleColor))
        }
    }

    private fun initSubtitle(subtitleResId: Int?) {
        binding.toolbarSubtitleTextView.apply {
            isVisible = subtitleResId != null
            if (subtitleResId != null) setText(subtitleResId)
        }
    }

    private fun initBackground(newBackgroundColor: Int?) {
        if (newBackgroundColor != null) {
            setBackgroundResource(newBackgroundColor)
        } else {
            background = null
        }
    }

    private fun initCenterDrawable(drawable: Drawable?) {
        if (drawable != null) {
            initTitle(null)
            initSubtitle(null)
            initTitleDrawables(null, null)
        }
        setCenterDrawable(drawable)
    }

    fun configureStartButton(resId: Int?, clickAction: (() -> Unit)?, iconColor: Int? = null) {
        binding.startImageButton.apply {
            if (resId == null) {
                hide()
                return
            }
            imageTintList = iconColor?.let { ContextCompat.getColorStateList(context, iconColor) }
            setImageResource(resId)
            setOnClickListener { clickAction?.invoke() }
            show()
        }
        setGuidelinePosition()
    }

    fun changeTitle(title: String) {
        binding.toolbarTitleTextView.apply {
            text = title
            show()
        }
    }

    fun changeTitle(@StringRes titleRes: Int) {
        binding.toolbarTitleTextView.apply {
            setText(titleRes)
            show()
        }
    }

    fun changeTitle(title: CharSequence) {
        binding.toolbarTitleTextView.apply {
            text = title
            show()
        }
    }

    fun changeSubtitle(subtitle: String) {
        binding.toolbarSubtitleTextView.apply {
            text = subtitle
            show()
        }
    }

    fun changeSubtitle(@StringRes subtitleResId: Int) {
        binding.toolbarSubtitleTextView.apply {
            setText(subtitleResId)
            show()
        }
    }

    fun setSubtitleStartDrawable(drawable: Drawable) {
        binding.toolbarSubtitleTextView.setDrawable(start = drawable)
    }

    fun clearSubtitleStartDrawable() {
        binding.toolbarSubtitleTextView.setDrawable(start = null)
    }

    fun setOnTitleLongClickListener(action: () -> Unit) {
        with(binding) {
            toolbarSubtitleTextView.setOnLongClickListener { action(); true }
            toolbarTitleTextView.setOnLongClickListener { action(); true }
        }
    }

    fun setEndButtons(buttons: List<BaseToolbarButton>) {
        setButtons { buttons.forEach { button -> binding.buttonContainerView.addButton(button) } }
    }

    fun setEndButton(button: BaseToolbarButton) {
        setButtons { binding.buttonContainerView.addButton(button) }
    }

    private fun setButtons(initButtons: () -> Unit) {
        binding.buttonContainerView.removeAllViews()
        initButtons()
        setGuidelinePosition()
    }

    fun setButtonVisibilityById(@IdRes buttonId: Int, isVisible: Boolean) {
        binding.buttonContainerView.findViewById<View>(buttonId)?.isVisible = isVisible
    }

    fun setEndDrawable(drawable: Drawable?) {
        binding.textEndImageView.apply {
            isVisible = drawable != null
            setImageDrawable(drawable ?: return)
        }
        setGuidelinePosition()
    }

    fun setStartDrawable(drawable: Drawable?) {
        binding.textStartImageView.apply {
            isVisible = drawable != null
            setImageDrawable(drawable ?: return)
        }
        setGuidelinePosition()
    }

    fun setCenterDrawable(drawable: Drawable?) {
        binding.centerImageView.apply {
            isVisible = drawable != null
            setImageDrawable(drawable ?: return)
        }
    }

    fun removeClickListeners() {
        binding.startImageButton.setOnClickListener(null)
        binding.buttonContainerView.removeClickListeners()
    }

    private fun setGuidelinePosition() {
        doOnPreDraw {
            with(binding) {
                val viewWidthToCalculate = max(startImageButton.measuredWidth, buttonContainerView.measuredWidth).run {
                    plus(if (textStartImageView.isVisible) textStartImageView.width else textEndImageView.width)
                        .plus(resources.getDimension(R.dimen.spacing_small).toInt())
                }.toFloat()
                val screenWidth = context.getDisplaySize().x
                val percentage = viewWidthToCalculate / screenWidth
                parentStartGuideline.setGuidelinePercent(percentage)
                parentEndGuideline.setGuidelinePercent(1 - percentage)
            }
        }
    }

    private fun initRootView() {
        setBackgroundColor(ContextCompat.getColor(context, R.color.primary_background))
    }
}
