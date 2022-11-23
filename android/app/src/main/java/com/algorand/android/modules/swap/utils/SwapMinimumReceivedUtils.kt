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

package com.algorand.android.modules.swap.utils

import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.currency.domain.model.Currency
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote

private const val FIRST_PLACEHOLDER_KEY = "first"
private const val SECOND_PLACEHOLDER_KEY = "second"

fun getFormattedMinimumReceivedAmount(swapQuote: SwapQuote): AnnotatedString {
    return with(swapQuote) {
        val minimumReceivedAmount = getFormattedMinimumReceivedAmount()
        if (isToAssetAlgo) {
            AnnotatedString(
                R.string.pair_value_format_packed_annotated,
                replacementList = listOf(
                    FIRST_PLACEHOLDER_KEY to Currency.ALGO.symbol,
                    SECOND_PLACEHOLDER_KEY to minimumReceivedAmount
                )
            )
        } else {
            val assetShortName = toAssetDetail.shortName.getName().orEmpty()
            AnnotatedString(
                R.string.pair_value_format_annotated,
                replacementList = listOf(
                    FIRST_PLACEHOLDER_KEY to minimumReceivedAmount,
                    SECOND_PLACEHOLDER_KEY to assetShortName
                )
            )
        }
    }
}
