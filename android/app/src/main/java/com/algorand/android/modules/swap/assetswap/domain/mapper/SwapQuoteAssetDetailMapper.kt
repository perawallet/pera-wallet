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

package com.algorand.android.modules.swap.assetswap.domain.mapper

import com.algorand.android.assetsearch.domain.mapper.VerificationTierDecider
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuoteAssetDetail
import com.algorand.android.modules.swap.assetswap.domain.model.dto.SwapQuoteAssetDetailDTO
import com.algorand.android.utils.AssetName
import java.math.BigDecimal
import javax.inject.Inject

class SwapQuoteAssetDetailMapper @Inject constructor(
    private val verificationTierDecider: VerificationTierDecider
) {

    fun mapToSwapQuoteAssetDetail(
        dto: SwapQuoteAssetDetailDTO,
        assetId: Long,
        fractionDecimals: Int,
        usdValue: BigDecimal
    ): SwapQuoteAssetDetail {
        return SwapQuoteAssetDetail(
            assetId = assetId,
            logoUrl = dto.logoUrl,
            name = AssetName.create(dto.name),
            shortName = AssetName.createShortName(dto.shortName),
            total = dto.total,
            fractionDecimals = fractionDecimals,
            verificationTier = verificationTierDecider.decideVerificationTier(dto.verificationTierDTO),
            usdValue = usdValue
        )
    }
}
