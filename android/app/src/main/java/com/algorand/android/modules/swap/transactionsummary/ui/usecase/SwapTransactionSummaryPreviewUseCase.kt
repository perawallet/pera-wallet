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

package com.algorand.android.modules.swap.transactionsummary.ui.usecase

import android.content.res.Resources
import com.algorand.android.R
import com.algorand.android.models.AccountIconResource
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.currency.domain.model.Currency
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote
import com.algorand.android.modules.swap.transactionsummary.ui.mapper.BaseSwapTransactionSummaryItemMapper
import com.algorand.android.modules.swap.transactionsummary.ui.mapper.SwapTransactionSummaryPreviewMapper
import com.algorand.android.modules.swap.transactionsummary.ui.model.BaseSwapTransactionSummaryItem
import com.algorand.android.modules.swap.transactionsummary.ui.model.BaseSwapTransactionSummaryItem.SwapAccountItemTransaction
import com.algorand.android.modules.swap.transactionsummary.ui.model.BaseSwapTransactionSummaryItem.SwapAmountsItemTransaction
import com.algorand.android.modules.swap.transactionsummary.ui.model.BaseSwapTransactionSummaryItem.SwapFeesItemTransaction
import com.algorand.android.modules.swap.transactionsummary.ui.model.BaseSwapTransactionSummaryItem.SwapPriceImpactItemTransaction
import com.algorand.android.modules.transaction.detail.domain.model.TransactionSign
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.formatAsAlgoAmount
import com.algorand.android.utils.formatAsAssetAmount
import com.algorand.android.utils.formatAsCurrency
import com.algorand.android.utils.isGreaterThan
import java.math.BigDecimal
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

class SwapTransactionSummaryPreviewUseCase @Inject constructor(
    private val swapTransactionSummaryPreviewMapper: SwapTransactionSummaryPreviewMapper,
    private val baseSwapTransactionSummaryItemMapper: BaseSwapTransactionSummaryItemMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val getAccountDisplayNameUseCase: AccountDisplayNameUseCase
) {

    fun getSwapSummaryPreview(
        resources: Resources,
        swapQuote: SwapQuote,
        algorandTransactionFees: Long,
        optInTransactionFees: Long
    ) = flow {
        val swapSummaryListItems = mutableListOf<BaseSwapTransactionSummaryItem>(
            createSwapAmountsItem(resources, swapQuote),
            createSwapAccountItem(swapQuote),
            createSwapFeesItem(swapQuote, algorandTransactionFees, optInTransactionFees),
            createSwapPriceImpactItem(swapQuote)
        )
        val swapSummaryPreview = swapTransactionSummaryPreviewMapper.mapToSwapSummaryPreview(
            baseSwapTransactionSummaryItems = swapSummaryListItems
        )
        emit(swapSummaryPreview)
    }

    private fun createSwapAmountsItem(resources: Resources, swapQuote: SwapQuote): SwapAmountsItemTransaction {
        with(swapQuote) {
            val fromAssetFractionalDigit = fromAssetDetail.fractionDecimals
            val toAssetFractionalDigit = toAssetDetail.fractionDecimals
            val formattedReceivedAmount = toAssetAmount
                .movePointLeft(toAssetFractionalDigit)
                .formatAmount(toAssetFractionalDigit, isDecimalFixed = false)
                .formatAsAssetAmount(
                    assetShortName = getAssetSymbol(resources, isToAssetAlgo, toAssetDetail.shortName),
                    transactionSign = TransactionSign.POSITIVE.signTextRes?.run { resources.getString(this) }
                )
            return baseSwapTransactionSummaryItemMapper.mapToSwapAmountsItem(
                formattedReceivedAmount = resources.getString(
                    R.string.approximate_currency_value,
                    formattedReceivedAmount
                ),
                formattedPaidAmount = fromAssetAmount
                    .movePointLeft(fromAssetFractionalDigit)
                    .formatAmount(fromAssetFractionalDigit, isDecimalFixed = false)
                    .run {
                        val transactionSign = TransactionSign.NEGATIVE.signTextRes?.run { resources.getString(this) }
                        if (isFromAssetAlgo) {
                            formatAsAlgoAmount(transactionSign)
                        } else {
                            formatAsAssetAmount(
                                assetShortName = getAssetSymbol(resources, isFromAssetAlgo, fromAssetDetail.shortName),
                                transactionSign = transactionSign
                            )
                        }
                    }
            )
        }
    }

    private fun createSwapAccountItem(swapQuote: SwapQuote): SwapAccountItemTransaction {
        val accountDetail = accountDetailUseCase.getCachedAccountDetail(swapQuote.accountAddress)?.data
        val safeAccountAddress = accountDetail?.account?.address ?: swapQuote.accountAddress
        val accountDisplayName = getAccountDisplayNameUseCase.invoke(safeAccountAddress)
        val accountIconResource = AccountIconResource.getAccountIconResourceByAccountType(accountDetail?.account?.type)
        return baseSwapTransactionSummaryItemMapper.mapToSwapAccountItem(
            accountDisplayName = accountDisplayName,
            accountIconResource = accountIconResource
        )
    }

    private fun createSwapFeesItem(
        swapQuote: SwapQuote,
        algorandTransactionFees: Long,
        optInTransactionFees: Long
    ): SwapFeesItemTransaction {
        val peraFee = swapQuote.peraFeeAmount
        val exchangeFee = swapQuote.exchangeFeeAmount
        val formattedAlgorandTransactionFee = algorandTransactionFees
            .toBigDecimal()
            .movePointLeft(ALGO_DECIMALS)
            .formatAsCurrency(Currency.ALGO.symbol)
        val formattedOptInTransactionFee = optInTransactionFees
            .toBigDecimal()
            .movePointLeft(ALGO_DECIMALS)
            .formatAsCurrency(Currency.ALGO.symbol)
        val formattedExchangeFee = exchangeFee.formatAsCurrency(Currency.ALGO.symbol)
        val formattedPeraFee = peraFee.formatAsCurrency(Currency.ALGO.symbol)
        return baseSwapTransactionSummaryItemMapper.mapToSwapFeesItem(
            formattedAlgorandFees = formattedAlgorandTransactionFee,
            formattedOptInFees = formattedOptInTransactionFee,
            isOptInFeesVisible = optInTransactionFees > 0L,
            formattedExchangeFees = formattedExchangeFee,
            isExchangeFeesVisible = exchangeFee isGreaterThan BigDecimal.ZERO,
            formattedPeraFees = formattedPeraFee,
            isPeraFeeVisible = peraFee isGreaterThan BigDecimal.ZERO
        )
    }

    private fun createSwapPriceImpactItem(swapQuote: SwapQuote): SwapPriceImpactItemTransaction {
        return baseSwapTransactionSummaryItemMapper.mapToSwapPriceImpactItem(swapQuote.priceImpact.toString())
    }

    private fun getAssetSymbol(resources: Resources, isAlgo: Boolean, assetName: AssetName): String {
        return if (isAlgo) Currency.ALGO.symbol else assetName.getName(resources)
    }
}
