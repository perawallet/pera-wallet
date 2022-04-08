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

package com.algorand.android.mapper

import com.algorand.android.R
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleImageData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleMixedData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleVideoData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedUnsupportedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData
import com.algorand.android.models.BaseRemoveAssetItem.BaseRemoveCollectibleItem.RemoveCollectibleImageItem
import com.algorand.android.models.BaseRemoveAssetItem.BaseRemoveCollectibleItem.RemoveCollectibleMixedItem
import com.algorand.android.models.BaseRemoveAssetItem.BaseRemoveCollectibleItem.RemoveCollectibleVideoItem
import com.algorand.android.models.BaseRemoveAssetItem.BaseRemoveCollectibleItem.RemoveNotSupportedCollectibleItem
import com.algorand.android.models.BaseRemoveAssetItem.RemoveAssetItem
import com.algorand.android.utils.AssetName
import javax.inject.Inject

class RemoveAssetItemMapper @Inject constructor() {

    fun mapTo(ownedAssetData: OwnedAssetData): RemoveAssetItem {
        return with(ownedAssetData) {
            RemoveAssetItem(
                id = id,
                name = name,
                shortName = shortName,
                avatarDisplayText = AssetName.create(name),
                isVerified = isVerified,
                isAlgo = isAlgo,
                amount = amount,
                creatorPublicKey = creatorPublicKey,
                decimals = decimals,
                formattedAmount = formattedAmount,
                formattedSelectedCurrencyValue = formattedSelectedCurrencyValue,
                isAmountInSelectedCurrencyVisible = isAmountInSelectedCurrencyVisible,
                notAvailableResId = R.string.not_available_shortened
            )
        }
    }

    fun mapTo(ownedCollectibleImageData: OwnedCollectibleImageData): RemoveCollectibleImageItem {
        return with(ownedCollectibleImageData) {
            RemoveCollectibleImageItem(
                id = id,
                name = name,
                shortName = shortName,
                avatarDisplayText = AssetName.create(name),
                isVerified = isVerified,
                isAlgo = isAlgo,
                amount = amount,
                creatorPublicKey = creatorPublicKey,
                decimals = decimals,
                formattedAmount = formattedAmount,
                formattedSelectedCurrencyValue = formattedSelectedCurrencyValue,
                isAmountInSelectedCurrencyVisible = isAmountInSelectedCurrencyVisible,
                prismUrl = prismUrl,
                notAvailableResId = R.string.not_available_shortened
            )
        }
    }

    fun mapTo(ownedCollectibleImageData: OwnedCollectibleVideoData): RemoveCollectibleVideoItem {
        return with(ownedCollectibleImageData) {
            RemoveCollectibleVideoItem(
                id = id,
                name = name,
                shortName = shortName,
                avatarDisplayText = AssetName.create(name),
                isVerified = isVerified,
                isAlgo = isAlgo,
                amount = amount,
                creatorPublicKey = creatorPublicKey,
                decimals = decimals,
                formattedAmount = formattedAmount,
                formattedSelectedCurrencyValue = formattedSelectedCurrencyValue,
                isAmountInSelectedCurrencyVisible = isAmountInSelectedCurrencyVisible,
                prismUrl = thumbnailPrismUrl,
                notAvailableResId = R.string.not_available_shortened
            )
        }
    }

    fun mapTo(ownedCollectibleMixedData: OwnedCollectibleMixedData): RemoveCollectibleMixedItem {
        return with(ownedCollectibleMixedData) {
            RemoveCollectibleMixedItem(
                id = id,
                name = name,
                shortName = shortName,
                avatarDisplayText = AssetName.create(name),
                isVerified = isVerified,
                isAlgo = isAlgo,
                amount = amount,
                creatorPublicKey = creatorPublicKey,
                decimals = decimals,
                formattedAmount = formattedAmount,
                formattedSelectedCurrencyValue = formattedSelectedCurrencyValue,
                isAmountInSelectedCurrencyVisible = isAmountInSelectedCurrencyVisible,
                prismUrl = thumbnailPrismUrl,
                notAvailableResId = R.string.not_available_shortened
            )
        }
    }

    fun mapTo(ownedUnsupportedCollectibleData: OwnedUnsupportedCollectibleData): RemoveNotSupportedCollectibleItem {
        return with(ownedUnsupportedCollectibleData) {
            RemoveNotSupportedCollectibleItem(
                id = id,
                name = name,
                shortName = shortName,
                avatarDisplayText = AssetName.create(name),
                isVerified = isVerified,
                isAlgo = isAlgo,
                amount = amount,
                creatorPublicKey = creatorPublicKey,
                decimals = decimals,
                formattedAmount = formattedAmount,
                formattedSelectedCurrencyValue = formattedSelectedCurrencyValue,
                isAmountInSelectedCurrencyVisible = isAmountInSelectedCurrencyVisible,
                notAvailableResId = R.string.not_available_shortened
            )
        }
    }
}
