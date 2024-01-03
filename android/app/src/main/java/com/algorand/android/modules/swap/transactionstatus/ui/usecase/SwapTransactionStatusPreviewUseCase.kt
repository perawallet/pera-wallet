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

package com.algorand.android.modules.swap.transactionstatus.ui.usecase

import android.content.res.Resources
import android.text.style.ForegroundColorSpan
import androidx.core.content.res.ResourcesCompat
import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapQuoteTransaction
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapQuoteTransaction.SwapTransaction
import com.algorand.android.modules.swap.transactionstatus.domain.SendSwapTransactionsManager
import com.algorand.android.modules.swap.transactionstatus.ui.mapper.SwapTransactionStatusPreviewMapper
import com.algorand.android.modules.swap.transactionstatus.ui.model.SwapTransactionStatusPreview
import com.algorand.android.modules.swap.transactionstatus.ui.model.SwapTransactionStatusType
import com.algorand.android.usecase.NetworkSlugUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.encodeToURL
import com.algorand.android.utils.formatAmount
import java.math.BigInteger
import javax.inject.Inject
import kotlinx.coroutines.flow.channelFlow

class SwapTransactionStatusPreviewUseCase @Inject constructor(
    private val swapTransactionStatusPreviewMapper: SwapTransactionStatusPreviewMapper,
    private val networkSlugUseCase: NetworkSlugUseCase,
    private val sendSwapTransactionsManager: SendSwapTransactionsManager,
    private val swapTransactionEventTrackingUseCase: SwapTransactionEventTrackingUseCase
) {

    suspend fun getSwapTransactionStatusPreviewFlow(
        resources: Resources,
        swapQuote: SwapQuote,
        signedTransactions: Array<SwapQuoteTransaction>
    ) = channelFlow<SwapTransactionStatusPreview> {
        send(createSendingStatusPreview(resources, swapQuote))
        sendSwapTransactionsManager.sendSwapTransactions(
            signedTransactions = signedTransactions.toMutableList(),
            onSendTransactionsSuccess = {
                send(createCompletedStatusPreview(resources, swapQuote, signedTransactions))
                logSwapSuccessEvent(swapQuote, signedTransactions)
            },
            onSendTransactionsFailed = {
                send(
                    createFailedStatusPreview(
                        resources = resources,
                        swapQuote = swapQuote
                    )
                )
                logSwapFailureEvent(swapQuote)
            }
        )
    }

    private suspend fun logSwapSuccessEvent(swapQuote: SwapQuote, signedTransactions: Array<SwapQuoteTransaction>) {
        val algorandTransactionFee = getAlgorandTransactionFees(signedTransactions)
        val optInTransactionFee = getOptInTransactionFees(signedTransactions)
        val totalNetworkFee = algorandTransactionFee + optInTransactionFee
        swapTransactionEventTrackingUseCase.logSuccessTransactionEvent(swapQuote, totalNetworkFee)
    }

    private suspend fun logSwapFailureEvent(swapQuote: SwapQuote) {
        swapTransactionEventTrackingUseCase.logFailureTransactionEvent(swapQuote)
    }

    fun updatePreviewWithNavigateBack(previousState: SwapTransactionStatusPreview): SwapTransactionStatusPreview {
        return previousState.copy(
            navigateBackEvent = Event(Unit)
        )
    }

    fun updatePreviewForTryAgain(previousState: SwapTransactionStatusPreview): SwapTransactionStatusPreview {
        return previousState.copy(
            navigateToAssetSwapFragmentEvent = Event(Unit)
        )
    }

    fun getNetworkSlug(): String? {
        return networkSlugUseCase.getActiveNodeSlug()
    }

    private fun createSendingStatusPreview(resources: Resources, swapQuote: SwapQuote): SwapTransactionStatusPreview {
        val formattedAmount = swapQuote.getFormattedMinimumReceivedAmount()
        val formattedAmountAndAsset = "$formattedAmount ${swapQuote.toAssetDetail.shortName.getName(resources)}"
        return swapTransactionStatusPreviewMapper.mapToSwapTransactionStatusPreview(
            swapTransactionStatusType = SwapTransactionStatusType.SENDING,
            transactionStatusAnimationResId = R.raw.transaction_sending_animation,
            transactionStatusAnimationBackgroundResId = R.drawable.bg_layer_gray_lighter_oval,
            transactionStatusAnimationBackgroundTintResId = R.color.black,
            transactionStatusTitleAnnotatedString = AnnotatedString(
                stringResId = R.string.sending_the_transaction
            ),
            transactionStatusDescriptionAnnotatedString = AnnotatedString(
                stringResId = R.string.you_will_receive_at_least,
                replacementList = listOf("amount_and_asset_name" to formattedAmountAndAsset)
            ),
            isTransactionDetailGroupVisible = false,
            isPrimaryActionButtonVisible = false,
            isGoToHomepageButtonVisible = false
        )
    }

    private fun createCompletedStatusPreview(
        resources: Resources,
        swapQuote: SwapQuote,
        signedTransactions: Array<SwapQuoteTransaction>
    ): SwapTransactionStatusPreview {
        with(swapQuote) {
            val toAssetName = toAssetDetail.shortName.getName(resources)
            val fromAssetName = fromAssetDetail.shortName.getName(resources)
            val formattedToAmount = getFormattedReceivedAssetAmount(signedTransactions, this)
            val formattedFromAmount = fromAssetAmount.movePointLeft(fromAssetDetail.fractionDecimals)
                .formatAmount(fromAssetDetail.fractionDecimals, isDecimalFixed = false)
            val txnGroupId = signedTransactions.firstOrNull { it is SwapTransaction }?.transactionGroupId
            val annotatedDescriptionTextColor = ResourcesCompat.getColor(resources, R.color.text_main, null)
            return swapTransactionStatusPreviewMapper.mapToSwapTransactionStatusPreview(
                swapTransactionStatusType = SwapTransactionStatusType.COMPLETED,
                transactionStatusAnimationDrawableResId = R.drawable.ic_check,
                transactionStatusAnimationDrawableTintResId = R.color.background,
                transactionStatusAnimationBackgroundResId = R.drawable.bg_layer_gray_lighter_oval,
                transactionStatusAnimationBackgroundTintResId = R.color.success,
                transactionStatusTitleAnnotatedString = AnnotatedString(
                    stringResId = R.string.asset_pair_swap_completed,
                    replacementList = listOf(
                        "to_asset_name" to toAssetName,
                        "from_asset_name" to fromAssetName
                    )
                ),
                transactionStatusDescriptionAnnotatedString = AnnotatedString(
                    stringResId = R.string.you_received_amount_asset_name_in,
                    replacementList = listOf(
                        "to_amount_and_asset_name" to "$formattedToAmount $toAssetName",
                        "from_amount_and_asset_name" to "$formattedFromAmount $fromAssetName"
                    ),
                    customAnnotationList = listOf(
                        "received_asset_color" to ForegroundColorSpan(annotatedDescriptionTextColor),
                        "paid_asset_color" to ForegroundColorSpan(annotatedDescriptionTextColor)
                    )
                ),
                isTransactionDetailGroupVisible = true,
                urlEncodedTransactionGroupId = txnGroupId?.encodeToURL(),
                isPrimaryActionButtonVisible = true,
                isGoToHomepageButtonVisible = false,
                primaryActionButtonTextResId = R.string.done
            )
        }
    }

    private fun createFailedStatusPreview(
        resources: Resources,
        swapQuote: SwapQuote
    ): SwapTransactionStatusPreview {
        return swapTransactionStatusPreviewMapper.mapToSwapTransactionStatusPreview(
            swapTransactionStatusType = SwapTransactionStatusType.FAILED,
            transactionStatusAnimationDrawableResId = R.drawable.ic_close,
            transactionStatusAnimationDrawableTintResId = R.color.background,
            transactionStatusAnimationBackgroundResId = R.drawable.bg_layer_gray_lighter_oval,
            transactionStatusAnimationBackgroundTintResId = R.color.negative,
            transactionStatusTitleAnnotatedString = AnnotatedString(
                stringResId = R.string.asset_pair_swap_has_failed,
                replacementList = listOf(
                    "to_asset_name" to swapQuote.toAssetDetail.shortName.getName(resources),
                    "from_asset_name" to swapQuote.fromAssetDetail.shortName.getName(resources)
                )
            ),
            transactionStatusDescriptionAnnotatedString = AnnotatedString(R.string.we_encountered_an_unexpected),
            isTransactionDetailGroupVisible = false,
            isPrimaryActionButtonVisible = true,
            isGoToHomepageButtonVisible = true,
            primaryActionButtonTextResId = R.string.try_again,
            secondaryActionButtonTextResId = R.string.go_to_homepage
        )
    }

    fun getAlgorandTransactionFees(transactions: Array<SwapQuoteTransaction>): Long {
        var transactionFees: Long = 0
        transactions.forEach { swapQuoteTransaction ->
            swapQuoteTransaction.unsignedTransactions.forEach { unsignedTransaction ->
                transactionFees += unsignedTransaction.decodedTransaction?.fee ?: 0L
            }
        }
        return transactionFees
    }

    fun getOptInTransactionFees(transactions: Array<SwapQuoteTransaction>): Long {
        var transactionFees: Long = 0
        transactions.forEach { swapQuoteTransaction ->
            if (swapQuoteTransaction is SwapQuoteTransaction.OptInTransaction) {
                swapQuoteTransaction.unsignedTransactions.forEach {
                    transactionFees += it.decodedTransaction?.fee ?: 0L
                }
            }
        }
        return transactionFees
    }

    private fun getFormattedReceivedAssetAmount(
        signedTransactions: Array<SwapQuoteTransaction>,
        swapQuote: SwapQuote
    ): String {
        val swapTransaction = signedTransactions.firstOrNull { it is SwapTransaction } as? SwapTransaction
        var receivedAssetAmount: BigInteger? = null
        swapTransaction?.unsignedTransactions?.forEach {
            if (it.decodedTransaction?.receiverAddress?.decodedAddress == it.accountAddress) {
                receivedAssetAmount = it.decodedTransaction.amount?.toBigInteger() ?: BigInteger.ZERO
                return@forEach
            } else if (it.decodedTransaction?.assetReceiverAddress?.decodedAddress == it.accountAddress) {
                receivedAssetAmount = it.decodedTransaction.assetAmount ?: BigInteger.ZERO
                return@forEach
            }
        }

        val receivedAssetDecimal = swapQuote.toAssetDetail.fractionDecimals
        return receivedAssetAmount
            ?.toBigDecimal()
            ?.movePointLeft(receivedAssetDecimal)
            ?.formatAmount(receivedAssetDecimal, isDecimalFixed = false)
            ?: swapQuote.getFormattedMinimumReceivedAmount()
    }
}
