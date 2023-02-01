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

package com.algorand.android.modules.swap.assetswap.ui.usecase

import com.algorand.android.modules.currency.domain.usecase.DisplayedCurrencyUseCase
import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapType
import com.algorand.android.modules.swap.assetswap.ui.mapper.SelectedAssetAmountDetailMapper
import com.algorand.android.modules.swap.assetswap.ui.model.AssetSwapPreview
import com.algorand.android.modules.swap.assetswap.ui.utils.SwapAmountUtils
import com.algorand.android.modules.swap.common.domain.usecase.GetSwapSlippageToleranceUseCase
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import com.algorand.android.utils.formatAsCurrency
import com.algorand.android.utils.formatAsPercentage
import com.algorand.android.utils.isEqualTo
import com.algorand.android.utils.toBigDecimalOrZero
import java.math.BigDecimal
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

class AssetSwapAmountUpdatedPreviewUseCase @Inject constructor(
    private val selectedAssetAmountDetailMapper: SelectedAssetAmountDetailMapper,
    private val assetSwapCreateQuotePreviewUseCase: AssetSwapCreateQuotePreviewUseCase,
    private val displayedCurrencyUseCase: DisplayedCurrencyUseCase,
    private val getSwapSlippageToleranceUseCase: GetSwapSlippageToleranceUseCase
) {

    fun getUpdatedPreview(
        fromAssetId: Long,
        toAssetId: Long?,
        amount: String?,
        accountAddress: String,
        swapType: SwapType,
        percentage: Float?,
        previousState: AssetSwapPreview
    ) = flow<AssetSwapPreview> {
        if (amount == null || amount.toBigDecimalOrZero() isEqualTo BigDecimal.ZERO) {
            val newState = previousState.copy(
                toSelectedAssetAmountDetail = selectedAssetAmountDetailMapper.mapToDefaultSelectedAssetAmountDetail(
                    primaryCurrencySymbol = displayedCurrencyUseCase.getDisplayedCurrencySymbol()
                ),
                fromSelectedAssetAmountDetail = previousState.fromSelectedAssetAmountDetail?.copy(
                    amount = amount,
                    formattedApproximateValue = BigDecimal.ZERO
                        .formatAsCurrency(displayedCurrencyUseCase.getDisplayedCurrencySymbol())
                ),
                isSwapButtonEnabled = false
            )
            emit(newState)
            return@flow
        }
        if (toAssetId == null || !SwapAmountUtils.isAmountValidForApiRequest(amount)) {
            emit(previousState.copy(isLoadingVisible = false))
            return@flow
        }
        emit(previousState.copy(isLoadingVisible = true))
        val assetDecimal = with(previousState) {
            if (swapType == SwapType.FIXED_INPUT) {
                fromSelectedAssetDetail.assetDecimal
            } else {
                toSelectedAssetDetail?.assetDecimal ?: DEFAULT_ASSET_DECIMAL
            }
        }
        val swapQuoteUpdatedPreview = assetSwapCreateQuotePreviewUseCase.getSwapQuoteUpdatedPreview(
            accountAddress = accountAddress,
            fromAssetId = fromAssetId,
            toAssetId = toAssetId,
            amount = amount,
            swapType = swapType,
            slippage = getSwapSlippageToleranceUseCase(),
            previousState = previousState,
            swapTypeAssetDecimal = assetDecimal,
            isMaxAndPercentageButtonEnabled = true,
            formattedPercentageText = percentage?.formatAsPercentage().orEmpty()
        ) ?: return@flow
        emit(swapQuoteUpdatedPreview)
    }
}
