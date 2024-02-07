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

package com.algorand.android.modules.swap.assetswap.data.repository

import com.algorand.android.models.Result
import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapType
import com.algorand.android.modules.swap.assetswap.data.mapper.PeraFeeDTOMapper
import com.algorand.android.modules.swap.assetswap.data.mapper.PeraFeeRequestBodyMapper
import com.algorand.android.modules.swap.assetswap.data.mapper.SwapQuoteDTOMapper
import com.algorand.android.modules.swap.assetswap.data.mapper.SwapQuoteRequestBodyMapper
import com.algorand.android.modules.swap.assetswap.data.mapper.decider.SwapQuoteProviderResponseDecider
import com.algorand.android.modules.swap.assetswap.data.model.SwapQuoteExceptionRequestBody
import com.algorand.android.modules.swap.assetswap.data.model.SwapQuoteRequestBody
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuoteProvider
import com.algorand.android.modules.swap.assetswap.domain.model.dto.PeraFeeDTO
import com.algorand.android.modules.swap.assetswap.domain.model.dto.SwapQuoteDTO
import com.algorand.android.modules.swap.assetswap.domain.repository.AssetSwapRepository
import com.algorand.android.modules.swap.confirmswap.data.mapper.CreateSwapQuoteTransactionsRequestBodyMapper
import com.algorand.android.modules.swap.confirmswap.data.mapper.SwapQuoteTransactionDTOMapper
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapQuoteTransactionDTO
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import java.math.BigInteger
import javax.inject.Inject

class AssetSwapRepositoryImpl @Inject constructor(
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val hipoErrorHandler: RetrofitErrorHandler,
    private val swapQuoteDTOMapper: SwapQuoteDTOMapper,
    private val swapQuoteRequestBodyMapper: SwapQuoteRequestBodyMapper,
    private val swapQuoteProviderResponseDecider: SwapQuoteProviderResponseDecider,
    private val peraFeeRequestBodyMapper: PeraFeeRequestBodyMapper,
    private val peraFeeDTOMapper: PeraFeeDTOMapper,
    private val swapQuoteTransactionDTOMapper: SwapQuoteTransactionDTOMapper,
    private val createSwapQuoteTransactionsRequestBodyMapper: CreateSwapQuoteTransactionsRequestBodyMapper
) : AssetSwapRepository {

    override suspend fun getSwapQuote(
        fromAssetId: Long,
        toAssetId: Long,
        amount: BigInteger,
        swapType: SwapType,
        accountAddress: String,
        deviceId: String,
        slippage: Float?,
        providers: List<SwapQuoteProvider>
    ): Flow<Result<SwapQuoteDTO>> = flow {
        val providersResponse = providers.map {
            swapQuoteProviderResponseDecider.decideSwapQuoteProviderResponse(it)
        }.mapNotNull { it.value }
        val requestBody = swapQuoteRequestBodyMapper.mapToSwapQuoteRequestBody(
            providersList = providersResponse,
            swapperAccountAddress = accountAddress,
            swapType = swapType,
            deviceId = deviceId,
            fromAssetId = fromAssetId,
            toAssetId = toAssetId,
            amount = amount,
            slippage = slippage
        )

        val swapQuoteDto = getSwapQuoteDTO(requestBody)
        emit(swapQuoteDto)
    }

    override suspend fun getPeraFee(fromAssetId: Long, amount: BigInteger): Flow<Result<PeraFeeDTO>> = flow {
        val requestBody = peraFeeRequestBodyMapper.mapToPeraFeeRequestBody(fromAssetId, amount)
        requestWithHipoErrorHandler(hipoErrorHandler) {
            mobileAlgorandApi.getPeraFee(requestBody)
        }.use(
            onSuccess = { peraFeeResponse ->
                val peraFeeDTO = peraFeeDTOMapper.mapToPeraFeeDTO(peraFeeResponse.peraFeeAmount)
                emit(Result.Success(peraFeeDTO))
            },
            onFailed = { exception, code ->
                emit(Result.Error(exception, code))
            }
        )
    }

    override suspend fun createQuoteTransactions(quoteId: Long): Flow<Result<List<SwapQuoteTransactionDTO>>> = flow {
        val requestBody = createSwapQuoteTransactionsRequestBodyMapper
            .mapToCreateSwapQuoteTransactionsRequestBody(quoteId)
        requestWithHipoErrorHandler(hipoErrorHandler) {
            mobileAlgorandApi.getQuoteTransactions(requestBody)
        }.use(
            onSuccess = { createSwapQuoteTransactionResponse ->
                val swapQuoteTransactions = createSwapQuoteTransactionResponse.transactionGroups?.map {
                    swapQuoteTransactionDTOMapper.mapToSwapQuoteTransactionDTO(it)
                }
                if (swapQuoteTransactions == null || swapQuoteTransactions.isEmpty()) {
                    emit(Result.Error(IllegalStateException()))
                } else {
                    emit(Result.Success(swapQuoteTransactions))
                }
            },
            onFailed = { exception, code ->
                emit(Result.Error(exception, code))
            }
        )
    }

    private suspend fun getSwapQuoteDTO(requestBody: SwapQuoteRequestBody): Result<SwapQuoteDTO> {
        var result: Result<SwapQuoteDTO>? = null
        requestWithHipoErrorHandler(hipoErrorHandler) {
            mobileAlgorandApi.getSwapQuote(requestBody)
        }.use(
            onSuccess = { response ->
                val swapQuoteResponse = response.swapQuoteResponseList.firstOrNull()
                result = if (swapQuoteResponse == null) {
                    Result.Error(IllegalArgumentException())
                } else {
                    val swapQuoteDTO = swapQuoteDTOMapper.mapToSwapQuoteDTO(swapQuoteResponse)
                    Result.Success(swapQuoteDTO)
                }
            },
            onFailed = { exception, code ->
                result = Result.Error(exception, code)
            }
        )
        return result ?: Result.Error(NullPointerException())
    }
    override suspend fun updateSwapQuoteException(quoteId: Long, exceptionText: String?) {
        requestWithHipoErrorHandler(hipoErrorHandler) {
            mobileAlgorandApi.putSwapQuoteException(
                quoteId, swapQuoteExceptionRequestBody = SwapQuoteExceptionRequestBody(
                    exceptionText = exceptionText
                )
            )
        }
    }
}
