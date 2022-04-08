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

package com.algorand.android.mapper

import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleImageData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleMixedData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleVideoData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedUnsupportedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData
import com.algorand.android.models.BaseSelectAssetItem.BaseSelectCollectibleItem.SelectCollectibleImageItem
import com.algorand.android.models.BaseSelectAssetItem.BaseSelectCollectibleItem.SelectMixedCollectibleItem
import com.algorand.android.models.BaseSelectAssetItem.BaseSelectCollectibleItem.SelectNotSupportedCollectibleItem
import com.algorand.android.models.BaseSelectAssetItem.BaseSelectCollectibleItem.SelectVideoCollectibleItem
import com.algorand.android.models.BaseSelectAssetItem.SelectAssetItem
import com.algorand.android.utils.AssetName
import javax.inject.Inject

class AssetSelectionMapper @Inject constructor() {

    fun mapToAssetItem(
        accountAssetData: OwnedAssetData
    ): SelectAssetItem {
        return SelectAssetItem(
            id = accountAssetData.id,
            isAlgo = accountAssetData.isAlgo,
            isVerified = accountAssetData.isVerified,
            shortName = accountAssetData.shortName,
            name = accountAssetData.name,
            amount = accountAssetData.amount,
            formattedAmount = accountAssetData.formattedAmount,
            formattedSelectedCurrencyValue = accountAssetData.formattedSelectedCurrencyValue,
            isAmountInSelectedCurrencyVisible = accountAssetData.isAmountInSelectedCurrencyVisible,
            avatarDisplayText = AssetName.create(accountAssetData.name)
        )
    }

    fun mapToCollectibleImageItem(
        ownedCollectibleImageData: OwnedCollectibleImageData
    ): SelectCollectibleImageItem {
        return SelectCollectibleImageItem(
            id = ownedCollectibleImageData.id,
            isAlgo = ownedCollectibleImageData.isAlgo,
            isVerified = ownedCollectibleImageData.isVerified,
            shortName = ownedCollectibleImageData.shortName,
            name = ownedCollectibleImageData.name,
            amount = ownedCollectibleImageData.amount,
            formattedAmount = ownedCollectibleImageData.formattedAmount,
            formattedSelectedCurrencyValue = ownedCollectibleImageData.formattedSelectedCurrencyValue,
            isAmountInSelectedCurrencyVisible = ownedCollectibleImageData.isAmountInSelectedCurrencyVisible,
            avatarDisplayText = AssetName.create(ownedCollectibleImageData.name),
            prismUrl = ownedCollectibleImageData.prismUrl
        )
    }

    fun mapToCollectibleVideoItem(
        ownedCollectibleVideoData: OwnedCollectibleVideoData
    ): SelectVideoCollectibleItem {
        return SelectVideoCollectibleItem(
            id = ownedCollectibleVideoData.id,
            isAlgo = ownedCollectibleVideoData.isAlgo,
            isVerified = ownedCollectibleVideoData.isVerified,
            shortName = ownedCollectibleVideoData.shortName,
            name = ownedCollectibleVideoData.name,
            amount = ownedCollectibleVideoData.amount,
            formattedAmount = ownedCollectibleVideoData.formattedAmount,
            formattedSelectedCurrencyValue = ownedCollectibleVideoData.formattedSelectedCurrencyValue,
            isAmountInSelectedCurrencyVisible = ownedCollectibleVideoData.isAmountInSelectedCurrencyVisible,
            avatarDisplayText = AssetName.create(ownedCollectibleVideoData.name),
            thumbnailPrismUrl = ownedCollectibleVideoData.thumbnailPrismUrl
        )
    }

    fun mapToCollectibleMixedItem(
        ownedCollectibleVideoData: OwnedCollectibleMixedData
    ): SelectMixedCollectibleItem {
        return SelectMixedCollectibleItem(
            id = ownedCollectibleVideoData.id,
            isAlgo = ownedCollectibleVideoData.isAlgo,
            isVerified = ownedCollectibleVideoData.isVerified,
            shortName = ownedCollectibleVideoData.shortName,
            name = ownedCollectibleVideoData.name,
            amount = ownedCollectibleVideoData.amount,
            formattedAmount = ownedCollectibleVideoData.formattedAmount,
            formattedSelectedCurrencyValue = ownedCollectibleVideoData.formattedSelectedCurrencyValue,
            isAmountInSelectedCurrencyVisible = ownedCollectibleVideoData.isAmountInSelectedCurrencyVisible,
            avatarDisplayText = AssetName.create(ownedCollectibleVideoData.name),
            thumbnailPrismUrl = ownedCollectibleVideoData.thumbnailPrismUrl
        )
    }

    fun mapToCollectibleNotSupportedItem(
        ownedUnsupportedCollectibleData: OwnedUnsupportedCollectibleData
    ): SelectNotSupportedCollectibleItem {
        return SelectNotSupportedCollectibleItem(
            id = ownedUnsupportedCollectibleData.id,
            isAlgo = ownedUnsupportedCollectibleData.isAlgo,
            isVerified = ownedUnsupportedCollectibleData.isVerified,
            shortName = ownedUnsupportedCollectibleData.shortName,
            name = ownedUnsupportedCollectibleData.name,
            amount = ownedUnsupportedCollectibleData.amount,
            formattedAmount = ownedUnsupportedCollectibleData.formattedAmount,
            formattedSelectedCurrencyValue = ownedUnsupportedCollectibleData.formattedSelectedCurrencyValue,
            isAmountInSelectedCurrencyVisible = ownedUnsupportedCollectibleData.isAmountInSelectedCurrencyVisible,
            avatarDisplayText = AssetName.create(ownedUnsupportedCollectibleData.name)
        )
    }
}
