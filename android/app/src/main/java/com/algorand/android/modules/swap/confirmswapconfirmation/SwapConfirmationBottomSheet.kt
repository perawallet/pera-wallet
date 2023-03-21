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

package com.algorand.android.modules.swap.confirmswapconfirmation

import android.content.Context
import android.text.method.LinkMovementMethod
import android.widget.ImageView
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.utils.BaseDoubleButtonBottomSheet
import com.algorand.android.utils.browser.openTinymanFaqPriceImpactUrl
import com.algorand.android.utils.getCustomClickableSpan
import com.algorand.android.utils.getXmlStyledString
import com.algorand.android.utils.setFragmentNavigationResult
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SwapConfirmationBottomSheet : BaseDoubleButtonBottomSheet() {

    private val swapConfirmationViewModel by viewModels<SwapConfirmationViewModel>()

    override fun setTitleText(textView: TextView) {
        textView.setText(R.string.high_price_impact_detected)
    }

    override fun setDescriptionText(textView: TextView) {
        textView.apply {
            text = getFormattedDescriptionText(textView.context)
            movementMethod = LinkMovementMethod.getInstance()
        }
    }

    override fun setAcceptButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.confirm_swap)
            setOnClickListener {
                setFragmentNavigationResult<Boolean>(CONFIRMATION_SUCCESS_KEY, true)
                navBack()
            }
        }
    }

    override fun setCancelButton(materialButton: MaterialButton) {
        materialButton.apply {
            setText(R.string.cancel)
            setOnClickListener {
                navBack()
            }
        }
    }

    override fun setIconImageView(imageView: ImageView) {
        imageView.setImageResource(R.drawable.ic_error_negative)
    }

    private fun getFormattedDescriptionText(context: Context): CharSequence {
        val linkTextColor = ContextCompat.getColor(context, R.color.link_primary)
        val priceImpactPercentage = swapConfirmationViewModel.getPriceImpactPercentage().toString()
        return context.getXmlStyledString(
            stringResId = R.string.it_appears_that_you_formatted,
            replacementList = listOf(PRICE_IMPACT_PERCENTAGE_REPLACEMENT_KEY to priceImpactPercentage),
            customAnnotations = listOf(
                FAQ_URL_ANNOTATION_KEY to getCustomClickableSpan(linkTextColor) {
                    this@SwapConfirmationBottomSheet.context?.openTinymanFaqPriceImpactUrl()
                }
            )
        )
    }

    companion object {
        private const val FAQ_URL_ANNOTATION_KEY = "faq_url"
        private const val PRICE_IMPACT_PERCENTAGE_REPLACEMENT_KEY = "price_impact_percentage"
        const val CONFIRMATION_SUCCESS_KEY = "confirmation_success_key"
    }
}
