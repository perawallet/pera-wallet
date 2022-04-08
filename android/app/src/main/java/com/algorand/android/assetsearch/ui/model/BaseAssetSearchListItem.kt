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

package com.algorand.android.assetsearch.ui.model

import com.algorand.android.models.RecyclerListItem
import com.algorand.android.utils.AssetName

sealed class BaseAssetSearchListItem : RecyclerListItem {

    enum class ItemType {
        ASSET_ITEM,
        COLLECTIBLE_IMAGE_ITEM,
        COLLECTIBLE_VIDEO_ITEM,
        COLLECTIBLE_MIXED_ITEM,
        COLLECTIBLE_NOT_SUPPORTED_ITEM
    }

    abstract val assetId: Long
    abstract val fullName: AssetName
    abstract val shortName: AssetName
    abstract val isVerified: Boolean
    abstract val avatarDisplayText: AssetName
    abstract val itemType: ItemType

    data class AssetSearchItem(
        override val assetId: Long,
        override val fullName: AssetName,
        override val shortName: AssetName,
        override val isVerified: Boolean,
        override val avatarDisplayText: AssetName
    ) : BaseAssetSearchListItem() {

        override val itemType: ItemType = ItemType.ASSET_ITEM

        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AssetSearchItem && other.assetId == assetId
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AssetSearchItem && other == this
        }
    }

    sealed class BaseCollectibleSearchListItem : BaseAssetSearchListItem() {

        data class ImageCollectibleSearchItem(
            override val assetId: Long,
            override val fullName: AssetName,
            override val shortName: AssetName,
            override val avatarDisplayText: AssetName,
            override val isVerified: Boolean,
            val prismUrl: String?
        ) : BaseCollectibleSearchListItem() {

            override val itemType: ItemType = ItemType.COLLECTIBLE_IMAGE_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is ImageCollectibleSearchItem && other.assetId == assetId
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is ImageCollectibleSearchItem && other == this
            }
        }

        data class VideoCollectibleSearchItem(
            override val assetId: Long,
            override val fullName: AssetName,
            override val shortName: AssetName,
            override val avatarDisplayText: AssetName,
            override val isVerified: Boolean,
            val thumbnailUrl: String?
        ) : BaseCollectibleSearchListItem() {

            override val itemType: ItemType = ItemType.COLLECTIBLE_VIDEO_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is VideoCollectibleSearchItem && other.assetId == assetId
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is VideoCollectibleSearchItem && other == this
            }
        }

        data class MixedCollectibleSearchItem(
            override val assetId: Long,
            override val fullName: AssetName,
            override val shortName: AssetName,
            override val avatarDisplayText: AssetName,
            override val isVerified: Boolean,
            val prismUrl: String?
        ) : BaseCollectibleSearchListItem() {

            override val itemType: ItemType = ItemType.COLLECTIBLE_MIXED_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is MixedCollectibleSearchItem && other.assetId == assetId
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is MixedCollectibleSearchItem && other == this
            }
        }

        data class NotSupportedCollectibleSearchItem(
            override val assetId: Long,
            override val fullName: AssetName,
            override val shortName: AssetName,
            override val avatarDisplayText: AssetName,
            override val isVerified: Boolean
        ) : BaseCollectibleSearchListItem() {

            override val itemType: ItemType = ItemType.COLLECTIBLE_NOT_SUPPORTED_ITEM

            override fun areItemsTheSame(other: RecyclerListItem): Boolean {
                return other is NotSupportedCollectibleSearchItem && other.assetId == assetId
            }

            override fun areContentsTheSame(other: RecyclerListItem): Boolean {
                return other is NotSupportedCollectibleSearchItem && other == this
            }
        }
    }
}
