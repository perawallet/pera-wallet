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

package com.algorand.android.nft.mapper

import com.algorand.android.nft.domain.model.BaseCollectibleMedia
import com.algorand.android.nft.ui.model.BaseCollectibleMediaItem
import javax.inject.Inject

class CollectibleMediaItemMapper @Inject constructor() {

    fun mapToImageCollectibleMediaItem(
        collectibleId: Long,
        isOwnedByTheUser: Boolean,
        errorText: String,
        collectibleMedia: BaseCollectibleMedia
    ): BaseCollectibleMediaItem.ImageCollectibleMediaItem {
        return BaseCollectibleMediaItem.ImageCollectibleMediaItem(
            downloadUrl = collectibleMedia.downloadUrl,
            previewUrl = collectibleMedia.previewUrl,
            collectibleId = collectibleId,
            errorText = errorText,
            isOwnedByTheUser = isOwnedByTheUser
        )
    }

    fun mapToVideoCollectibleMediaItem(
        collectibleId: Long,
        isOwnedByTheUser: Boolean,
        errorText: String,
        collectibleMedia: BaseCollectibleMedia,
        previewUrl: String
    ): BaseCollectibleMediaItem.VideoCollectibleMediaItem {
        return BaseCollectibleMediaItem.VideoCollectibleMediaItem(
            downloadUrl = collectibleMedia.downloadUrl,
            previewUrl = previewUrl,
            collectibleId = collectibleId,
            errorText = errorText,
            isOwnedByTheUser = isOwnedByTheUser
        )
    }

    fun mapToUnsupportedCollectibleMediaItem(
        collectibleId: Long,
        isOwnedByTheUser: Boolean,
        errorText: String,
        collectibleMedia: BaseCollectibleMedia
    ): BaseCollectibleMediaItem.UnsupportedCollectibleMediaItem {
        return BaseCollectibleMediaItem.UnsupportedCollectibleMediaItem(
            downloadUrl = collectibleMedia.downloadUrl,
            previewUrl = collectibleMedia.previewUrl,
            collectibleId = collectibleId,
            errorText = errorText,
            isOwnedByTheUser = isOwnedByTheUser
        )
    }
}
