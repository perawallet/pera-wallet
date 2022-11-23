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

package com.algorand.android.modules.swap.assetswap.data.mapper

import com.algorand.android.assetsearch.data.mapper.VerificationTierDTODecider
import com.algorand.android.modules.swap.assetswap.data.model.SwapQuoteAssetDetailResponse
import com.algorand.android.modules.swap.assetswap.data.utils.getSafeAssetIdForResponse
import com.algorand.android.modules.swap.assetswap.domain.model.dto.SwapQuoteAssetDetailDTO
import javax.inject.Inject

class SwapQuoteAssetDetailDTOMapper @Inject constructor(
    private val verificationTierDTODecider: VerificationTierDTODecider
) {

    fun mapToSwapQuoteAssetDetailDTO(response: SwapQuoteAssetDetailResponse?): SwapQuoteAssetDetailDTO? {
        if (response == null) return null
        val safeAssetId = getSafeAssetIdForResponse(response.assetId)
        return SwapQuoteAssetDetailDTO(
            assetId = safeAssetId,
            logoUrl = response.logoUrl,
            name = response.name,
            shortName = response.shortName,
            total = response.total,
            fractionDecimals = response.fractionDecimals,
            verificationTierDTO = verificationTierDTODecider
                .decideVerificationTierDTO(response.verificationTierResponse),
            usdValue = response.usdValue
        )
    }
}
