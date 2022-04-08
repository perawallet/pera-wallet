/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.models

import com.algorand.android.utils.AssetName
import java.math.BigInteger

sealed class BaseSelectAssetItem : RecyclerListItem {

    enum class ItemType {
        SELECT_ASSET_TEM,
        SELECT_COLLECTIBLE_IMAGE_ITEM,
        SELECT_COLLECTIBLE_VIDEO_ITEM,
        SELECT_COLLECTIBLE_NOT_SUPPORTED_ITEM,
        SELECT_COLLECTIBLE_MIXED_ITEM
    }

    abstract val id: Long
    abstract val name: String?
    abstract val shortName: String?
    abstract val avatarDisplayText: AssetName
    abstract val isVerified: Boolean
    abstract val isAlgo: Boolean
    abstract val amount: BigInteger
    abstract val formattedAmount: String
    abstract val formattedSelectedCurrencyValue: String
    abstract val isAmountInSelectedCurrencyVisible: Boolean
    abstract val itemType: ItemType

    override fun areItemsTheSame(other: RecyclerListItem): Boolean {
        return other is BaseSelectAssetItem && id == other.id
    }

    override fun areContentsTheSame(other: RecyclerListItem): Boolean {
        return other is BaseSelectAssetItem && shortName == other.shortName && name == other.name
    }

    data class SelectAssetItem(
        override val id: Long,
        override val isAlgo: Boolean,
        override val isVerified: Boolean,
        override val shortName: String?,
        override val name: String?,
        override val formattedAmount: String,
        override val formattedSelectedCurrencyValue: String,
        override val isAmountInSelectedCurrencyVisible: Boolean,
        override val avatarDisplayText: AssetName,
        override val amount: BigInteger
    ) : BaseSelectAssetItem() {
        override val itemType: ItemType = ItemType.SELECT_ASSET_TEM
    }

    sealed class BaseSelectCollectibleItem : BaseSelectAssetItem() {

        data class SelectCollectibleImageItem(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val avatarDisplayText: AssetName,
            override val isVerified: Boolean,
            override val isAlgo: Boolean,
            override val amount: BigInteger,
            override val formattedAmount: String,
            override val formattedSelectedCurrencyValue: String,
            override val isAmountInSelectedCurrencyVisible: Boolean,
            val prismUrl: String?
        ) : BaseSelectCollectibleItem() {
            override val itemType: ItemType = ItemType.SELECT_COLLECTIBLE_IMAGE_ITEM
        }

        data class SelectVideoCollectibleItem(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val avatarDisplayText: AssetName,
            override val isVerified: Boolean,
            override val isAlgo: Boolean,
            override val amount: BigInteger,
            override val formattedAmount: String,
            override val formattedSelectedCurrencyValue: String,
            override val isAmountInSelectedCurrencyVisible: Boolean,
            val thumbnailPrismUrl: String?
        ) : BaseSelectCollectibleItem() {
            override val itemType: ItemType = ItemType.SELECT_COLLECTIBLE_VIDEO_ITEM
        }

        data class SelectMixedCollectibleItem(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val avatarDisplayText: AssetName,
            override val isVerified: Boolean,
            override val isAlgo: Boolean,
            override val amount: BigInteger,
            override val formattedAmount: String,
            override val formattedSelectedCurrencyValue: String,
            override val isAmountInSelectedCurrencyVisible: Boolean,
            val thumbnailPrismUrl: String?
        ) : BaseSelectCollectibleItem() {
            override val itemType: ItemType = ItemType.SELECT_COLLECTIBLE_MIXED_ITEM
        }

        data class SelectNotSupportedCollectibleItem(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val avatarDisplayText: AssetName,
            override val isVerified: Boolean,
            override val isAlgo: Boolean,
            override val amount: BigInteger,
            override val formattedAmount: String,
            override val formattedSelectedCurrencyValue: String,
            override val isAmountInSelectedCurrencyVisible: Boolean
        ) : BaseSelectCollectibleItem() {
            override val itemType: ItemType = ItemType.SELECT_COLLECTIBLE_NOT_SUPPORTED_ITEM
        }
    }
}
