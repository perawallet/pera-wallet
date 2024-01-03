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

package com.algorand.android.modules.swap.assetswap.domain.usecase

import com.algorand.android.deviceregistration.domain.usecase.DeviceIdUseCase
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.modules.parity.domain.model.ParityValue
import com.algorand.android.modules.parity.utils.ParityUtils
import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapType
import com.algorand.android.modules.swap.assetswap.data.utils.getSafeAssetIdForRequest
import com.algorand.android.modules.swap.assetswap.domain.mapper.SwapQuoteAssetDetailMapper
import com.algorand.android.modules.swap.assetswap.domain.mapper.SwapQuoteMapper
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuote
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuoteAssetDetail
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuoteProvider
import com.algorand.android.modules.swap.assetswap.domain.model.dto.SwapQuoteAssetDetailDTO
import com.algorand.android.modules.swap.assetswap.domain.model.dto.SwapQuoteDTO
import com.algorand.android.modules.swap.assetswap.domain.repository.AssetSwapRepository
import com.algorand.android.modules.swap.common.SwapAppxValueParityHelper
import com.algorand.android.modules.swap.utils.defaultExchangeSwapFee
import com.algorand.android.modules.swap.utils.defaultPeraSwapFee
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.toBigDecimalOrZero
import com.algorand.android.utils.toBigIntegerOrZero
import com.algorand.android.utils.toFloatOrZero
import java.math.BigInteger
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map

