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

package com.algorand.android.modules.swap.assetswap.domain.model

import android.os.Parcelable
import com.algorand.android.assetsearch.domain.model.VerificationTier
import com.algorand.android.utils.AssetName
import java.math.BigDecimal
import java.math.BigInteger
import kotlinx.parcelize.Parcelize

@Parcelize
data class SwapQuoteAssetDetail(
    val assetId: Long,
    val logoUrl: String?,
    val name: AssetName,
    val shortName: AssetName,
    val total: BigInteger?,
    val fractionDecimals: Int,
    val verificationTier: VerificationTier,
    val usdValue: BigDecimal
) : Parcelable
