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
import java.math.BigDecimal
import java.math.BigInteger

// TODO: Rename this as AssetDetailDTO
data class AssetDetail(
    override val assetId: Long,
    override val fullName: String?,
    override val shortName: String?,
    override val fractionDecimals: Int?,
    override val usdValue: BigDecimal?,
    override val assetCreator: AssetCreator?,
    override val verificationTier: VerificationTier,
    override val logoUri: String?,
    override val logoSvgUri: String?,
    override val explorerUrl: String?,
    override val projectUrl: String?,
    override val projectName: String?,
    override val discordUrl: String?,
    override val telegramUrl: String?,
    override val twitterUsername: String?,
    override val assetDescription: String?,
    override val url: String?,
    override val totalSupply: BigDecimal?,
    override val maxSupply: BigInteger?
) : BaseAssetDetail()
