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

package com.algorand.android.ui.common

import android.os.Bundle
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.constraintlayout.widget.ConstraintLayout
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.WarningTextView
import com.algorand.android.databinding.FragmentBaseInfoBinding
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.button.MaterialButton

abstract class BaseInfoFragment : DaggerBaseFragment(R.layout.fragment_base_info) {

    private val binding by viewBinding(FragmentBaseInfoBinding::bind)

    protected val rootConstraintLayout: ConstraintLayout
        get() = binding.rootConstraintLayout

    abstract fun setImageView(imageView: ImageView)
    abstract fun setTitleText(textView: TextView)
    abstract fun setDescriptionText(textView: TextView)
    abstract fun setFirstButton(materialButton: MaterialButton)
    open fun setWarningFrame(warningTextView: WarningTextView) {}
    open fun setSecondButton(materialButton: MaterialButton) {}
    open fun setTopStartButton(materialButton: MaterialButton) {}

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setImageView(binding.infoImageView)
        setTitleText(binding.titleTextView)
        setDescriptionText(binding.descriptionTextView)
        setFirstButton(binding.firstButton)
        setSecondButton(binding.secondButton)
        setWarningFrame(binding.warningFrameView)
        setTopStartButton(binding.topStartButton)
    }
}
