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

package com.algorand.android.modules.walletconnect.validityextend.ui

import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.utils.BaseDoubleButtonBottomSheet
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.setFragmentNavigationResult
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WCSessionValidityExtensionBottomSheet : BaseDoubleButtonBottomSheet() {

    private val wcSessionValidityExtensionViewModel by viewModels<WCSessionValidityExtensionViewModel>()

    override fun setTitleText(textView: TextView) {
        val annotatedString = AnnotatedString(
            stringResId = R.string.extend_validity_to_date,
            replacementList = listOf(
                "extended_session_validity_date" to wcSessionValidityExtensionViewModel
                    .formattedExtendedSessionValidityDate
            )
        )
        textView.text = context?.getXmlStyledString(annotatedString)
    }

    override fun setDescriptionText(textView: TextView) {
        val annotatedString = AnnotatedString(
            stringResId = R.string.you_can_extend_the_expiration,
            replacementList = listOf(
                "max_extendable_session_validity_date" to wcSessionValidityExtensionViewModel
                    .formattedMaxExtendableSessionValidityDate
            )
        )
        textView.text = context?.getXmlStyledString(annotatedString)
    }

    override fun setAcceptButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.extend)
            setOnClickListener {
                setFragmentNavigationResult(WC_SESSION_VALIDITY_EXTENSION_RESULT_KEY, true)
                navBack()
            }
        }
    }

    override fun setCancelButton(materialButton: MaterialButton) {
        materialButton.apply {
            text = getString(R.string.cancel)
            setOnClickListener { navBack() }
        }
    }

    override fun setIconImageView(imageView: ImageView) {
        imageView.apply {
            setImageResource(R.drawable.ic_extend_time)
            imageTintList = ContextCompat.getColorStateList(requireContext(), R.color.positive)
        }
    }

    companion object {
        const val WC_SESSION_VALIDITY_EXTENSION_RESULT_KEY = "wcSessionValidityExtensionResultKey"
    }
}
