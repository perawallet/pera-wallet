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

package com.algorand.android.customviews

import android.content.Context
import android.util.AttributeSet
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import com.algorand.android.databinding.CustomDialpadBinding
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.button.MaterialButton

class DialPadView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : ConstraintLayout(context, attrs) {

    private val binding = viewBinding(CustomDialpadBinding::inflate)

    private lateinit var numPadViewList: MutableList<MaterialButton>
    private var dialPadListener: DialPadListener? = null

    init {
        initColorViewList()
        setClickListeners()
    }

    private fun initColorViewList() {
        with(binding) {
            numPadViewList = mutableListOf(
                padView0Button,
                padView1Button,
                padView2Button,
                padView3Button,
                padView4Button,
                padView5Button,
                padView6Button,
                padView7Button,
                padView8Button,
                padView9Button
            )
        }
    }

    private fun setClickListeners() {
        numPadViewList.forEach { it.setOnClickListener { v -> onNumPadClick(v) } }
        binding.deleteImageView.setOnClickListener { onBackspaceClick() }
    }

    private fun onNumPadClick(view: View?) {
        dialPadListener?.onNumberClick((view as MaterialButton).text.toString().toInt())
    }

    private fun onBackspaceClick() {
        dialPadListener?.onBackspaceClick()
    }

    fun setDialPadListener(dialPadListener: DialPadListener) {
        this.dialPadListener = dialPadListener
    }

    interface DialPadListener {
        fun onNumberClick(number: Int)
        fun onBackspaceClick()
    }
}
