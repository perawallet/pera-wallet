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

package com.algorand.android.modules.assets.profile.detail.domain.usecase

import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.modules.assets.profile.detail.domain.repository.AssetDetailRepository
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.distinctUntilChanged

class GetAccountAssetDetailUseCase @Inject constructor(
    @Named(AssetDetailRepository.INJECTION_NAME)
    private val assetDetailRepository: AssetDetailRepository
) {

    suspend fun getAssetDetail(accountAddress: String, assetId: Long): Flow<BaseAccountAssetData.BaseOwnedAssetData?> {
        return assetDetailRepository.getAccountAssetDetail(accountAddress, assetId).distinctUntilChanged()
    }
}
