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

package com.algorand.android.modules.collectibles.detail.base.domain.usecase

import com.algorand.android.models.Result
import com.algorand.android.modules.collectibles.detail.base.data.model.CollectibleDetailDTO
import com.algorand.android.modules.collectibles.detail.base.domain.repository.CollectibleDetailRepository
import com.algorand.android.nft.domain.mapper.CollectibleDetailMapper
import com.algorand.android.nft.domain.model.BaseCollectibleDetail
import com.algorand.android.nft.domain.model.CollectibleMediaType
import javax.inject.Inject
import javax.inject.Named

class GetCollectibleDetailUseCase @Inject constructor(
    @Named(CollectibleDetailRepository.INJECTION_NAME)
    private val collectibleRepository: CollectibleDetailRepository,
    private val collectibleDetailMapper: CollectibleDetailMapper
) {

    suspend fun getCollectibleDetail(collectibleAssetId: Long): Result<BaseCollectibleDetail> {
        return collectibleRepository.getCollectibleDetail(collectibleAssetId).map {
            getMappedCollectibleDetail(it)
        }
    }

    private fun getMappedCollectibleDetail(collectibleDetailDTO: CollectibleDetailDTO): BaseCollectibleDetail {
        return with(collectibleDetailMapper) {
            when (collectibleDetailDTO.mediaType) {
                CollectibleMediaType.IMAGE -> mapToImageCollectibleDetail(collectibleDetailDTO)
                CollectibleMediaType.VIDEO -> {
                    val thumbnailPrismUrl = with(collectibleDetailDTO) {
                        primaryImageUrl ?: medias.firstOrNull()?.previewUrl ?: medias.firstOrNull()?.downloadUrl
                    }.orEmpty()
                    mapToVideoCollectibleDetail(collectibleDetailDTO, thumbnailPrismUrl)
                }
                CollectibleMediaType.MIXED -> mapToMixedCollectibleDetail(collectibleDetailDTO)
                CollectibleMediaType.NOT_SUPPORTED -> mapToNotSupportedCollectibleDetail(collectibleDetailDTO)
                CollectibleMediaType.AUDIO -> {
                    val thumbnailPrismUrl = with(collectibleDetailDTO) {
                        primaryImageUrl ?: medias.firstOrNull()?.previewUrl ?: medias.firstOrNull()?.downloadUrl
                    }.orEmpty()
                    mapToAudioCollectibleDetail(collectibleDetailDTO, thumbnailPrismUrl)
                }
            }
        }
    }
}
