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

import com.algorand.android.modules.swap.assetswap.data.utils.getSafeAssetIdForRequest
import com.algorand.android.modules.swap.assetswap.domain.model.dto.PeraFeeDTO
import com.algorand.android.modules.swap.assetswap.domain.repository.AssetSwapRepository
import com.algorand.android.modules.swap.utils.defaultPeraSwapFee
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.DataResource
import java.math.BigDecimal
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.map

class GetPeraFeeUseCase @Inject constructor(
    @Named(AssetSwapRepository.INJECTION_NAME)
    private val assetSwapRepository: AssetSwapRepository
) {

    suspend fun getPeraFee(fromAssetId: Long, amount: BigDecimal, fractionDecimals: Int): DataResource<BigDecimal> {
        var result: DataResource<BigDecimal>? = null
        val amountAsMicro = amount.movePointRight(fractionDecimals).toBigInteger()
        val safeAssetId = getSafeAssetIdForRequest(fromAssetId)
        assetSwapRepository.getPeraFee(safeAssetId, amountAsMicro).map { peraFeeDtoResult ->
            peraFeeDtoResult.use(
                onSuccess = { peraFeeDTO ->
                    val safePeraFeeAmount = getSafePeraFee(peraFeeDTO)
                    result = DataResource.Success(safePeraFeeAmount)
                },
                onFailed = { exception, code ->
                    result = DataResource.Error.Api<BigDecimal>(exception, code)
                }
            )
        }.collect()
        return result ?: DataResource.Error.Local(NullPointerException())
    }

    private fun getSafePeraFee(peraFeeDTO: PeraFeeDTO): BigDecimal {
        return peraFeeDTO.peraFeeAmount?.toBigDecimal()?.movePointLeft(ALGO_DECIMALS) ?: defaultPeraSwapFee
    }
}
