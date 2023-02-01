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

package com.algorand.android.modules.swap.previewsummary.ui.usecase

import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.currency.domain.model.Currency
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote
import com.algorand.android.modules.swap.previewsummary.ui.mapper.SwapPreviewSummaryPreviewMapper
import com.algorand.android.modules.swap.previewsummary.ui.model.SwapPreviewSummaryPreview
import com.algorand.android.modules.swap.utils.getFormattedMinimumReceivedAmount
import com.algorand.android.modules.swap.utils.priceratioprovider.SwapPriceRatioProviderMapper
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.formatAsCurrency
import com.algorand.android.utils.formatAsPercentage
import javax.inject.Inject

class SwapPreviewSummaryPreviewUseCase @Inject constructor(
    private val swapPriceRatioProviderMapper: SwapPriceRatioProviderMapper,
    private val swapPreviewSummaryPreviewMapper: SwapPreviewSummaryPreviewMapper,
    private val accountDisplayNameUseCase: AccountDisplayNameUseCase,
    private val accountDetailUseCase: AccountDetailUseCase
) {

    fun getInitialPreview(swapQuote: SwapQuote): SwapPreviewSummaryPreview {
        return with(swapQuote) {
            swapPreviewSummaryPreviewMapper.mapToSwapPreviewSummaryPreview(
                priceRatioProvider = swapPriceRatioProviderMapper.mapToSwapPriceRatioProvider(swapQuote),
                slippageTolerance = slippage.formatAsPercentage(),
                priceImpact = priceImpact.toString(),
                minimumReceived = getFormattedMinimumReceivedAmount(swapQuote),
                formattedExchangeFee = exchangeFeeAmount.formatAsCurrency(Currency.ALGO.symbol),
                formattedPeraFee = peraFeeAmount.formatAsCurrency(Currency.ALGO.symbol),
                formattedTotalFee = totalFee.formatAsCurrency(Currency.ALGO.symbol),
                accountDisplayName = accountDisplayNameUseCase.invoke(swapQuote.accountAddress),
                accountIconResource = accountDetailUseCase.getAccountIcon(swapQuote.accountAddress)
            )
        }
    }
}
