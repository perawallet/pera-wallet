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
import com.algorand.android.modules.swap.slippagetolerance.ui.util.DEFAULT_SLIPPAGE_TOLERANCE
import com.algorand.android.utils.Event
import com.algorand.android.utils.emptyString
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

class AssetSwapFromAssetUpdatedUseCase @Inject constructor(
    private val assetSwapPreviewAssetDetailUseCase: AssetSwapPreviewAssetDetailUseCase,
    private val assetSwapCreateQuotePreviewUseCase: AssetSwapCreateQuotePreviewUseCase,
    private val selectedAssetAmountDetailMapper: SelectedAssetAmountDetailMapper,
    private val displayedCurrencyUseCase: DisplayedCurrencyUseCase
) {

    fun getFromAssetUpdatedPreview(
        fromAssetId: Long,
        toAssetId: Long?,
        amount: String?,
        accountAddress: String,
        swapType: SwapType,
        previousState: AssetSwapPreview
    ) = flow<AssetSwapPreview> {
        val fromSelectedAssetDetail = assetSwapPreviewAssetDetailUseCase.createFromSelectedAssetDetail(
            fromAssetId = fromAssetId,
            accountAddress = accountAddress,
            previousState = previousState
        )
        val newState = previousState.copy(fromSelectedAssetDetail = fromSelectedAssetDetail)

        if (toAssetId == fromAssetId) {
            emit(getToAssetClearedState(newState))
            return@flow
        }

        if (toAssetId == null || amount?.toBigDecimalOrNull() == null) {
            emit(newState)
        } else {
            if (!SwapAmountUtils.isAmountValidForApiRequest(amount)) return@flow
            emit(previousState.copy(isLoadingVisible = true))
            val swapQuoteUpdatedPreview = assetSwapCreateQuotePreviewUseCase.getSwapQuoteUpdatedPreview(
                accountAddress = accountAddress,
                fromAssetId = fromAssetId,
                toAssetId = toAssetId,
                amount = amount,
                swapType = swapType,
                slippage = DEFAULT_SLIPPAGE_TOLERANCE,
                previousState = newState,
                swapTypeAssetDecimal = fromSelectedAssetDetail.assetDecimal,
                isMaxAndPercentageButtonEnabled = true,
                formattedPercentageText = emptyString()
            ) ?: return@flow
            emit(swapQuoteUpdatedPreview)
        }
    }

    private fun getToAssetClearedState(previousState: AssetSwapPreview): AssetSwapPreview {
        return previousState.copy(
            toSelectedAssetDetail = null,
            clearToSelectedAssetDetailEvent = Event(Unit),
            toSelectedAssetAmountDetail = selectedAssetAmountDetailMapper.mapToDefaultSelectedAssetAmountDetail(
                amount = null,
                primaryCurrencySymbol = displayedCurrencyUseCase.getDisplayedCurrencySymbol()
            ),
            fromSelectedAssetAmountDetail = selectedAssetAmountDetailMapper.mapToDefaultSelectedAssetAmountDetail(
                amount = previousState.fromSelectedAssetAmountDetail?.amount,
                assetDecimal = previousState.fromSelectedAssetAmountDetail?.assetDecimal,
                primaryCurrencySymbol = displayedCurrencyUseCase.getDisplayedCurrencySymbol()
            ),
            isSwapButtonEnabled = false,
            isMaxAndPercentageButtonEnabled = false,
            isSwitchAssetsButtonEnabled = false
        )
    }
}
