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

package com.algorand.android.mapper

import com.algorand.android.customviews.accountandassetitem.model.BaseItemConfiguration
import com.algorand.android.decider.AssetDrawableProviderDecider
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleAudioData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleImageData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleMixedData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleVideoData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedUnsupportedCollectibleData
import com.algorand.android.models.BaseSelectAssetItem.BaseSelectCollectibleItem.SelectAudioCollectibleItem
import com.algorand.android.models.BaseSelectAssetItem.BaseSelectCollectibleItem.SelectCollectibleImageItem
import com.algorand.android.models.BaseSelectAssetItem.BaseSelectCollectibleItem.SelectMixedCollectibleItem
import com.algorand.android.models.BaseSelectAssetItem.BaseSelectCollectibleItem.SelectNotSupportedCollectibleItem
import com.algorand.android.models.BaseSelectAssetItem.BaseSelectCollectibleItem.SelectVideoCollectibleItem
import com.algorand.android.models.BaseSelectAssetItem.SelectAssetItem
import com.algorand.android.utils.AssetName
import javax.inject.Inject

class AssetSelectionMapper @Inject constructor(
    private val assetDrawableProviderDecider: AssetDrawableProviderDecider
) {

    fun mapToAssetItem(
        assetItemConfiguration: BaseItemConfiguration.BaseAssetItemConfiguration.AssetItemConfiguration
    ): SelectAssetItem {
        return SelectAssetItem(assetItemConfiguration)
    }

    fun mapToCollectibleImageItem(
        ownedCollectibleImageData: OwnedCollectibleImageData
    ): SelectCollectibleImageItem {
        return SelectCollectibleImageItem(
            id = ownedCollectibleImageData.id,
            isAlgo = ownedCollectibleImageData.isAlgo,
            shortName = ownedCollectibleImageData.shortName,
            name = ownedCollectibleImageData.name,
            amount = ownedCollectibleImageData.amount,
            formattedAmount = ownedCollectibleImageData.formattedAmount,
            formattedCompactAmount = ownedCollectibleImageData.formattedCompactAmount,
            formattedSelectedCurrencyValue = ownedCollectibleImageData.parityValueInSelectedCurrency
                .getFormattedValue(),
            formattedSelectedCurrencyCompactValue = ownedCollectibleImageData.parityValueInSelectedCurrency
                .getFormattedCompactValue(),
            isAmountInSelectedCurrencyVisible = ownedCollectibleImageData.isAmountInSelectedCurrencyVisible,
            avatarDisplayText = AssetName.create(ownedCollectibleImageData.name),
            prismUrl = ownedCollectibleImageData.prismUrl,
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(
                assetId = ownedCollectibleImageData.id
            ),
            optedInAtRound = ownedCollectibleImageData.optedInAtRound,
            amountInSelectedCurrency = ownedCollectibleImageData.parityValueInSelectedCurrency.amountAsCurrency
        )
    }

    fun mapToCollectibleVideoItem(
        ownedCollectibleVideoData: OwnedCollectibleVideoData
    ): SelectVideoCollectibleItem {
        return SelectVideoCollectibleItem(
            id = ownedCollectibleVideoData.id,
            isAlgo = ownedCollectibleVideoData.isAlgo,
            shortName = ownedCollectibleVideoData.shortName,
            name = ownedCollectibleVideoData.name,
            amount = ownedCollectibleVideoData.amount,
            formattedAmount = ownedCollectibleVideoData.formattedAmount,
            formattedCompactAmount = ownedCollectibleVideoData.formattedCompactAmount,
            formattedSelectedCurrencyValue = ownedCollectibleVideoData.parityValueInSelectedCurrency
                .getFormattedValue(),
            formattedSelectedCurrencyCompactValue = ownedCollectibleVideoData.parityValueInSelectedCurrency
                .getFormattedCompactValue(),
            isAmountInSelectedCurrencyVisible = ownedCollectibleVideoData.isAmountInSelectedCurrencyVisible,
            avatarDisplayText = AssetName.create(ownedCollectibleVideoData.name),
            prismUrl = ownedCollectibleVideoData.prismUrl,
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(
                assetId = ownedCollectibleVideoData.id
            ),
            optedInAtRound = ownedCollectibleVideoData.optedInAtRound,
            amountInSelectedCurrency = ownedCollectibleVideoData.parityValueInSelectedCurrency.amountAsCurrency
        )
    }

    fun mapToCollectibleAudioItem(
        ownedCollectibleAudioData: OwnedCollectibleAudioData
    ): SelectAudioCollectibleItem {
        return SelectAudioCollectibleItem(
            id = ownedCollectibleAudioData.id,
            isAlgo = ownedCollectibleAudioData.isAlgo,
            shortName = ownedCollectibleAudioData.shortName,
            name = ownedCollectibleAudioData.name,
            amount = ownedCollectibleAudioData.amount,
            formattedAmount = ownedCollectibleAudioData.formattedAmount,
            formattedCompactAmount = ownedCollectibleAudioData.formattedCompactAmount,
            formattedSelectedCurrencyValue = ownedCollectibleAudioData.parityValueInSelectedCurrency
                .getFormattedValue(),
            formattedSelectedCurrencyCompactValue = ownedCollectibleAudioData.parityValueInSelectedCurrency
                .getFormattedCompactValue(),
            isAmountInSelectedCurrencyVisible = ownedCollectibleAudioData.isAmountInSelectedCurrencyVisible,
            avatarDisplayText = AssetName.create(ownedCollectibleAudioData.name),
            prismUrl = ownedCollectibleAudioData.prismUrl,
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(
                assetId = ownedCollectibleAudioData.id
            ),
            optedInAtRound = ownedCollectibleAudioData.optedInAtRound,
            amountInSelectedCurrency = ownedCollectibleAudioData.parityValueInSelectedCurrency.amountAsCurrency
        )
    }

    fun mapToCollectibleMixedItem(
        ownedCollectibleMixedData: OwnedCollectibleMixedData
    ): SelectMixedCollectibleItem {
        return SelectMixedCollectibleItem(
            id = ownedCollectibleMixedData.id,
            isAlgo = ownedCollectibleMixedData.isAlgo,
            shortName = ownedCollectibleMixedData.shortName,
            name = ownedCollectibleMixedData.name,
            amount = ownedCollectibleMixedData.amount,
            formattedAmount = ownedCollectibleMixedData.formattedAmount,
            formattedCompactAmount = ownedCollectibleMixedData.formattedCompactAmount,
            formattedSelectedCurrencyValue = ownedCollectibleMixedData.parityValueInSelectedCurrency
                .getFormattedValue(),
            formattedSelectedCurrencyCompactValue = ownedCollectibleMixedData.parityValueInSelectedCurrency
                .getFormattedCompactValue(),
            isAmountInSelectedCurrencyVisible = ownedCollectibleMixedData.isAmountInSelectedCurrencyVisible,
            avatarDisplayText = AssetName.create(ownedCollectibleMixedData.name),
            prismUrl = ownedCollectibleMixedData.prismUrl,
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(
                assetId = ownedCollectibleMixedData.id
            ),
            optedInAtRound = ownedCollectibleMixedData.optedInAtRound,
            amountInSelectedCurrency = ownedCollectibleMixedData.parityValueInSelectedCurrency.amountAsCurrency
        )
    }

    fun mapToCollectibleNotSupportedItem(
        ownedUnsupportedCollectibleData: OwnedUnsupportedCollectibleData
    ): SelectNotSupportedCollectibleItem {
        return SelectNotSupportedCollectibleItem(
            id = ownedUnsupportedCollectibleData.id,
            isAlgo = ownedUnsupportedCollectibleData.isAlgo,
            shortName = ownedUnsupportedCollectibleData.shortName,
            name = ownedUnsupportedCollectibleData.name,
            amount = ownedUnsupportedCollectibleData.amount,
            formattedAmount = ownedUnsupportedCollectibleData.formattedAmount,
            formattedCompactAmount = ownedUnsupportedCollectibleData.formattedCompactAmount,
            formattedSelectedCurrencyValue = ownedUnsupportedCollectibleData.parityValueInSelectedCurrency
                .getFormattedValue(),
            formattedSelectedCurrencyCompactValue = ownedUnsupportedCollectibleData.parityValueInSelectedCurrency
                .getFormattedCompactValue(),
            isAmountInSelectedCurrencyVisible = ownedUnsupportedCollectibleData.isAmountInSelectedCurrencyVisible,
            avatarDisplayText = AssetName.create(ownedUnsupportedCollectibleData.name),
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(
                assetId = ownedUnsupportedCollectibleData.id
            ),
            optedInAtRound = ownedUnsupportedCollectibleData.optedInAtRound,
            amountInSelectedCurrency = ownedUnsupportedCollectibleData.parityValueInSelectedCurrency.amountAsCurrency
        )
    }
}
