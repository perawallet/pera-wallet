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

import com.algorand.android.models.AssetHolding
import com.algorand.android.models.AssetHoldingResponse
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetStatus
import java.math.BigInteger
import javax.inject.Inject

class AssetHoldingsMapper @Inject constructor() {

    fun mapToAssetHoldings(assetHoldingResponse: AssetHoldingResponse): AssetHolding {
        return AssetHolding(
            assetId = assetHoldingResponse.assetId ?: 0L,
            amount = assetHoldingResponse.amount ?: BigInteger.ZERO,
            isDeleted = assetHoldingResponse.isDeleted
        )
    }

    fun mapToPendingAdditionAssetHoldings(assetInformation: AssetInformation): AssetHolding {
        return AssetHolding(
            assetId = assetInformation.assetId,
            amount = BigInteger.ZERO,
            isDeleted = false,
            status = AssetStatus.PENDING_FOR_ADDITION
        )
    }
}
