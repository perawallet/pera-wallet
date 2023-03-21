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

package com.algorand.android.modules.swap.confirmswap.ui.usecase

import androidx.lifecycle.Lifecycle
import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.accounts.domain.usecase.AccountDetailSummaryUseCase
import com.algorand.android.modules.currency.domain.model.Currency.ALGO
import com.algorand.android.modules.parity.utils.ParityUtils
import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapType
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuoteAssetDetail
import com.algorand.android.modules.swap.assetswap.domain.usecase.GetSwapQuoteUseCase
import com.algorand.android.modules.swap.common.SwapAppxValueParityHelper
import com.algorand.android.modules.swap.common.domain.usecase.SetSwapSlippageToleranceUseCase
import com.algorand.android.modules.swap.confirmswap.domain.SwapTransactionSignManager
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapQuoteTransaction
import com.algorand.android.modules.swap.confirmswap.domain.usecase.CreateSwapQuoteTransactionsUseCase
import com.algorand.android.modules.swap.confirmswap.ui.mapper.ConfirmSwapAssetDetailMapper
import com.algorand.android.modules.swap.confirmswap.ui.mapper.ConfirmSwapPreviewMapper
import com.algorand.android.modules.swap.confirmswap.ui.mapper.decider.ConfirmSwapPriceImpactWarningStatusDecider
import com.algorand.android.modules.swap.confirmswap.ui.model.ConfirmSwapPreview
import com.algorand.android.modules.swap.confirmswap.ui.model.ConfirmSwapPriceImpactWarningStatus
import com.algorand.android.modules.swap.confirmswap.ui.model.ConfirmSwapPriceImpactWarningStatus.NoWarning
import com.algorand.android.modules.swap.ledger.signwithledger.ui.model.LedgerDialogPayload
import com.algorand.android.modules.swap.utils.getFormattedMinimumReceivedAmount
import com.algorand.android.modules.swap.utils.priceratioprovider.SwapPriceRatioProviderMapper
import com.algorand.android.modules.transaction.signmanager.ExternalTransactionSignResult
import com.algorand.android.modules.transaction.signmanager.ExternalTransactionSignResult.Error
import com.algorand.android.modules.transaction.signmanager.ExternalTransactionSignResult.LedgerScanFailed
import com.algorand.android.modules.transaction.signmanager.ExternalTransactionSignResult.LedgerWaitingForApproval
import com.algorand.android.modules.transaction.signmanager.ExternalTransactionSignResult.Loading
import com.algorand.android.modules.transaction.signmanager.ExternalTransactionSignResult.Success
import com.algorand.android.modules.transaction.signmanager.ExternalTransactionSignResult.TransactionCancelled
import com.algorand.android.utils.ErrorResource.Api
import com.algorand.android.utils.ErrorResource.LocalErrorResource.Defined
import com.algorand.android.utils.ErrorResource.LocalErrorResource.Local
import com.algorand.android.utils.Event
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.formatAsAlgoAmount
import com.algorand.android.utils.formatAsAssetAmount
import com.algorand.android.utils.formatAsCurrency
import com.algorand.android.utils.formatAsPercentage
import java.io.IOException
import java.math.BigDecimal
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.channelFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.flow

