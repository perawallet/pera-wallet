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

import com.algorand.android.assetsearch.domain.model.AssetDetailDTO
import com.algorand.android.models.AssetDetail
import com.algorand.android.models.AssetDetailResponse
import javax.inject.Inject

class AssetDetailMapper @Inject constructor() {

    fun mapToAssetDetail(assetDetailResponse: AssetDetailResponse): AssetDetail {
        return AssetDetail(
            assetId = assetDetailResponse.assetId,
            fullName = assetDetailResponse.fullName,
            shortName = assetDetailResponse.shortName,
            isVerified = assetDetailResponse.isVerified,
            fractionDecimals = assetDetailResponse.fractionDecimals,
            usdValue = assetDetailResponse.usdValue,
            assetCreator = assetDetailResponse.assetCreator
        )
    }

    fun mapToAssetDetail(assetDetailDTO: AssetDetailDTO): AssetDetail {
        return AssetDetail(
            assetId = assetDetailDTO.assetId,
            fullName = assetDetailDTO.fullName,
            shortName = assetDetailDTO.shortName,
            isVerified = assetDetailDTO.isVerified,
            fractionDecimals = assetDetailDTO.fractionDecimals,
            usdValue = assetDetailDTO.usdValue,
            assetCreator = assetDetailDTO.assetCreator
        )
    }
}