class GetSwapQuoteUseCase @Inject constructor(
    @Named(AssetSwapRepository.INJECTION_NAME)
    private val assetSwapRepository: AssetSwapRepository,
    private val swapQuoteMapper: SwapQuoteMapper,
    private val swapQuoteAssetDetailMapper: SwapQuoteAssetDetailMapper,
    private val deviceIdUseCase: DeviceIdUseCase,
    private val swapAppxValueParityHelper: SwapAppxValueParityHelper
) {

    suspend fun getSwapQuote(
        fromAssetId: Long,
        toAssetId: Long,
        amount: BigInteger,
        accountAddress: String,
        slippage: Float
    ) = flow<DataResource<SwapQuote>> {
        emit(DataResource.Loading())
        val safeFromAssetId = getSafeAssetIdForRequest(fromAssetId)
        val safeToAssetId = getSafeAssetIdForRequest(toAssetId)
        val deviceId = deviceIdUseCase.getSelectedNodeDeviceId().orEmpty()
        val providers = SwapQuoteProvider.getProviders() // TODO Get this from UI when design is ready
        val swapType = SwapType.getDefaultSwapType()
        assetSwapRepository.getSwapQuote(
            safeFromAssetId,
            safeToAssetId,
            amount,
            swapType,
            accountAddress,
            deviceId,
            slippage,
            providers
        ).map { result ->
            result.use(
                onSuccess = { swapQuoteDto ->
                    val swapQuote = mapSwapQuoteOrNull(swapQuoteDto, swapType)
                    if (swapQuote == null) {
                        emit(DataResource.Error.Local(IllegalArgumentException())) // TODO Use proper exception
                    } else {
                        emit(DataResource.Success(swapQuote))
                    }
                },
                onFailed = { exception, code ->
                    emit(DataResource.Error.Api(exception, code))
                }
            )
        }.collect()
    }

    private fun mapSwapQuoteOrNull(swapQuoteDto: SwapQuoteDTO, swapType: SwapType): SwapQuote? {
        return with(swapQuoteDto) {
            swapQuoteMapper.mapToSwapQuote(
                swapQuoteDTO = this,
                quoteId = id ?: return null,
                swapType = swapType,
                fromAssetDetail = mapSwapQuoteAssetDetail(swapQuoteDto.assetInAssetDetail) ?: return null,
                toAssetDetail = mapSwapQuoteAssetDetail(swapQuoteDto.assetOutAssetDetail) ?: return null,
                fromAssetAmount = swapQuoteDto.assetInAmount.toBigDecimalOrZero(),
                toAssetAmount = swapQuoteDto.assetOutAmount.toBigDecimalOrZero(),
                fromAssetAmountInUsdValue = swapQuoteDto.assetInAmountInUsdValue.toBigDecimalOrZero(),
                fromAssetAmountInSelectedCurrency = getFromAssetAmountInSelectedCurrency(swapQuoteDto),
                fromAssetAmountWithSlippage = swapQuoteDto.assetInAmountWithSlippage.toBigDecimalOrZero(),
                toAssetAmountInUsdValue = swapQuoteDto.assetOutAmountInUsdValue.toBigDecimalOrZero(),
                toAssetAmountInSelectedCurrency = getToAssetAmountInSelectedCurrency(swapQuoteDto),
                toAssetAmountWithSlippage = swapQuoteDto.assetOutAmountWithSlippage.toBigDecimalOrZero(),
                slippage = swapQuoteDto.slippage.toFloatOrZero() * SLIPPAGE_TOLERANCE_RESPONSE_MULTIPLIER,
                price = swapQuoteDto.price.toFloatOrZero(),
                priceImpact = swapQuoteDto.priceImpact.toFloatOrZero() * PRICE_IMPACT_RESPONSE_MULTIPLIER,
                peraFeeAmount = swapQuoteDto.peraFeeAmount?.movePointLeft(ALGO_DECIMALS) ?: defaultPeraSwapFee,
                exchangeFeeAmount = swapQuoteDto.exchangeFeeAmount?.movePointLeft(
                    swapQuoteDto.assetInAssetDetail?.fractionDecimals ?: DEFAULT_ASSET_DECIMAL_FOR_SWAP
                ) ?: defaultExchangeSwapFee,
                swapperAddress = swapperAddress ?: return null
            )
        }
    }

    private fun getFromAssetAmountInSelectedCurrency(swapQuoteDto: SwapQuoteDTO): ParityValue {
        return with(swapQuoteDto) {
            val usdValuePerAsset = ParityUtils.getUsdValuePerAsset(
                assetAmount = assetInAmount,
                assetDecimal = assetInAssetDetail?.fractionDecimals,
                totalAssetAmountInUsdValue = assetInAmountInUsdValue
            )
            swapAppxValueParityHelper.getDisplayedParityCurrencyValue(
                assetAmount = assetInAmount.toBigIntegerOrZero(),
                assetUsdValue = usdValuePerAsset,
                assetDecimal = assetInAssetDetail?.fractionDecimals ?: DEFAULT_ASSET_DECIMAL_FOR_SWAP,
                assetId = assetInAssetDetail?.assetId ?: FALLBACK_ASSET_ID_FOR_QUOTE
            )
        }
    }

    private fun getToAssetAmountInSelectedCurrency(swapQuoteDto: SwapQuoteDTO): ParityValue {
        return with(swapQuoteDto) {
            val usdValuePerAsset = ParityUtils.getUsdValuePerAsset(
                assetAmount = assetOutAmount,
                assetDecimal = assetOutAssetDetail?.fractionDecimals,
                totalAssetAmountInUsdValue = assetOutAmountInUsdValue
            )
            swapAppxValueParityHelper.getDisplayedParityCurrencyValue(
                assetAmount = assetOutAmount.toBigIntegerOrZero(),
                assetUsdValue = usdValuePerAsset,
                assetDecimal = assetOutAssetDetail?.fractionDecimals ?: DEFAULT_ASSET_DECIMAL_FOR_SWAP,
                assetId = assetOutAssetDetail?.assetId ?: FALLBACK_ASSET_ID_FOR_QUOTE
            )
        }
    }

    private fun mapSwapQuoteAssetDetail(dto: SwapQuoteAssetDetailDTO?): SwapQuoteAssetDetail? {
        if (dto == null) return null
        return swapQuoteAssetDetailMapper.mapToSwapQuoteAssetDetail(
            dto = dto,
            assetId = dto.assetId ?: return null,
            fractionDecimals = dto.fractionDecimals ?: DEFAULT_ASSET_DECIMAL_FOR_SWAP,
            usdValue = dto.usdValue.toBigDecimalOrZero()
        )
    }

    companion object {
        private const val SLIPPAGE_TOLERANCE_RESPONSE_MULTIPLIER = 100f
        private const val PRICE_IMPACT_RESPONSE_MULTIPLIER = 100f
        private const val DEFAULT_ASSET_DECIMAL_FOR_SWAP = DEFAULT_ASSET_DECIMAL
        private const val FALLBACK_ASSET_ID_FOR_QUOTE = ALGO_ID
    }
}
