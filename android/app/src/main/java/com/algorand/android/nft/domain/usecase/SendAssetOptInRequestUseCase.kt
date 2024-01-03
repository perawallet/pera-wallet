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

package com.algorand.android.nft.domain.usecase

import com.algorand.android.nft.domain.mapper.AssetSupportRequestMapper
import com.algorand.android.repository.AssetRepository
import com.algorand.android.utils.DataResource
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

class SendAssetOptInRequestUseCase @Inject constructor(
    private val assetRepository: AssetRepository,
    private val assetSupportRequestMapper: AssetSupportRequestMapper // TODO create dedicated model for asset support
) {

    fun sendAssetOptInRequest(senderPublicKey: String, receiverPublicKey: String, assetId: Long) = flow {
        emit(DataResource.Loading<Unit>())
        val assetSupportRequest =
            assetSupportRequestMapper.mapToAssetSupportRequest(senderPublicKey, receiverPublicKey, assetId)
        assetRepository.postAssetSupportRequest(assetSupportRequest).use(
            onSuccess = {
                emit(DataResource.Success<Unit>(Unit))
            },
            onFailed = { exception, code ->
                emit(DataResource.Error.Api<Unit>(exception, code))
            }
        )
    }
}
