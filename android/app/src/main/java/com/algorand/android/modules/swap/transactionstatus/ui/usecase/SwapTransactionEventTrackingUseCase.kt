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

import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote
import com.algorand.android.modules.tracking.swap.swapstatus.AssetSwapFailureEventTracker
import com.algorand.android.modules.tracking.swap.swapstatus.AssetSwapSuccessEventTracker
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.DATE_AND_TIME_PATTERN
import com.algorand.android.utils.TWO_DECIMALS
import com.algorand.android.utils.getUTCZonedDateTime
import java.math.BigDecimal
import java.math.RoundingMode
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.util.Locale
import javax.inject.Inject

class SwapTransactionEventTrackingUseCase @Inject constructor(
    private val swapSuccessEventTracker: AssetSwapSuccessEventTracker,
    private val swapFailureEventTracker: AssetSwapFailureEventTracker,
    private val parityUseCase: ParityUseCase
) {

    suspend fun logSuccessTransactionEvent(swapQuote: SwapQuote, networkFee: Long) {
        val currentTimeUTC = getCurrentTimeUTC()
        with(swapQuote) {
            swapSuccessEventTracker.logSuccessSwapEvent(
                swapQuote = this,
                inputAsaAmountAsAlgo = getAssetAmountAsAlgo(
                    fromAssetAmountInUsdValue,
                    fromAssetAmount,
                    fromAssetDetail.fractionDecimals,
                    isFromAssetAlgo
                ),
                inputAsaAmountAsUsd = getInputAsaAmountAsUsd(this),
                inputAsaAmount = getInputAsaAmount(this),
                outputAsaAmountAsAlgo = getAssetAmountAsAlgo(
                    toAssetAmountInUsdValue,
                    toAssetAmount,
                    toAssetDetail.fractionDecimals,
                    isToAssetAlgo
                ),
                outputAsaAmountAsUsd = getOutputAsaAmountAsUsd(this),
                outputAsaAmount = getOutputAsaAmount(this),
                swapDateTimestamp = currentTimeUTC.toInstant().toEpochMilli(),
                formattedSwapDateTime = getFormattedSwapDateTime(currentTimeUTC),
                peraFeeAsUsd = getPeraFeeAsUsd(peraFeeAmount),
                peraFeeAsAlgo = getPeraFeeAsAlgo(peraFeeAmount),
                exchangeFeeAsAlgo = getExchangeFeeAsAlgo(swapQuote),
                networkFeeAsAlgo = getNetworkFeeAsAlgo(networkFee)
            )
        }
    }

    suspend fun logFailureTransactionEvent(swapQuote: SwapQuote) {
        val currentTimeUTC = getCurrentTimeUTC()
        with(swapQuote) {
            swapFailureEventTracker.logFailureSwapEvent(
                swapQuote = this,
                inputAsaAmountAsAlgo = getAssetAmountAsAlgo(
                    fromAssetAmountInUsdValue,
                    fromAssetAmount,
                    fromAssetDetail.fractionDecimals,
                    isFromAssetAlgo
                ),
                inputAsaAmountAsUsd = getInputAsaAmountAsUsd(this),
                outputAsaAmountAsAlgo = getAssetAmountAsAlgo(
                    toAssetAmountInUsdValue,
                    toAssetAmount,
                    toAssetDetail.fractionDecimals,
                    isToAssetAlgo
                ),
                outputAsaAmountAsUsd = getOutputAsaAmountAsUsd(this),
                swapDateTimestamp = currentTimeUTC.toInstant().toEpochMilli(),
                formattedSwapDateTime = getFormattedSwapDateTime(currentTimeUTC)
            )
        }
    }

    private fun getCurrentTimeUTC() = getUTCZonedDateTime()

    private fun getFormattedSwapDateTime(zonedDateTime: ZonedDateTime): String {
        return zonedDateTime.format(DateTimeFormatter.ofPattern(DATE_AND_TIME_PATTERN, Locale.ENGLISH))
    }

    private fun getAssetAmountAsAlgo(
        swappedAssetUsdValue: BigDecimal,
        swappedAssetAmount: BigDecimal,
        assetDecimal: Int,
        isAlgo: Boolean
    ): Double {
        return if (isAlgo) {
            swappedAssetAmount.movePointLeft(ALGO_DECIMALS)
        } else {
            val usdToAlgoRatio = parityUseCase.getUsdToAlgoConversionRate()
            val assetUnitUsdValue = swappedAssetAmount
                .movePointLeft(assetDecimal)
                .multiply(swappedAssetUsdValue)
                .setScale(TWO_DECIMALS, calculationRoundingMode)
            assetUnitUsdValue.multiply(usdToAlgoRatio).setScale(assetDecimal, calculationRoundingMode)
        }.stripTrailingZeros().toDouble()
    }

    private fun getPeraFeeAsUsd(peraFeeAsAlgo: BigDecimal): Double {
        val algoToUsdConversionRatio = parityUseCase.getAlgoToUsdConversionRate()
        return peraFeeAsAlgo
            .multiply(algoToUsdConversionRatio)
            .setScale(TWO_DECIMALS, calculationRoundingMode)
            .stripTrailingZeros()
            .toDouble()
    }

    private fun getPeraFeeAsAlgo(peraFeeAsAlgo: BigDecimal): Double {
        return peraFeeAsAlgo.stripTrailingZeros().toDouble()
    }

    private fun getExchangeFeeAsAlgo(swapQuote: SwapQuote): Double {
        return with(swapQuote) {
            if (isFromAssetAlgo) {
                exchangeFeeAmount
            } else {
                val usdToAlgoRatio = parityUseCase.getUsdToAlgoConversionRate()
                val assetUnitUsdValue = fromAssetAmount
                    .movePointLeft(fromAssetDetail.fractionDecimals)
                    .multiply(fromAssetAmountInUsdValue)
                val exchangeFeeAsUsd = exchangeFeeAmount.multiply(assetUnitUsdValue)
                exchangeFeeAsUsd
                    .multiply(usdToAlgoRatio)
                    .setScale(fromAssetDetail.fractionDecimals, calculationRoundingMode)
            }
        }.stripTrailingZeros().toDouble()
    }

    private fun getInputAsaAmountAsUsd(swapQuote: SwapQuote): Double {
        return swapQuote.fromAssetAmountInUsdValue
            .setScale(TWO_DECIMALS, calculationRoundingMode)
            .stripTrailingZeros()
            .toDouble()
    }

    private fun getOutputAsaAmountAsUsd(swapQuote: SwapQuote): Double {
        return swapQuote.toAssetAmountInUsdValue
            .setScale(TWO_DECIMALS, calculationRoundingMode)
            .stripTrailingZeros()
            .toDouble()
    }

    private fun getInputAsaAmount(swapQuote: SwapQuote): Double {
        return swapQuote.fromAssetAmount
            .movePointLeft(swapQuote.fromAssetDetail.fractionDecimals)
            .stripTrailingZeros()
            .toDouble()
    }

    private fun getOutputAsaAmount(swapQuote: SwapQuote): Double {
        return swapQuote.toAssetAmount
            .movePointLeft(swapQuote.toAssetDetail.fractionDecimals)
            .stripTrailingZeros()
            .toDouble()
    }

    private fun getNetworkFeeAsAlgo(networkFee: Long): Double {
        return networkFee.toBigDecimal()
            .movePointLeft(ALGO_DECIMALS)
            .stripTrailingZeros()
            .toDouble()
    }

    companion object {
        private val calculationRoundingMode = RoundingMode.DOWN
    }
}
