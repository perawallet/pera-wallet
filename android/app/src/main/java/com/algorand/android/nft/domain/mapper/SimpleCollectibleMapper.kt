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

package com.algorand.android.nft.domain.mapper

import com.algorand.android.nft.data.model.CollectibleResponse
import com.algorand.android.nft.domain.model.SimpleCollectible
import javax.inject.Inject

class SimpleCollectibleMapper @Inject constructor(
    private val collectibleMediaTypeMapper: CollectibleMediaTypeMapper
) {

    fun mapToSimpleCollectible(collectibleResponse: CollectibleResponse?): SimpleCollectible? {
        if (collectibleResponse == null) return null
        return SimpleCollectible(
            mediaType = collectibleMediaTypeMapper.mapToCollectibleMediaType(collectibleResponse.mediaType),
            primaryImageUrl = collectibleResponse.primaryImageUrl,
            title = collectibleResponse.title,
            collectionName = collectibleResponse.collectionName,
            explorerUrl = collectibleResponse.explorerUrl
        )
    }
}
