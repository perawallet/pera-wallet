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

import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.AssetDetail
import javax.inject.Inject

class AlgoAssetInformationProvider @Inject constructor() {

    fun getAlgoAssetInformation(): CacheResult<AssetDetail> {
        return CacheResult.Success.create(
            AssetDetail(
                assetId = ALGORAND_ID,
                fullName = ALGOS_FULL_NAME,
                shortName = ALGOS_SHORT_NAME,
                isVerified = true,
                fractionDecimals = ALGO_DECIMALS,
                usdValue = null,
                assetCreator = null
            )
        )
    }
}
