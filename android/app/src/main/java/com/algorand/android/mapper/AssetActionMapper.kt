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

import com.algorand.android.assetsearch.domain.model.VerificationTier
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetInformation
import javax.inject.Inject

class AssetActionMapper @Inject constructor() {

    fun mapTo(assetId: Long, publicKey: String?, asset: AssetInformation?): AssetAction {
        return AssetAction(
            assetId = assetId,
            publicKey = publicKey,
            asset = asset,
        )
    }

    fun mapTo(
        assetId: Long,
        fullName: String?,
        shortName: String?,
        verificationTier: VerificationTier?,
        accountAddress: String?,
        creatorPublicKey: String?
    ): AssetAction {
        return AssetAction(
            assetId = assetId,
            asset = AssetInformation(
                assetId = assetId,
                fullName = fullName,
                shortName = shortName,
                verificationTier = verificationTier,
                creatorPublicKey = creatorPublicKey
            ),
            publicKey = accountAddress
        )
    }
}
