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

package com.algorand.android.modules.assets.profile.detail.data.repository

import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.modules.assets.profile.detail.domain.repository.AssetDetailRepository
import com.algorand.android.usecase.GetBaseOwnedAssetDataUseCase

class AssetDetailRepositoryImpl(
    private val getBaseOwnedAssetDataUseCase: GetBaseOwnedAssetDataUseCase
) : AssetDetailRepository {
    override suspend fun getAccountAssetDetail(
        accountAddress: String,
        assetId: Long
    ): BaseAccountAssetData.BaseOwnedAssetData? = getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(
        assetId = assetId,
        publicKey = accountAddress
    )
}
