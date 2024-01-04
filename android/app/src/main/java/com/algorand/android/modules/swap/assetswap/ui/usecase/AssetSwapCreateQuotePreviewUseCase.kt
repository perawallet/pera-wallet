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

import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.accounts.domain.usecase.AccountDetailSummaryUseCase
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote
import com.algorand.android.modules.swap.assetswap.domain.usecase.GetSwapQuoteUseCase
import com.algorand.android.modules.swap.assetswap.ui.mapper.AssetSwapPreviewMapper
import com.algorand.android.modules.swap.assetswap.ui.mapper.SelectedAssetAmountDetailMapper
import com.algorand.android.modules.swap.assetswap.ui.model.AssetSwapPreview
import com.algorand.android.modules.swap.assetswap.ui.utils.SwapBalanceErrorProvider
import com.algorand.android.utils.ErrorResource
import com.algorand.android.utils.Event
import com.algorand.android.utils.toBigDecimalOrZero
import javax.inject.Inject
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.map

class AssetSwapCreateQuotePreviewUseCase @Inject constructor(
    private val getSwapQuoteUseCase: GetSwapQuoteUseCase,
    private val swapBalanceErrorProvider: SwapBalanceErrorProvider,
    private val assetSwapPreviewMapper: AssetSwapPreviewMapper,
    private val assetSwapPreviewAssetDetailUseCase: AssetSwapPreviewAssetDetailUseCase,
    private val selectedAssetAmountDetailMapper: SelectedAssetAmountDetailMapper,
    private val accountDetailSummaryUseCase: AccountDetailSummaryUseCase,
    private val assetSwapSwitchButtonStatusUseCase: AssetSwapSwitchButtonStatusUseCase,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase
) {

    @Suppress("LongParameterList", "LongMethod")
    suspend fun getSwapQuoteUpdatedPreview(
        accountAddress: String,
        fromAssetId: Long,
        toAssetId: Long,
        amount: String?,
        swapTypeAssetDecimal: Int,
        isMaxAndPercentageButtonEnabled: Boolean,
        formattedPercentageText: String,
        previousState: AssetSwapPreview
    ): AssetSwapPreview? {
        var assetSwapPreview: AssetSwapPreview? = null
        val amountAsBigInteger = amount.toBigDecimalOrZero().movePointRight(swapTypeAssetDecimal).toBigInteger()
        getSwapQuoteUseCase.getSwapQuote(
            fromAssetId = fromAssetId,
            toAssetId = toAssetId,
            amount = amountAsBigInteger,
            slippage = null,
            accountAddress = accountAddress
        ).map {
            it.useSuspended(
                onSuccess = { swapQuote ->
                    val errorEvent = swapBalanceErrorProvider.checkIfSwapHasError(swapQuote, accountAddress)
                    val accountDetailSummary = accountDetailSummaryUseCase.getAccountDetailSummary(accountAddress)
                    assetSwapPreview = assetSwapPreviewMapper.mapToAssetSwapPreview(
                        accountDisplayName = accountDetailSummary.accountDisplayName,
                        accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(accountAddress),
                        fromSelectedAssetDetail = assetSwapPreviewAssetDetailUseCase
                            .createSelectedAssetDetailFromSwapQuoteAssetDetail(
                                accountAddress = accountAddress,
                                swapQuoteAssetDetail = swapQuote.fromAssetDetail
                            ),
                        toSelectedAssetDetail = assetSwapPreviewAssetDetailUseCase
                            .createSelectedAssetDetailFromSwapQuoteAssetDetail(
                                accountAddress = accountAddress,
                                swapQuoteAssetDetail = swapQuote.toAssetDetail
                            ),
                        isSwapButtonEnabled = errorEvent == null,
                        isLoadingVisible = false,
                        fromSelectedAssetAmountDetail = createFromSelectedAssetAmountDetail(swapQuote, amount),
                        toSelectedAssetAmountDetail = createToSelectedAssetAmountDetail(swapQuote),
                        isSwitchAssetsButtonEnabled = assetSwapSwitchButtonStatusUseCase.isSwitchAssetsButtonEnabled(
                            accountAddress = accountAddress,
                            fromAssetId = fromAssetId,
                            toAssetId = toAssetId,
                            previousState = previousState
                        ),
                        isMaxAndPercentageButtonEnabled = isMaxAndPercentageButtonEnabled,
                        formattedPercentageText = formattedPercentageText,
                        errorEvent = errorEvent,
                        swapQuote = swapQuote,
                        clearToSelectedAssetDetailEvent = null,
                        navigateToConfirmSwapFragmentEvent = null
                    )
                },
                onFailed = { errorDataResource ->
                    assetSwapPreview = previousState.copy(
                        isLoadingVisible = false,
                        isSwapButtonEnabled = false,
                        errorEvent = errorDataResource.exception?.message?.run {
                            Event(ErrorResource.Api(this))
                        },
                        fromSelectedAssetAmountDetail = previousState.swapQuote?.run {
                            createFromSelectedAssetAmountDetail(this, amount)
                        }
                    )
                }
            )
        }.collect()
        return assetSwapPreview
    }

    private fun createFromSelectedAssetAmountDetail(
        swapQuote: SwapQuote,
        previousAmount: String?
    ): AssetSwapPreview.SelectedAssetAmountDetail {
        val amount = if (previousAmount.isNullOrBlank()) {
            swapQuote.fromAssetAmount
                .movePointLeft(swapQuote.fromAssetDetail.fractionDecimals)
                .stripTrailingZeros()
                .toPlainString()
        } else {
            previousAmount
        }
        return selectedAssetAmountDetailMapper.mapToSelectedAssetAmountDetail(
            amount = amount,
            formattedApproximateValue = swapQuote.fromAssetAmountInSelectedCurrency.getFormattedValue(),
            assetDecimal = swapQuote.fromAssetDetail.fractionDecimals
        )
    }

    private fun createToSelectedAssetAmountDetail(swapQuote: SwapQuote): AssetSwapPreview.SelectedAssetAmountDetail {
        val amount = swapQuote.toAssetAmount
            .movePointLeft(swapQuote.toAssetDetail.fractionDecimals)
            .stripTrailingZeros()
            .toPlainString()
        return selectedAssetAmountDetailMapper.mapToSelectedAssetAmountDetail(
            amount = amount,
            formattedApproximateValue = swapQuote.toAssetAmountInSelectedCurrency.getFormattedValue(),
            assetDecimal = swapQuote.toAssetDetail.fractionDecimals
        )
    }
}