@Suppress("LongParameterList")
class ConfirmSwapPreviewUseCase @Inject constructor(
    private val confirmSwapPreviewMapper: ConfirmSwapPreviewMapper,
    private val confirmSwapAssetDetailMapper: ConfirmSwapAssetDetailMapper,
    private val getSwapQuoteUseCase: GetSwapQuoteUseCase,
    private val createSwapQuoteTransactionsUseCase: CreateSwapQuoteTransactionsUseCase,
    private val swapTransactionSignManager: SwapTransactionSignManager,
    private val swapPriceRatioProviderMapper: SwapPriceRatioProviderMapper,
    private val accountDetailSummaryUseCase: AccountDetailSummaryUseCase,
    private val setSwapSlippageToleranceUseCase: SetSwapSlippageToleranceUseCase,
    private val swapAppxValueParityHelper: SwapAppxValueParityHelper,
    private val priceImpactWarningStatusDecider: ConfirmSwapPriceImpactWarningStatusDecider
) {

    fun getConfirmSwapPreview(swapQuote: SwapQuote): ConfirmSwapPreview {
        val accountDetailSummary = accountDetailSummaryUseCase.getAccountDetailSummary(swapQuote.accountAddress)
        return with(swapQuote) {
            confirmSwapPreviewMapper.mapToConfirmSwapPreview(
                fromAssetDetail = createFromAssetDetail(swapQuote),
                toAssetDetail = createToAssetDetail(swapQuote),
                priceRatioProvider = swapPriceRatioProviderMapper.mapToSwapPriceRatioProvider(swapQuote),
                slippageTolerance = slippage.formatAsPercentage(),
                formattedPriceImpact = priceImpact.formatAsPercentage(),
                minimumReceived = getFormattedMinimumReceivedAmount(swapQuote),
                formattedPeraFee = peraFeeAmount.formatAsCurrency(ALGO.symbol),
                formattedExchangeFee = getFormattedExchangeFee(swapQuote),
                swapQuote = swapQuote,
                isLoading = false,
                priceImpact = swapQuote.priceImpact,
                errorEvent = null,
                slippageToleranceUpdateSuccessEvent = null,
                accountIconResource = accountDetailSummary.accountIconResource,
                accountDisplayName = accountDetailSummary.accountDisplayName
            )
        }
    }

    suspend fun updateSlippageTolerance(
        slippageTolerance: Float,
        swapQuote: SwapQuote,
        previousState: ConfirmSwapPreview
    ): Flow<ConfirmSwapPreview> = flow {
        with(swapQuote) {
            if (slippage == slippageTolerance) return@flow
            val swapAmount = if (swapType == SwapType.FIXED_INPUT) fromAssetAmount else toAssetAmount
            emit(previousState)
            getSwapQuoteUseCase.getSwapQuote(
                fromAssetId = fromAssetDetail.assetId,
                toAssetId = toAssetDetail.assetId,
                amount = swapAmount.toBigInteger(),
                accountAddress = accountAddress,
                slippage = slippageTolerance
            ).collect {
                it.useSuspended(
                    onSuccess = { newSwapQuote ->
                        setSwapSlippageToleranceUseCase(slippageTolerance)
                        val newState = getConfirmSwapPreview(newSwapQuote).copy(
                            slippageToleranceUpdateSuccessEvent = Event(Unit)
                        )
                        emit(newState)
                    },
                    onFailed = { errorDataResource ->
                        val errorMessage = errorDataResource.exception?.message
                        val errorEvent = if (!errorMessage.isNullOrBlank()) {
                            Event(Api(errorMessage))
                        } else {
                            null
                        }
                        val newState = previousState.copy(
                            isLoading = false,
                            errorEvent = errorEvent
                        )
                        emit(newState)
                    }
                )
            }
        }
    }

    suspend fun createQuoteAndUpdateUi(
        quoteId: Long,
        accountAddress: String,
        previousState: ConfirmSwapPreview
    ): Flow<ConfirmSwapPreview> = channelFlow {
        swapTransactionSignManager.manualStopAllResources()
        createSwapQuoteTransactionsUseCase.createQuoteTransactions(quoteId, accountAddress).useSuspended(
            onSuccess = {
                with(swapTransactionSignManager) {
                    signSwapQuoteTransaction(it)
                    swapTransactionSignResultFlow.collectLatest { result ->
                        trySend(updatePreviewWithSignResult(result, previousState))
                    }
                }
            },
            onFailed = {
                val errorResource = if (it.exception is IOException) {
                    Local(R.string.the_internet_connection)
                } else {
                    val errorMessage = it.exception?.message
                    if (errorMessage.isNullOrBlank()) {
                        Local(R.string.we_encountered_an_unexpected, R.string.something_went_wrong)
                    } else {
                        Api(errorMessage)
                    }
                }
                val newState = previousState.copy(
                    errorEvent = Event(errorResource)
                )
                trySend(newState)
            }
        )
    }

    private fun updatePreviewWithSignResult(
        result: ExternalTransactionSignResult,
        previousState: ConfirmSwapPreview
    ): ConfirmSwapPreview {
        with(previousState) {
            return when (result) {
                is Success<*> -> {
                    (result.signedTransaction as? List<SwapQuoteTransaction>)?.let { signedTransactions ->
                        copy(navigateToTransactionStatusFragmentEvent = Event(signedTransactions))
                    } ?: copy(errorEvent = Event(Local(R.string.an_error_occured)))
                }
                Loading -> copy(isLoading = true)
                is Error.Api -> copy(errorEvent = Event(Api(result.errorMessage)))
                is Error.Defined -> copy(errorEvent = Event(Defined(result.description)))
                LedgerScanFailed -> copy(navigateToLedgerNotFoundDialogEvent = Event(Unit))
                is LedgerWaitingForApproval -> {
                    val ledgerPayload = LedgerDialogPayload(
                        result.ledgerName,
                        result.currentTransactionIndex,
                        result.totalTransactionCount,
                        result.isTransactionIndicatorVisible
                    )
                    copy(navigateToLedgerWaitingForApprovalDialogEvent = Event(ledgerPayload))
                }
                is TransactionCancelled -> {
                    val annotatedString = (result.error as? Error.Defined)?.description
                        ?: AnnotatedString(R.string.an_error_occured)
                    copy(
                        errorEvent = Event(Defined(annotatedString)),
                        dismissLedgerWaitingForApprovalDialogEvent = Event(Unit)
                    )
                }
                else -> previousState
            }
        }
    }

    private fun createFromAssetDetail(swapQuote: SwapQuote): ConfirmSwapPreview.SwapAssetDetail {
        return with(swapQuote) {
            createAssetDetail(fromAssetDetail, fromAssetAmount, fromAssetAmountInUsdValue, NoWarning)
        }
    }

    private fun createToAssetDetail(swapQuote: SwapQuote): ConfirmSwapPreview.SwapAssetDetail {
        return with(swapQuote) {
            val priceImpactWarningStatus = priceImpactWarningStatusDecider.decideWarningStatus(swapQuote.priceImpact)
            createAssetDetail(toAssetDetail, toAssetAmount, toAssetAmountInUsdValue, priceImpactWarningStatus)
        }
    }

    private fun createAssetDetail(
        assetDetail: SwapQuoteAssetDetail,
        amount: BigDecimal,
        approximateValueInUsd: BigDecimal,
        priceImpactWarningStatus: ConfirmSwapPriceImpactWarningStatus
    ): ConfirmSwapPreview.SwapAssetDetail {
        val formattedAmount = amount.movePointLeft(assetDetail.fractionDecimals)
            .formatAmount(assetDetail.fractionDecimals, isDecimalFixed = false)
        val amountTextColorResId = priceImpactWarningStatus.toAssetAmountTextColorResId
        return confirmSwapAssetDetailMapper.mapToAssetDetail(
            assetId = assetDetail.assetId,
            formattedAmount = formattedAmount,
            formattedApproximateValue = getFormattedApproximateValue(assetDetail, amount, approximateValueInUsd),
            shortName = assetDetail.shortName,
            verificationTier = assetDetail.verificationTier,
            amountTextColorResId = amountTextColorResId,
            approximateValueTextColorResId = amountTextColorResId
        )
    }

    private fun getFormattedApproximateValue(
        assetDetail: SwapQuoteAssetDetail,
        amount: BigDecimal,
        approximateValueInUsd: BigDecimal
    ): String {
        val usdValuePerAsset = ParityUtils.getUsdValuePerAsset(
            amount.toPlainString(),
            assetDetail.fractionDecimals,
            approximateValueInUsd.toPlainString()
        )
        return swapAppxValueParityHelper.getDisplayedParityCurrencyValue(
            assetAmount = amount.toBigInteger(),
            assetUsdValue = usdValuePerAsset,
            assetDecimal = assetDetail.fractionDecimals,
            assetId = assetDetail.assetId
        ).getFormattedValue()
    }

    private fun getFormattedExchangeFee(swapQuote: SwapQuote): String {
        return with(swapQuote) {
            exchangeFeeAmount.stripTrailingZeros().toPlainString().run {
                if (isFromAssetAlgo) {
                    formatAsAlgoAmount()
                } else {
                    formatAsAssetAmount(fromAssetDetail.shortName.getName())
                }
            }
        }
    }

    fun setupSwapTransactionSignManager(lifecycle: Lifecycle) {
        swapTransactionSignManager.setup(lifecycle)
    }

    fun stopAllResources() {
        swapTransactionSignManager.stopAllResources()
    }
}
