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

package com.algorand.android.modules.swap.confirmswap.ui.mapper

import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote
import com.algorand.android.modules.swap.confirmswap.ui.model.ConfirmSwapPreview
import com.algorand.android.modules.swap.utils.priceratioprovider.SwapPriceRatioProvider
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.ErrorResource
import com.algorand.android.utils.Event
import javax.inject.Inject

class ConfirmSwapPreviewMapper @Inject constructor() {

    @Suppress("LongParameterList")
    fun mapToConfirmSwapPreview(
        fromAssetDetail: ConfirmSwapPreview.SwapAssetDetail,
        toAssetDetail: ConfirmSwapPreview.SwapAssetDetail,
        priceRatioProvider: SwapPriceRatioProvider,
        slippageTolerance: String,
        formattedPriceImpact: String,
        minimumReceived: AnnotatedString,
        swapQuote: SwapQuote,
        isLoading: Boolean,
        isPriceImpactErrorVisible: Boolean,
        formattedExchangeFee: String,
        formattedPeraFee: String,
        accountIconResource: AccountIconResource,
        accountDisplayName: AccountDisplayName,
        errorEvent: Event<ErrorResource>?,
        slippageToleranceUpdateSuccessEvent: Event<Unit>?
    ): ConfirmSwapPreview {
        return ConfirmSwapPreview(
            fromAssetDetail = fromAssetDetail,
            toAssetDetail = toAssetDetail,
            priceRatioProvider = priceRatioProvider,
            slippageTolerance = slippageTolerance,
            formattedPriceImpact = formattedPriceImpact,
            minimumReceived = minimumReceived,
            formattedExchangeFee = formattedExchangeFee,
            formattedPeraFee = formattedPeraFee,
            swapQuote = swapQuote,
            isLoading = isLoading,
            isPriceImpactErrorVisible = isPriceImpactErrorVisible,
            accountIconResource = accountIconResource,
            accountDisplayName = accountDisplayName,
            errorEvent = errorEvent,
            slippageToleranceUpdateSuccessEvent = slippageToleranceUpdateSuccessEvent
        )
    }
}
