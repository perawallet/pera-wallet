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

package com.algorand.android.modules.swap.confirmswap.ui.model

import android.content.Context
import android.text.method.LinkMovementMethod
import android.text.method.MovementMethod
import androidx.core.content.ContextCompat
import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.utils.browser.openTinymanFaqPriceImpactUrl
import com.algorand.android.utils.getCustomClickableSpan

sealed class ConfirmSwapPriceImpactWarningStatus {

    abstract val percentageRange: IntRange
    abstract val priceImpactTextColorResId: Int
    abstract val priceImpactLabelTextColorResId: Int
    abstract val toAssetAmountTextColorResId: Int

    open val isPriceImpactErrorVisible: Boolean = true
    open val movementMethod: MovementMethod? = null
    open val isConfirmButtonEnabled: Boolean = true
    open val isConfirmationRequired: Boolean = false

    abstract fun getErrorText(context: Context): AnnotatedString?

    object NoWarning : ConfirmSwapPriceImpactWarningStatus() {

        override val priceImpactTextColorResId: Int = R.color.text_main
        override val priceImpactLabelTextColorResId: Int = R.color.text_gray
        override val isPriceImpactErrorVisible: Boolean = false
        override val toAssetAmountTextColorResId: Int = R.color.text_main

        override val percentageRange: IntRange = Int.MIN_VALUE until FIVE_PERCENT

        override fun getErrorText(context: Context): AnnotatedString? = null
    }

    sealed class Warning : ConfirmSwapPriceImpactWarningStatus() {

        override val priceImpactTextColorResId: Int = R.color.negative
        override val priceImpactLabelTextColorResId: Int = R.color.negative
        override val toAssetAmountTextColorResId: Int = R.color.negative

        object Level1 : Warning() {

            override val percentageRange: IntRange = FIVE_PERCENT until TEN_PERCENT

            override fun getErrorText(context: Context): AnnotatedString {
                return AnnotatedString(
                    R.string.caution_price_impact,
                    replacementList = listOf(
                        PRICE_IMPACT_PERCENTAGE_REPLACEMENT_KEY to percentageRange.first.toString()
                    )
                )
            }
        }

        object Level2 : Warning() {

            override val percentageRange: IntRange = TEN_PERCENT until FIFTEEN_PERCENT
            override val isConfirmationRequired: Boolean = true

            override fun getErrorText(context: Context): AnnotatedString {
                return AnnotatedString(
                    R.string.caution_price_impact,
                    replacementList = listOf(
                        PRICE_IMPACT_PERCENTAGE_REPLACEMENT_KEY to percentageRange.first.toString()
                    )
                )
            }
        }

        object Level3 : Warning() {

            override val percentageRange: IntRange = FIFTEEN_PERCENT until Int.MAX_VALUE
            override val movementMethod: MovementMethod = LinkMovementMethod.getInstance()
            override val isConfirmButtonEnabled: Boolean = false
            override val isConfirmationRequired: Boolean = true

            override fun getErrorText(context: Context): AnnotatedString {
                val linkTextColor = ContextCompat.getColor(context, R.color.link_primary)
                return AnnotatedString(
                    R.string.this_swap_can_not_be,
                    customAnnotationList = listOf(
                        PRICE_IMPACT_FAQ_URL_KEY to getCustomClickableSpan(linkTextColor) {
                            context.openTinymanFaqPriceImpactUrl()
                        }
                    )
                )
            }
        }
    }

    companion object {
        private const val FIVE_PERCENT = 5
        private const val TEN_PERCENT = 10
        private const val FIFTEEN_PERCENT = 15
        private const val PRICE_IMPACT_PERCENTAGE_REPLACEMENT_KEY = "price_impact_percentage"
        private const val PRICE_IMPACT_FAQ_URL_KEY = "faq_url"
    }
}
