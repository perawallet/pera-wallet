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

package com.algorand.android.mapper

import com.algorand.android.assetsearch.data.mapper.VerificationTierDTODecider
import com.algorand.android.assetsearch.domain.mapper.VerificationTierDecider
import com.algorand.android.models.AssetDetail
import com.algorand.android.models.AssetDetailResponse
import javax.inject.Inject

class AssetDetailMapper @Inject constructor(
    private val verificationTierDTODecider: VerificationTierDTODecider,
    private val verificationTierDecider: VerificationTierDecider
) {

    fun mapToAssetDetail(assetDetailResponse: AssetDetailResponse): AssetDetail {
        // TODO Remove this after updating AssetFetchAndCacheUseCase TODOs
        val verificationTier = with(assetDetailResponse) {
            val verificationTierDto = verificationTierDTODecider.decideVerificationTierDTO(verificationTier)
            verificationTierDecider.decideVerificationTier(verificationTierDto)
        }
        return AssetDetail(
            assetId = assetDetailResponse.assetId,
            fullName = assetDetailResponse.fullName,
            shortName = assetDetailResponse.shortName,
            fractionDecimals = assetDetailResponse.fractionDecimals,
            usdValue = assetDetailResponse.usdValue,
            assetCreator = assetDetailResponse.assetCreator,
            verificationTier = verificationTier,
            logoUri = assetDetailResponse.logoUri,
            logoSvgUri = assetDetailResponse.logoSvgUri,
            explorerUrl = assetDetailResponse.explorerUrl,
            projectName = assetDetailResponse.projectName,
            projectUrl = assetDetailResponse.projectUrl,
            discordUrl = assetDetailResponse.discordUrl,
            telegramUrl = assetDetailResponse.telegramUrl,
            twitterUsername = assetDetailResponse.twitterUsername,
            assetDescription = assetDetailResponse.description,
            totalSupply = assetDetailResponse.totalSupply,
            url = assetDetailResponse.url,
            maxSupply = assetDetailResponse.maxSupply
        )
    }
}
