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

import com.algorand.android.nft.data.repository.CollectibleDetailRepositoryImpl
import com.algorand.android.nft.domain.mapper.CollectibleDetailMapper
import com.algorand.android.nft.domain.model.BaseCollectibleDetail
import com.algorand.android.nft.domain.model.CollectibleDetailDTO
import com.algorand.android.nft.domain.model.CollectibleMediaType
import com.algorand.android.utils.DataResource
import javax.inject.Inject
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow

class GetCollectibleDetailUseCase @Inject constructor(
    private val collectibleRepository: CollectibleDetailRepositoryImpl,
    private val collectibleDetailMapper: CollectibleDetailMapper,
) {

    fun getCollectibleDetail(collectibleAssetId: Long) = flow<DataResource<BaseCollectibleDetail>> {
        emit(DataResource.Loading())
        collectibleRepository.getCollectibleDetail(collectibleAssetId).collect {
            it.use(
                onSuccess = { collectibleDetailDto ->
                    val baseCollectibleDetail = getMappedCollectibleDetail(collectibleDetailDto)
                    emit(DataResource.Success(baseCollectibleDetail))
                },
                onFailed = { exception, code ->
                    emit(DataResource.Error.Api<BaseCollectibleDetail>(exception, code))
                }
            )
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
            }
        }
    }
}
