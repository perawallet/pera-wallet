/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.utils

import com.algorand.android.assetsearch.domain.model.VerificationTier
import com.algorand.android.models.AssetDetail
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.utils.browser.ALGORAND_DISCORD_URL
import com.algorand.android.utils.browser.ALGORAND_TELEGRAM_URL
import com.algorand.android.utils.browser.ALGORAND_TWITTER_USERNAME
import com.algorand.android.utils.browser.ALGORAND_WEBSITE_URL
import javax.inject.Inject

class AlgoAssetInformationProvider @Inject constructor() {

    fun getAlgoAssetInformation(): CacheResult<AssetDetail> {
        return CacheResult.Success.create(
            AssetDetail(
                assetId = ALGO_ID,
                fullName = ALGO_FULL_NAME,
                shortName = ALGO_SHORT_NAME,
                fractionDecimals = ALGO_DECIMALS,
                usdValue = null,
                assetCreator = null,
                verificationTier = VerificationTier.TRUSTED,
                logoUri = null,
                logoSvgUri = null,
                explorerUrl = null,
                projectUrl = null,
                projectName = null,
                discordUrl = ALGORAND_DISCORD_URL,
                telegramUrl = ALGORAND_TELEGRAM_URL,
                twitterUsername = ALGORAND_TWITTER_USERNAME,
                assetDescription = null,
                totalSupply = algoTotalSupply,
                url = ALGORAND_WEBSITE_URL,
                maxSupply = null,
                last24HoursAlgoPriceChangePercentage = null,
                isAvailableOnDiscoverMobile = true
            )
        )
    }
}
