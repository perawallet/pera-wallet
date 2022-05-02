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

package com.algorand.android.nft.ui.model

import android.os.Parcelable
import com.algorand.android.models.RecyclerListItem
import kotlinx.parcelize.Parcelize

sealed class BaseCollectibleMediaItem : Parcelable, RecyclerListItem {

    abstract val collectibleId: Long
    abstract val errorText: String
    abstract val downloadUrl: String?
    abstract val previewUrl: String?
    abstract val isOwnedByTheUser: Boolean
    abstract val itemType: ItemType

    enum class ItemType {
        IMAGE,
        VIDEO,
        UNSUPPORTED,
        GIF,
        NO_MEDIA
    }

    @Parcelize
    data class ImageCollectibleMediaItem(
        override val collectibleId: Long,
        override val errorText: String,
        override val downloadUrl: String?,
        override val previewUrl: String?,
        override val isOwnedByTheUser: Boolean
    ) : BaseCollectibleMediaItem() {

        override val itemType: ItemType = ItemType.IMAGE

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is ImageCollectibleMediaItem &&
                other.previewUrl == previewUrl &&
                other.downloadUrl == downloadUrl &&
                other.isOwnedByTheUser == isOwnedByTheUser
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is ImageCollectibleMediaItem && other == this
        }
    }

    @Parcelize
    data class GifCollectibleMediaItem(
        override val collectibleId: Long,
        override val errorText: String,
        override val downloadUrl: String?,
        override val previewUrl: String?,
        override val isOwnedByTheUser: Boolean
    ) : BaseCollectibleMediaItem() {

        override val itemType: ItemType = ItemType.GIF

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is GifCollectibleMediaItem &&
                other.previewUrl == previewUrl &&
                other.downloadUrl == downloadUrl &&
                other.isOwnedByTheUser == isOwnedByTheUser
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is GifCollectibleMediaItem && other == this
        }
    }

    @Parcelize
    data class VideoCollectibleMediaItem(
        override val collectibleId: Long,
        override val errorText: String,
        override val downloadUrl: String?,
        override val previewUrl: String?,
        override val isOwnedByTheUser: Boolean
    ) : BaseCollectibleMediaItem() {

        override val itemType: ItemType = ItemType.VIDEO

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is VideoCollectibleMediaItem &&
                other.previewUrl == previewUrl &&
                other.downloadUrl == downloadUrl &&
                other.isOwnedByTheUser == isOwnedByTheUser
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is VideoCollectibleMediaItem && other == this
        }
    }

    @Parcelize
    data class UnsupportedCollectibleMediaItem(
        override val collectibleId: Long,
        override val errorText: String,
        override val downloadUrl: String?,
        override val previewUrl: String?,
        override val isOwnedByTheUser: Boolean
    ) : BaseCollectibleMediaItem() {

        override val itemType: ItemType = ItemType.UNSUPPORTED

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is UnsupportedCollectibleMediaItem &&
                other.previewUrl == previewUrl &&
                other.downloadUrl == downloadUrl &&
                other.isOwnedByTheUser == isOwnedByTheUser
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is UnsupportedCollectibleMediaItem && other == this
        }
    }

    @Parcelize
    data class NoMediaCollectibleMediaItem(
        override val collectibleId: Long,
        override val errorText: String,
        override val downloadUrl: String?,
        override val previewUrl: String?,
        override val isOwnedByTheUser: Boolean
    ) : BaseCollectibleMediaItem() {

        override val itemType: ItemType = ItemType.NO_MEDIA

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is NoMediaCollectibleMediaItem &&
                other.previewUrl == previewUrl &&
                other.downloadUrl == downloadUrl &&
                other.isOwnedByTheUser == isOwnedByTheUser
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is NoMediaCollectibleMediaItem && other == this
        }
    }
}
