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

package com.algorand.android.modules.collectibles.detail.base.ui.model

import android.os.Parcelable
import com.algorand.android.models.RecyclerListItem
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider
import kotlinx.parcelize.Parcelize

sealed class BaseCollectibleMediaItem : Parcelable, RecyclerListItem {

    abstract val collectibleId: Long
    abstract val downloadUrl: String?
    abstract val previewUrl: String?
    abstract val baseAssetDrawableProvider: BaseAssetDrawableProvider
    abstract val shouldDecreaseOpacity: Boolean
    abstract val itemType: ItemType

    abstract val has3dSupport: Boolean
    abstract val hasFullScreenSupport: Boolean
    abstract val showPlayButton: Boolean

    enum class ItemType {
        IMAGE,
        VIDEO,
        AUDIO,
        UNSUPPORTED,
        GIF,
        NO_MEDIA
    }

    @Parcelize
    data class ImageCollectibleMediaItem(
        override val collectibleId: Long,
        override val downloadUrl: String?,
        override val previewUrl: String?,
        override val shouldDecreaseOpacity: Boolean,
        override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
        override val has3dSupport: Boolean,
        override val hasFullScreenSupport: Boolean,
        override val showPlayButton: Boolean
    ) : BaseCollectibleMediaItem() {

        override val itemType: ItemType
            get() = ItemType.IMAGE

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is ImageCollectibleMediaItem &&
                other.previewUrl == previewUrl &&
                other.downloadUrl == downloadUrl
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is ImageCollectibleMediaItem && other == this
        }
    }

    @Parcelize
    data class GifCollectibleMediaItem(
        override val collectibleId: Long,
        override val downloadUrl: String?,
        override val previewUrl: String?,
        override val shouldDecreaseOpacity: Boolean,
        override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
        override val has3dSupport: Boolean,
        override val hasFullScreenSupport: Boolean,
        override val showPlayButton: Boolean
    ) : BaseCollectibleMediaItem() {

        override val itemType: ItemType
            get() = ItemType.GIF

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is GifCollectibleMediaItem &&
                other.previewUrl == previewUrl &&
                other.downloadUrl == downloadUrl
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is GifCollectibleMediaItem && other == this
        }
    }

    @Parcelize
    data class VideoCollectibleMediaItem(
        override val collectibleId: Long,
        override val downloadUrl: String?,
        override val previewUrl: String?,
        override val shouldDecreaseOpacity: Boolean,
        override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
        override val has3dSupport: Boolean,
        override val hasFullScreenSupport: Boolean,
        override val showPlayButton: Boolean
    ) : BaseCollectibleMediaItem() {

        override val itemType: ItemType
            get() = ItemType.VIDEO

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is VideoCollectibleMediaItem &&
                other.previewUrl == previewUrl &&
                other.downloadUrl == downloadUrl
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is VideoCollectibleMediaItem && other == this
        }
    }

    @Parcelize
    data class AudioCollectibleMediaItem(
        override val collectibleId: Long,
        override val downloadUrl: String?,
        override val previewUrl: String?,
        override val shouldDecreaseOpacity: Boolean,
        override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
        override val has3dSupport: Boolean,
        override val hasFullScreenSupport: Boolean,
        override val showPlayButton: Boolean
    ) : BaseCollectibleMediaItem() {

        override val itemType: ItemType
            get() = ItemType.AUDIO

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is VideoCollectibleMediaItem &&
                other.previewUrl == previewUrl &&
                other.downloadUrl == downloadUrl
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is VideoCollectibleMediaItem && other == this
        }
    }

    @Parcelize
    data class UnsupportedCollectibleMediaItem(
        override val collectibleId: Long,
        override val downloadUrl: String?,
        override val previewUrl: String?,
        override val shouldDecreaseOpacity: Boolean,
        override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
        override val has3dSupport: Boolean,
        override val hasFullScreenSupport: Boolean,
        override val showPlayButton: Boolean
    ) : BaseCollectibleMediaItem() {

        override val itemType: ItemType
            get() = ItemType.UNSUPPORTED

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is UnsupportedCollectibleMediaItem &&
                other.previewUrl == previewUrl &&
                other.downloadUrl == downloadUrl
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is UnsupportedCollectibleMediaItem && other == this
        }
    }

    @Parcelize
    data class NoMediaCollectibleMediaItem(
        override val collectibleId: Long,
        override val downloadUrl: String?,
        override val previewUrl: String?,
        override val shouldDecreaseOpacity: Boolean,
        override val baseAssetDrawableProvider: BaseAssetDrawableProvider,
        override val has3dSupport: Boolean,
        override val hasFullScreenSupport: Boolean,
        override val showPlayButton: Boolean
    ) : BaseCollectibleMediaItem() {

        override val itemType: ItemType
            get() = ItemType.NO_MEDIA

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is NoMediaCollectibleMediaItem &&
                other.previewUrl == previewUrl &&
                other.downloadUrl == downloadUrl
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is NoMediaCollectibleMediaItem && other == this
        }
    }
}
