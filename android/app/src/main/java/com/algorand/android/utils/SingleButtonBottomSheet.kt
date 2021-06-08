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

package com.algorand.android.utils

import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetSingleButtonBinding
import com.algorand.android.utils.viewbinding.viewBinding

class SingleButtonBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_single_button) {

    private val binding by viewBinding(BottomSheetSingleButtonBinding::bind)

    private val args: SingleButtonBottomSheetArgs by navArgs()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        isCancelable = false
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        with(args) {
            binding.titleTextView.setText(titleResId)
            binding.iconImageView.setImageResource(drawableResId)
            binding.descriptionTextView.text = context?.getXmlStyledString(descriptionAnnotatedString)
            binding.iconImageView.backgroundTintList =
                ContextCompat.getColorStateList(requireContext(), imageBackgroundTintResId)
            binding.confirmationButton.apply {
                setText(buttonTextResId)
                backgroundTintList = ContextCompat.getColorStateList(requireContext(), buttonBackgroundTintResId)
                setOnClickListener {
                    if (isResultNeeded) {
                        setNavigationResult(ACCEPT_KEY, true)
                    }
                    navBack()
                }
            }
        }
    }

    companion object {
        const val ACCEPT_KEY = "accept_key"
    }
}
