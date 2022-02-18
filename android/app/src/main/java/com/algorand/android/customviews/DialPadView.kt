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
import android.view.View
import android.view.ViewGroup
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.res.use
import androidx.core.view.children
import androidx.core.view.isInvisible
import androidx.core.view.marginBottom
import androidx.core.view.marginLeft
import androidx.core.view.marginRight
import androidx.core.view.marginTop
import com.algorand.android.R
import com.algorand.android.databinding.CustomDialpadBinding
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.button.MaterialButton

class DialPadView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomDialpadBinding::inflate)

    private val numPadViewList: MutableList<MaterialButton> = mutableListOf()
    private var dialPadListener: DialPadListener? = null

    init {
        loadAttrs(attrs)
        initNumericPads()
        setClickListeners()
    }

    private fun loadAttrs(attrs: AttributeSet?) {
        context?.obtainStyledAttributes(attrs, R.styleable.DialPadView)?.use { attrs ->
            attrs.getBoolean(R.styleable.DialPadView_showDotButton, false).let { isShown ->
                binding.padViewDotButton.isInvisible = isShown.not()
            }
            attrs.getDimensionPixelSize(R.styleable.DialPadView_padButtonSize, -1).let { size ->
                if (size != -1) setButtonSize(size)
            }
            attrs.getDimensionPixelSize(R.styleable.DialPadView_buttonHorizontalMargin, -1).let { margin ->
                if (margin != -1) setHorizontalMargin(margin)
            }
            attrs.getDimensionPixelSize(R.styleable.DialPadView_buttonVerticalMargin, -1).let { margin ->
                if (margin != -1) setVerticalMargin(margin)
            }
        }
    }

    private fun setHorizontalMargin(margin: Int) {
        applyAllViews { view ->
            with(view) {
                (layoutParams as MarginLayoutParams).setMargins(margin, marginTop, margin, marginBottom)
            }
        }
    }

    private fun setVerticalMargin(margin: Int) {
        applyAllViews { view ->
            with(view) {
                (layoutParams as MarginLayoutParams).setMargins(marginLeft, margin, marginRight, margin)
            }
        }
    }

    private fun setButtonSize(size: Int) {
        applyAllViews { view ->
            with(view) {
                (layoutParams as ViewGroup.LayoutParams).height = size
                (layoutParams as ViewGroup.LayoutParams).width = size
            }
        }
    }

    private fun initNumericPads() {
        with(binding) {
            numPadViewList.apply {
                add(padView0Button)
                add(padView1Button)
                add(padView2Button)
                add(padView3Button)
                add(padView4Button)
                add(padView5Button)
                add(padView6Button)
                add(padView7Button)
                add(padView8Button)
                add(padView9Button)
            }
        }
    }

    private fun setClickListeners() {
        numPadViewList.forEach { it.setOnClickListener { v -> onNumPadClick(v) } }
        binding.padViewDeleteButton.setOnClickListener { onBackspaceClick() }
        binding.padViewDotButton.setOnClickListener { onDotClick() }
    }

    private fun onNumPadClick(view: View?) {
        dialPadListener?.onNumberClick((view as MaterialButton).text.toString().toInt())
    }

    private fun onBackspaceClick() {
        dialPadListener?.onBackspaceClick()
    }

    private fun onDotClick() {
        dialPadListener?.onDotClick()
    }

    private fun applyAllViews(action: (View) -> Unit) {
        children.forEach { view ->
            action(view)
        }
    }

    fun setDialPadListener(dialPadListener: DialPadListener) {
        this.dialPadListener = dialPadListener
    }

    interface DialPadListener {
        fun onNumberClick(number: Int)
        fun onBackspaceClick()
        fun onDotClick() {}
    }
}
