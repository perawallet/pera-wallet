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

package com.algorand.android.utils

import android.os.Bundle
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetDoubleButtonBinding
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.button.MaterialButton

abstract class BaseDoubleButtonBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_double_button) {

    private val binding by viewBinding(BottomSheetDoubleButtonBinding::bind)

    abstract fun setTitleText(textView: TextView)
    abstract fun setDescriptionText(textView: TextView)
    abstract fun setAcceptButton(materialButton: MaterialButton)
    abstract fun setCancelButton(materialButton: MaterialButton)
    abstract fun setIconImageView(imageView: ImageView)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        isCancelable = false
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
    }

    protected fun setProgressVisibility(isVisible: Boolean) {
        binding.progressBar.loadingProgressBar.isVisible = isVisible
    }

    private fun initUi() {
        with(binding) {
            setTitleText(titleTextView)
            setDescriptionText(descriptionTextView)
            setAcceptButton(acceptButton)
            setCancelButton(cancelButton)
            setIconImageView(iconImageView)
        }
    }

    companion object {
        const val RESULT_KEY = "result_key"
    }
}
