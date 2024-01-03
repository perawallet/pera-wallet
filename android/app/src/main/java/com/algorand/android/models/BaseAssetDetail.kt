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

package com.algorand.android.models

import com.algorand.android.assetsearch.domain.model.VerificationTier
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.utils.DEFAULT_ASSET_DECIMAL
import java.math.BigDecimal
import java.math.BigInteger

abstract class BaseAssetDetail {

    abstract val assetId: Long
    abstract val fullName: String?
    abstract val shortName: String?
    abstract val fractionDecimals: Int?
    abstract val usdValue: BigDecimal?
    abstract val assetCreator: AssetCreator?
    abstract val verificationTier: VerificationTier
    abstract val logoUri: String?
    abstract val logoSvgUri: String?
    abstract val explorerUrl: String?
    abstract val projectUrl: String?
    abstract val projectName: String?
    abstract val discordUrl: String?
    abstract val telegramUrl: String?
    abstract val twitterUsername: String?
    abstract val assetDescription: String?
    abstract val totalSupply: BigDecimal?
    abstract val maxSupply: BigInteger?
    abstract val url: String?
    abstract val last24HoursAlgoPriceChangePercentage: BigDecimal?
    abstract val isAvailableOnDiscoverMobile: Boolean?

    fun hasUsdValue(): Boolean {
        return usdValue != null || assetId == ALGO_ID
    }

    // TODO remove this function after deleting AssetInformation
    fun convertToAssetInformation(): AssetInformation {
        return AssetInformation(
            assetId = assetId,
            creatorPublicKey = assetCreator?.publicKey,
            shortName = shortName,
            fullName = fullName,
            verificationTier = verificationTier,
            decimals = fractionDecimals ?: DEFAULT_ASSET_DECIMAL
        )
    }
}
