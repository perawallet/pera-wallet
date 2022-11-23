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

import com.algorand.android.R
import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapType
import com.algorand.android.modules.swap.assetswap.ui.model.AssetSwapPreview
import com.algorand.android.utils.ErrorResource
import com.algorand.android.utils.Event
import com.algorand.android.utils.exceptions.InsufficientAlgoBalance
import com.algorand.android.utils.formatAsPercentage
import com.algorand.android.utils.recordException
import javax.inject.Inject

class AssetSwapPreviewUseCase @Inject constructor(
    private val getPercentageCalculatedForSwapUseCase: GetPercentageCalculatedBalanceForSwapUseCase,
    private val fromAssetUpdatedUseCase: AssetSwapFromAssetUpdatedUseCase,
    private val toAssetUpdatedUseCase: AssetSwapToAssetUpdatedUseCase,
    private val assetSwapAssetsSwitchUpdatePreviewUseCase: AssetSwapAssetsSwitchUpdatePreviewUseCase,
    private val assetSwapAmountUpdatedPreviewUseCase: AssetSwapAmountUpdatedPreviewUseCase,
    private val assetSwapInitialPreviewUseCase: AssetSwapInitialPreviewUseCase
) {

    fun getAssetSwapPreviewInitializationState(accountAddress: String, fromAssetId: Long): AssetSwapPreview {
        return assetSwapInitialPreviewUseCase.getAssetSwapPreviewInitializationState(accountAddress, fromAssetId)
    }

    fun getAmountUpdatedPreview(
        fromAssetId: Long,
        toAssetId: Long?,
        amount: String?,
        accountAddress: String,
        swapType: SwapType,
        percentage: Float?,
        previousState: AssetSwapPreview
    ) = assetSwapAmountUpdatedPreviewUseCase.getUpdatedPreview(
        fromAssetId = fromAssetId,
        toAssetId = toAssetId,
        amount = amount,
        accountAddress = accountAddress,
        swapType = swapType,
        previousState = previousState,
        percentage = percentage
    )

    fun getAssetsSwitchedUpdatedPreview(
        fromAssetId: Long,
        toAssetId: Long,
        amount: String?,
        accountAddress: String,
        swapType: SwapType,
        previousState: AssetSwapPreview
    ) = assetSwapAssetsSwitchUpdatePreviewUseCase.getAssetsSwitchedUpdatedPreview(
        fromAssetId = fromAssetId,
        toAssetId = toAssetId,
        amount = amount,
        accountAddress = accountAddress,
        swapType = swapType,
        previousState = previousState
    )

    fun getFromAssetUpdatedPreview(
        fromAssetId: Long,
        toAssetId: Long?,
        amount: String?,
        accountAddress: String,
        swapType: SwapType,
        previousState: AssetSwapPreview
    ) = fromAssetUpdatedUseCase.getFromAssetUpdatedPreview(
        fromAssetId = fromAssetId,
        toAssetId = toAssetId,
        amount = amount,
        accountAddress = accountAddress,
        swapType = swapType,
        previousState = previousState
    )

    suspend fun getToAssetUpdatedPreview(
        fromAssetId: Long,
        toAssetId: Long,
        amount: String?,
        fromAssetDecimal: Int,
        accountAddress: String,
        swapType: SwapType,
        previousState: AssetSwapPreview
    ) = toAssetUpdatedUseCase.getToAssetUpdatedPreview(
        fromAssetId = fromAssetId,
        toAssetId = toAssetId,
        amount = amount,
        fromAssetDecimal = fromAssetDecimal,
        accountAddress = accountAddress,
        swapType = swapType,
        previousState = previousState
    )

    suspend fun getBalanceForSelectedPercentage(
        previousAmount: String,
        fromAssetId: Long,
        percentage: Float,
        onLoadingChange: (isLoading: Boolean) -> Unit,
        onSuccess: (amount: String) -> Unit,
        onFailure: (errorEvent: Event<ErrorResource>) -> Unit,
        accountAddress: String
    ) {
        onLoadingChange(true)
        getPercentageCalculatedForSwapUseCase.getBalanceForSelectedPercentage(fromAssetId, percentage, accountAddress)
            .collect {
                it.useSuspended(
                    onSuccess = { updatedAmount ->
                        if (previousAmount == updatedAmount.toString()) onLoadingChange(false)
                        onSuccess(updatedAmount.toString())
                    },
                    onFailed = {
                        val errorEvent = if (it.exception is InsufficientAlgoBalance) {
                            Event(ErrorResource.LocalErrorResource.Local(R.string.account_does_not_have_algo))
                        } else {
                            Event(ErrorResource.Api(it.exception?.message.orEmpty()))
                        }
                        onFailure(errorEvent)
                    }
                )
            }
    }

    fun getSwapButtonClickUpdatedPreview(previousState: AssetSwapPreview): AssetSwapPreview {
        if (previousState.swapQuote == null) {
            recordException(
                IllegalArgumentException("$logTag: swap button click: swapQuote is null when it shouldn't be")
            )
            return previousState
        }
        return previousState.copy(
            navigateToConfirmSwapFragmentEvent = Event(previousState.swapQuote)
        )
    }

    fun getPercentageCalculationSuccessPreview(percentage: Float, previousState: AssetSwapPreview): AssetSwapPreview {
        return previousState.copy(
            formattedPercentageText = percentage.formatAsPercentage()
        )
    }

    fun getPercentageCalculationFailedPreview(
        errorEvent: Event<ErrorResource>,
        previousState: AssetSwapPreview
    ): AssetSwapPreview {
        return previousState.copy(
            errorEvent = errorEvent,
            isLoadingVisible = false
        )
    }

    companion object {
        private val logTag = AssetSwapPreviewUseCase::class.java.simpleName
    }
}
