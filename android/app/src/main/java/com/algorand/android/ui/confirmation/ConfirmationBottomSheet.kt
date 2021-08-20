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

package com.algorand.android.ui.confirmation

import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetConfirmationBinding
import com.algorand.android.models.ConfirmationBottomSheetParameters
import com.algorand.android.models.ConfirmationBottomSheetResult
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding

class ConfirmationBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_confirmation) {

    private val binding by viewBinding(BottomSheetConfirmationBinding::bind)

    private val args by navArgs<ConfirmationBottomSheetArgs>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        isCancelable = false
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi(args.parameters)
    }

    private fun initUi(parameters: ConfirmationBottomSheetParameters) {
        with(binding) {
            with(parameters) {
                titleTextView.setText(titleResId)
                descriptionTextView.text = descriptionText
                acceptButton.apply {
                    text = getString(confirmButtonTextResId)
                    setOnClickListener { setResultAndNavigateBack(true) }
                }
                cancelButton.apply {
                    text = getString(rejectButtonTextResId)
                    setOnClickListener { setResultAndNavigateBack(false) }
                }
                iconImageView.apply {
                    setImageResource(iconDrawableResId)
                    backgroundTintList = ContextCompat.getColorStateList(requireContext(), imageBackgroundTintResId)
                }
            }
        }
    }

    private fun setResultAndNavigateBack(isAccepted: Boolean) {
        val result = ConfirmationBottomSheetResult(args.parameters.confirmationIdentifier, isAccepted)
        setNavigationResult(RESULT_KEY, result)
        navBack()
    }

    companion object {
        const val RESULT_KEY = "result_key"
    }
}
