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

package com.algorand.android.modules.swap.assetselection.toasset.domain.mapper

import com.algorand.android.assetsearch.domain.mapper.VerificationTierDecider
import com.algorand.android.modules.swap.assetselection.toasset.domain.model.AvailableSwapAsset
import com.algorand.android.modules.swap.assetselection.toasset.domain.model.AvailableSwapAssetDTO
import com.algorand.android.utils.AssetName
import java.math.BigDecimal
import javax.inject.Inject

class AvailableSwapAssetMapper @Inject constructor(
    private val verificationTierDecider: VerificationTierDecider
) {

    fun mapToAvailableSwapAsset(
        assetId: Long,
        availableSwapAssetDTO: AvailableSwapAssetDTO,
        usdValue: BigDecimal,
    ): AvailableSwapAsset {
        return with(availableSwapAssetDTO) {
            AvailableSwapAsset(
                assetId = assetId,
                logoUrl = logoUrl,
                assetName = AssetName.create(assetName),
                assetShortName = AssetName.createShortName(assetShortName),
                verificationTier = verificationTierDecider.decideVerificationTier(verificationTierDTO),
                usdValue = usdValue
            )
        }
    }
}
