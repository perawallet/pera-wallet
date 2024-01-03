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

package com.algorand.android.modules.collectibles.detail.base.ui.mapper

import com.algorand.android.decider.AssetDrawableProviderDecider
import com.algorand.android.modules.collectibles.detail.base.ui.model.BaseCollectibleMediaItem
import com.algorand.android.nft.domain.model.BaseCollectibleDetail
import com.algorand.android.nft.domain.model.BaseCollectibleMedia
import javax.inject.Inject

class CollectibleMediaItemMapper @Inject constructor(
    private val assetDrawableProviderDecider: AssetDrawableProviderDecider
) {

    @SuppressWarnings("LongMethod")
    fun mapToCollectibleMediaItem(
        baseCollectibleMedia: BaseCollectibleMedia,
        shouldDecreaseOpacity: Boolean,
        baseCollectibleDetail: BaseCollectibleDetail,
        showMediaButtons: Boolean
    ): BaseCollectibleMediaItem {
        return when (baseCollectibleMedia) {
            is BaseCollectibleMedia.GifCollectibleMedia -> {
                mapToGifCollectibleMediaItem(
                    collectibleId = baseCollectibleDetail.assetId,
                    shouldDecreaseOpacity = shouldDecreaseOpacity,
                    collectibleMedia = baseCollectibleMedia,
                    baseCollectibleDetail = baseCollectibleDetail,
                    has3dSupport = true && showMediaButtons,
                    hasFullScreenSupport = true && showMediaButtons,
                    showPlayButton = false && showMediaButtons
                )
            }
            is BaseCollectibleMedia.AudioCollectibleMedia -> {
                mapToAudioCollectibleMediaItem(
                    collectibleId = baseCollectibleDetail.assetId,
                    isOwnedByTheUser = shouldDecreaseOpacity,
                    collectibleMedia = baseCollectibleMedia,
                    baseCollectibleDetail = baseCollectibleDetail,
                    has3dSupport = false && showMediaButtons,
                    hasFullScreenSupport = true && showMediaButtons,
                    showPlayButton = true && showMediaButtons
                )
            }
            is BaseCollectibleMedia.ImageCollectibleMedia -> {
                mapToImageCollectibleMediaItem(
                    collectibleId = baseCollectibleDetail.assetId,
                    shouldDecreaseOpacity = shouldDecreaseOpacity,
                    collectibleMedia = baseCollectibleMedia,
                    baseCollectibleDetail = baseCollectibleDetail,
                    has3dSupport = true && showMediaButtons,
                    hasFullScreenSupport = true && showMediaButtons,
                    showPlayButton = false && showMediaButtons
                )
            }
            is BaseCollectibleMedia.NoMediaCollectibleMedia -> {
                mapToNoMediaCollectibleMediaItem(
                    collectibleId = baseCollectibleDetail.assetId,
                    isOwnedByTheUser = shouldDecreaseOpacity,
                    collectibleMedia = baseCollectibleMedia,
                    baseCollectibleDetail = baseCollectibleDetail,
                    has3dSupport = false && showMediaButtons,
                    hasFullScreenSupport = false && showMediaButtons,
                    showPlayButton = false && showMediaButtons
                )
            }
            is BaseCollectibleMedia.UnsupportedCollectibleMedia -> {
                mapToUnsupportedCollectibleMediaItem(
                    collectibleId = baseCollectibleDetail.assetId,
                    isOwnedByTheUser = shouldDecreaseOpacity,
                    collectibleMedia = baseCollectibleMedia,
                    baseCollectibleDetail = baseCollectibleDetail,
                    has3dSupport = false && showMediaButtons,
                    hasFullScreenSupport = false && showMediaButtons,
                    showPlayButton = false && showMediaButtons
                )
            }
            is BaseCollectibleMedia.VideoCollectibleMedia -> {
                mapToVideoCollectibleMediaItem(
                    collectibleId = baseCollectibleDetail.assetId,
                    isOwnedByTheUser = shouldDecreaseOpacity,
                    collectibleMedia = baseCollectibleMedia,
                    baseCollectibleDetail = baseCollectibleDetail,
                    has3dSupport = false && showMediaButtons,
                    hasFullScreenSupport = true && showMediaButtons,
                    showPlayButton = true && showMediaButtons
                )
            }
        }
    }

    private fun mapToImageCollectibleMediaItem(
        collectibleId: Long,
        shouldDecreaseOpacity: Boolean,
        collectibleMedia: BaseCollectibleMedia,
        baseCollectibleDetail: BaseCollectibleDetail,
        has3dSupport: Boolean,
        hasFullScreenSupport: Boolean,
        showPlayButton: Boolean
    ): BaseCollectibleMediaItem.ImageCollectibleMediaItem {
        return BaseCollectibleMediaItem.ImageCollectibleMediaItem(
            downloadUrl = collectibleMedia.downloadUrl,
            previewUrl = collectibleMedia.previewUrl,
            collectibleId = collectibleId,
            shouldDecreaseOpacity = shouldDecreaseOpacity,
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(baseCollectibleDetail),
            has3dSupport = has3dSupport,
            hasFullScreenSupport = hasFullScreenSupport,
            showPlayButton = showPlayButton
        )
    }

    private fun mapToGifCollectibleMediaItem(
        collectibleId: Long,
        shouldDecreaseOpacity: Boolean,
        collectibleMedia: BaseCollectibleMedia,
        baseCollectibleDetail: BaseCollectibleDetail,
        has3dSupport: Boolean,
        hasFullScreenSupport: Boolean,
        showPlayButton: Boolean
    ): BaseCollectibleMediaItem.GifCollectibleMediaItem {
        return BaseCollectibleMediaItem.GifCollectibleMediaItem(
            downloadUrl = collectibleMedia.downloadUrl,
            previewUrl = collectibleMedia.previewUrl,
            collectibleId = collectibleId,
            shouldDecreaseOpacity = shouldDecreaseOpacity,
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(baseCollectibleDetail),
            has3dSupport = has3dSupport,
            hasFullScreenSupport = hasFullScreenSupport,
            showPlayButton = showPlayButton
        )
    }

    private fun mapToVideoCollectibleMediaItem(
        collectibleId: Long,
        isOwnedByTheUser: Boolean,
        collectibleMedia: BaseCollectibleMedia,
        baseCollectibleDetail: BaseCollectibleDetail,
        has3dSupport: Boolean,
        hasFullScreenSupport: Boolean,
        showPlayButton: Boolean
    ): BaseCollectibleMediaItem.VideoCollectibleMediaItem {
        return BaseCollectibleMediaItem.VideoCollectibleMediaItem(
            downloadUrl = collectibleMedia.downloadUrl,
            previewUrl = collectibleMedia.previewUrl,
            collectibleId = collectibleId,
            shouldDecreaseOpacity = isOwnedByTheUser,
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(baseCollectibleDetail),
            has3dSupport = has3dSupport,
            hasFullScreenSupport = hasFullScreenSupport,
            showPlayButton = showPlayButton
        )
    }

    private fun mapToAudioCollectibleMediaItem(
        collectibleId: Long,
        isOwnedByTheUser: Boolean,
        collectibleMedia: BaseCollectibleMedia,
        baseCollectibleDetail: BaseCollectibleDetail,
        has3dSupport: Boolean,
        hasFullScreenSupport: Boolean,
        showPlayButton: Boolean
    ): BaseCollectibleMediaItem.AudioCollectibleMediaItem {
        return BaseCollectibleMediaItem.AudioCollectibleMediaItem(
            downloadUrl = collectibleMedia.downloadUrl,
            previewUrl = collectibleMedia.previewUrl,
            collectibleId = collectibleId,
            shouldDecreaseOpacity = isOwnedByTheUser,
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(baseCollectibleDetail),
            has3dSupport = has3dSupport,
            hasFullScreenSupport = hasFullScreenSupport,
            showPlayButton = showPlayButton
        )
    }

    private fun mapToUnsupportedCollectibleMediaItem(
        collectibleId: Long,
        isOwnedByTheUser: Boolean,
        collectibleMedia: BaseCollectibleMedia,
        baseCollectibleDetail: BaseCollectibleDetail,
        has3dSupport: Boolean,
        hasFullScreenSupport: Boolean,
        showPlayButton: Boolean
    ): BaseCollectibleMediaItem.UnsupportedCollectibleMediaItem {
        return BaseCollectibleMediaItem.UnsupportedCollectibleMediaItem(
            downloadUrl = collectibleMedia.downloadUrl,
            previewUrl = collectibleMedia.previewUrl,
            collectibleId = collectibleId,
            shouldDecreaseOpacity = isOwnedByTheUser,
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(baseCollectibleDetail),
            has3dSupport = has3dSupport,
            hasFullScreenSupport = hasFullScreenSupport,
            showPlayButton = showPlayButton
        )
    }

    private fun mapToNoMediaCollectibleMediaItem(
        collectibleId: Long,
        isOwnedByTheUser: Boolean,
        collectibleMedia: BaseCollectibleMedia,
        baseCollectibleDetail: BaseCollectibleDetail,
        has3dSupport: Boolean,
        hasFullScreenSupport: Boolean,
        showPlayButton: Boolean
    ): BaseCollectibleMediaItem.NoMediaCollectibleMediaItem {
        return BaseCollectibleMediaItem.NoMediaCollectibleMediaItem(
            downloadUrl = collectibleMedia.downloadUrl,
            previewUrl = collectibleMedia.previewUrl,
            collectibleId = collectibleId,
            shouldDecreaseOpacity = isOwnedByTheUser,
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(baseCollectibleDetail),
            has3dSupport = has3dSupport,
            hasFullScreenSupport = hasFullScreenSupport,
            showPlayButton = showPlayButton
        )
    }
}
