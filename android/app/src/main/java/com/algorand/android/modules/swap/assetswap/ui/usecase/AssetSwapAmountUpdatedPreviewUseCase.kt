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

import com.algorand.android.modules.swap.assetswap.ui.mapper.SelectedAssetAmountDetailMapper
import com.algorand.android.modules.swap.assetswap.ui.model.AssetSwapPreview
import com.algorand.android.modules.swap.assetswap.ui.utils.SwapAmountUtils
import com.algorand.android.modules.swap.common.SwapAppxValueParityHelper
import com.algorand.android.modules.swap.common.domain.usecase.GetSwapSlippageToleranceUseCase
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
    private val swapAppxValueParityHelper: SwapAppxValueParityHelper,
    private val getSwapSlippageToleranceUseCase: GetSwapSlippageToleranceUseCase
) {

    fun getUpdatedPreview(
        fromAssetId: Long,
        toAssetId: Long?,
        amount: String?,
        accountAddress: String,
        percentage: Float?,
        previousState: AssetSwapPreview?
    ) = flow<AssetSwapPreview> {
        if (previousState != null) {
            if (amount == null || amount.toBigDecimalOrZero() isEqualTo BigDecimal.ZERO) {
                val newState = previousState.copy(
                    toSelectedAssetAmountDetail = selectedAssetAmountDetailMapper.mapToDefaultSelectedAssetAmountDetail(
                        primaryCurrencySymbol = swapAppxValueParityHelper.getDisplayedCurrencySymbol()
                    ),
                    fromSelectedAssetAmountDetail = previousState.fromSelectedAssetAmountDetail?.copy(
                        amount = amount,
                        formattedApproximateValue = BigDecimal.ZERO
                            .formatAsCurrency(swapAppxValueParityHelper.getDisplayedCurrencySymbol())
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
            val swapQuoteUpdatedPreview = assetSwapCreateQuotePreviewUseCase.getSwapQuoteUpdatedPreview(
                accountAddress = accountAddress,
                fromAssetId = fromAssetId,
                toAssetId = toAssetId,
                amount = amount,
                slippage = getSwapSlippageToleranceUseCase(),
                previousState = previousState,
                swapTypeAssetDecimal = previousState.fromSelectedAssetDetail.assetDecimal,
                isMaxAndPercentageButtonEnabled = true,
                formattedPercentageText = percentage?.formatAsPercentage().orEmpty()
            ) ?: return@flow
            emit(swapQuoteUpdatedPreview)
        }
    }
}
