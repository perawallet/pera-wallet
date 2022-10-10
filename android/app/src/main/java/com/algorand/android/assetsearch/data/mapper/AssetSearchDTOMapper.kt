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

package com.algorand.android.assetsearch.data.mapper

import com.algorand.android.assetsearch.domain.model.AssetSearchDTO
import com.algorand.android.models.AssetSearchResponse
import javax.inject.Inject

class AssetSearchDTOMapper @Inject constructor(
    private val collectibleSearchDTOMapper: CollectibleSearchDTOMapper,
    private val verificationTierDTODecider: VerificationTierDTODecider
) {

    fun mapToAssetSearchDTO(response: AssetSearchResponse): AssetSearchDTO {
        return AssetSearchDTO(
            assetId = response.assetId,
            fullName = response.fullName,
            shortName = response.shortName,
            logo = response.logo,
            verificationTier = verificationTierDTODecider.decideVerificationTierDTO(response.verificationTier),
            collectible = collectibleSearchDTOMapper.mapToCollectibleSearchDTO(response.collectible)
        )
    }
}
