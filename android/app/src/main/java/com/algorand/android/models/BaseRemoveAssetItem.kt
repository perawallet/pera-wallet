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
 */

package com.algorand.android.models

import androidx.annotation.StringRes
import com.algorand.android.utils.AssetName
import java.math.BigInteger

sealed class BaseRemoveAssetItem : RecyclerListItem {

    enum class ItemType {
        REMOVE_ASSET_ITEM,
        REMOVE_COLLECTIBLE_IMAGE_ITEM,
        REMOVE_COLLECTIBLE_VIDEO_ITEM,
        REMOVE_COLLECTIBLE_MIXED_ITEM,
        REMOVE_COLLECTIBLE_NOT_SUPPORTED_ITEM
    }

    abstract val id: Long
    abstract val name: String?
    abstract val shortName: String?
    abstract val avatarDisplayText: AssetName
    abstract val isVerified: Boolean
    abstract val isAlgo: Boolean
    abstract val decimals: Int
    abstract val creatorPublicKey: String?
    abstract val amount: BigInteger
    abstract val formattedAmount: String
    abstract val formattedCompactAmount: String
    abstract val formattedSelectedCurrencyValue: String
    abstract val formattedSelectedCurrencyCompactValue: String
    abstract val isAmountInSelectedCurrencyVisible: Boolean
    abstract val itemType: ItemType
    abstract val notAvailableResId: Int

    override fun areItemsTheSame(other: RecyclerListItem): Boolean {
        return other is BaseRemoveAssetItem && id == other.id
    }

    override fun areContentsTheSame(other: RecyclerListItem): Boolean {
        return other is BaseRemoveAssetItem &&
            shortName == other.shortName &&
            name == other.name &&
            amount == other.amount
    }

    data class RemoveAssetItem(
        override val id: Long,
        override val name: String?,
        override val shortName: String?,
        override val avatarDisplayText: AssetName,
        override val isVerified: Boolean,
        override val isAlgo: Boolean,
        override val decimals: Int,
        override val creatorPublicKey: String?,
        override val amount: BigInteger,
        override val formattedAmount: String,
        override val formattedCompactAmount: String,
        override val formattedSelectedCurrencyValue: String,
        override val formattedSelectedCurrencyCompactValue: String,
        override val isAmountInSelectedCurrencyVisible: Boolean,
        @StringRes
        override val notAvailableResId: Int
    ) : BaseRemoveAssetItem() {
        override val itemType = ItemType.REMOVE_ASSET_ITEM
    }

    sealed class BaseRemoveCollectibleItem : BaseRemoveAssetItem() {

        data class RemoveCollectibleImageItem(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val avatarDisplayText: AssetName,
            override val isVerified: Boolean,
            override val isAlgo: Boolean,
            override val decimals: Int,
            override val creatorPublicKey: String?,
            override val amount: BigInteger,
            override val formattedAmount: String,
            override val formattedCompactAmount: String,
            override val formattedSelectedCurrencyValue: String,
            override val formattedSelectedCurrencyCompactValue: String,
            override val isAmountInSelectedCurrencyVisible: Boolean,
            @StringRes
            override val notAvailableResId: Int,
            val prismUrl: String?,
        ) : BaseRemoveCollectibleItem() {
            override val itemType = ItemType.REMOVE_COLLECTIBLE_IMAGE_ITEM
        }

        data class RemoveCollectibleVideoItem(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val avatarDisplayText: AssetName,
            override val isVerified: Boolean,
            override val isAlgo: Boolean,
            override val decimals: Int,
            override val creatorPublicKey: String?,
            override val amount: BigInteger,
            override val formattedAmount: String,
            override val formattedCompactAmount: String,
            override val formattedSelectedCurrencyValue: String,
            override val formattedSelectedCurrencyCompactValue: String,
            override val isAmountInSelectedCurrencyVisible: Boolean,
            @StringRes
            override val notAvailableResId: Int,
            val prismUrl: String?,
        ) : BaseRemoveCollectibleItem() {
            override val itemType = ItemType.REMOVE_COLLECTIBLE_VIDEO_ITEM
        }

        data class RemoveCollectibleMixedItem(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val avatarDisplayText: AssetName,
            override val isVerified: Boolean,
            override val isAlgo: Boolean,
            override val decimals: Int,
            override val creatorPublicKey: String?,
            override val amount: BigInteger,
            override val formattedAmount: String,
            override val formattedCompactAmount: String,
            override val formattedSelectedCurrencyValue: String,
            override val formattedSelectedCurrencyCompactValue: String,
            override val isAmountInSelectedCurrencyVisible: Boolean,
            @StringRes
            override val notAvailableResId: Int,
            val prismUrl: String?,
        ) : BaseRemoveCollectibleItem() {
            override val itemType = ItemType.REMOVE_COLLECTIBLE_MIXED_ITEM
        }

        data class RemoveNotSupportedCollectibleItem(
            override val id: Long,
            override val name: String?,
            override val shortName: String?,
            override val avatarDisplayText: AssetName,
            override val isVerified: Boolean,
            override val isAlgo: Boolean,
            override val decimals: Int,
            override val creatorPublicKey: String?,
            override val amount: BigInteger,
            override val formattedAmount: String,
            override val formattedCompactAmount: String,
            override val formattedSelectedCurrencyValue: String,
            override val formattedSelectedCurrencyCompactValue: String,
            override val isAmountInSelectedCurrencyVisible: Boolean,
            @StringRes
            override val notAvailableResId: Int
        ) : BaseRemoveCollectibleItem() {
            override val itemType = ItemType.REMOVE_COLLECTIBLE_NOT_SUPPORTED_ITEM
        }
    }
}
