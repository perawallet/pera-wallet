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

package com.algorand.android.ui.confirmation

import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.navigation.fragment.navArgs
import com.algorand.android.models.ConfirmationBottomSheetResult
import com.algorand.android.utils.BaseDoubleButtonBottomSheet
import com.algorand.android.utils.setNavigationResult
import com.google.android.material.button.MaterialButton

class ConfirmationBottomSheet : BaseDoubleButtonBottomSheet() {

    private val args by navArgs<ConfirmationBottomSheetArgs>()

    override fun setTitleText(textView: TextView) {
        textView.setText(args.parameters.titleResId)
    }

    override fun setDescriptionText(textView: TextView) {
        textView.text = args.parameters.descriptionText
    }

    override fun setAcceptButton(materialButton: MaterialButton) {
        materialButton.apply {
            text = getString(args.parameters.confirmButtonTextResId)
            setOnClickListener { setResultAndNavigateBack(true) }
        }
    }

    override fun setCancelButton(materialButton: MaterialButton) {
        materialButton.apply {
            text = getString(args.parameters.rejectButtonTextResId)
            setOnClickListener { setResultAndNavigateBack(false) }
        }
    }

    override fun setIconImageView(imageView: ImageView) {
        imageView.apply {
            setImageResource(args.parameters.iconDrawableResId)
            imageTintList = ContextCompat.getColorStateList(context, args.parameters.imageTintResId)
        }
    }

    private fun setResultAndNavigateBack(isAccepted: Boolean) {
        val result = ConfirmationBottomSheetResult(args.parameters.confirmationIdentifier, isAccepted)
        setNavigationResult(RESULT_KEY, result)
        navBack()
    }
}
