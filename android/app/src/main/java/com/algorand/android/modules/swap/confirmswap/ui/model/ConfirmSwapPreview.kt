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

package com.algorand.android.modules.swap.confirmswap.ui.model

import android.content.res.Resources
import com.algorand.android.assetsearch.ui.model.VerificationTierConfiguration
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapQuoteTransaction
import com.algorand.android.modules.swap.ledger.signwithledger.ui.model.LedgerDialogPayload
import com.algorand.android.modules.swap.utils.priceratioprovider.SwapPriceRatioProvider
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.ErrorResource
import com.algorand.android.utils.Event
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider

data class ConfirmSwapPreview(
    val fromAssetDetail: SwapAssetDetail,
    val toAssetDetail: SwapAssetDetail,
    val slippageTolerance: String,
    val formattedPriceImpact: String,
    val minimumReceived: AnnotatedString,
    val formattedExchangeFee: String,
    val formattedPeraFee: String,
    val swapQuote: SwapQuote,
    val isLoading: Boolean,
    val priceImpactWarningStatus: ConfirmSwapPriceImpactWarningStatus,
    val accountIconResource: AccountIconResource,
    val accountDisplayName: AccountDisplayName,
    val errorEvent: Event<ErrorResource>? = null,
    val slippageToleranceUpdateSuccessEvent: Event<Unit>? = null,
    val navigateToTransactionStatusFragmentEvent: Event<List<SwapQuoteTransaction>>? = null,
    val navigateToLedgerWaitingForApprovalDialogEvent: Event<LedgerDialogPayload>? = null,
    val navigateToLedgerNotFoundDialogEvent: Event<Unit>? = null,
    val dismissLedgerWaitingForApprovalDialogEvent: Event<Unit>? = null,
    val navToSwapConfirmationBottomSheetEvent: Event<Long>? = null,
    private val priceRatioProvider: SwapPriceRatioProvider
) {

    fun getPriceRatio(resources: Resources): AnnotatedString {
        return priceRatioProvider.getRatioState(resources)
    }

    fun getSwitchedPriceRatio(resources: Resources): AnnotatedString {
        return priceRatioProvider.getSwitchedRatioState(resources)
    }

    data class SwapAssetDetail(
        val formattedAmount: String,
        val formattedApproximateValue: String,
        val shortName: AssetName,
        val assetDrawableProvider: BaseAssetDrawableProvider,
        val verificationTierConfig: VerificationTierConfiguration,
        val amountTextColorResId: Int,
        val approximateValueTextColorResId: Int
    )
}
