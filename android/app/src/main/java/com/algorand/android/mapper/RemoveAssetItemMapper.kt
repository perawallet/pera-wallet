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

import androidx.annotation.StringRes
import com.algorand.android.decider.AssetDrawableProviderDecider
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleImageData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleMixedData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleVideoData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedUnsupportedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData
import com.algorand.android.models.BaseRemoveAssetItem.BaseRemovableItem.BaseRemoveCollectibleItem.RemoveCollectibleImageItem
import com.algorand.android.models.BaseRemoveAssetItem.BaseRemovableItem.BaseRemoveCollectibleItem.RemoveCollectibleMixedItem
import com.algorand.android.models.BaseRemoveAssetItem.BaseRemovableItem.BaseRemoveCollectibleItem.RemoveCollectibleVideoItem
import com.algorand.android.models.BaseRemoveAssetItem.BaseRemovableItem.BaseRemoveCollectibleItem.RemoveNotSupportedCollectibleItem
import com.algorand.android.models.BaseRemoveAssetItem.BaseRemovableItem.RemoveAssetItem
import com.algorand.android.models.BaseRemoveAssetItem.DescriptionViewItem
import com.algorand.android.models.BaseRemoveAssetItem.SearchViewItem
import com.algorand.android.models.BaseRemoveAssetItem.TitleViewItem
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.modules.verificationtier.ui.decider.VerificationTierConfigurationDecider
import com.algorand.android.utils.AssetName
import javax.inject.Inject

class RemoveAssetItemMapper @Inject constructor(
    private val verificationTierConfigurationDecider: VerificationTierConfigurationDecider,
    private val assetDrawableProviderDecider: AssetDrawableProviderDecider
) {

    fun mapTo(
        ownedAssetData: OwnedAssetData,
        actionItemButtonState: AccountAssetItemButtonState
    ): RemoveAssetItem {
        return with(ownedAssetData) {
            RemoveAssetItem(
                id = id,
                name = AssetName.create(name),
                shortName = AssetName.create(shortName),
                amount = amount,
                creatorPublicKey = creatorPublicKey,
                decimals = decimals,
                formattedAmount = formattedAmount,
                formattedCompactAmount = formattedCompactAmount,
                formattedSelectedCurrencyValue = parityValueInSelectedCurrency.getFormattedValue(),
                formattedSelectedCurrencyCompactValue = parityValueInSelectedCurrency.getFormattedCompactValue(),
                isAmountInSelectedCurrencyVisible = isAmountInSelectedCurrencyVisible,
                verificationTierConfiguration =
                verificationTierConfigurationDecider.decideVerificationTierConfiguration(verificationTier),
                prismUrl = prismUrl,
                baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(id),
                actionItemButtonState = actionItemButtonState,
                amountInPrimaryCurrency = parityValueInSelectedCurrency.amountAsCurrency
            )
        }
    }

    fun mapTo(
        ownedCollectibleImageData: OwnedCollectibleImageData,
        actionItemButtonState: AccountAssetItemButtonState
    ): RemoveCollectibleImageItem {
        return with(ownedCollectibleImageData) {
            RemoveCollectibleImageItem(
                id = id,
                name = AssetName.create(name),
                shortName = AssetName.create(shortName),
                amount = amount,
                creatorPublicKey = creatorPublicKey,
                decimals = decimals,
                formattedAmount = formattedAmount,
                formattedCompactAmount = formattedCompactAmount,
                formattedSelectedCurrencyValue = parityValueInSelectedCurrency.getFormattedValue(),
                formattedSelectedCurrencyCompactValue = parityValueInSelectedCurrency.getFormattedCompactValue(),
                isAmountInSelectedCurrencyVisible = isAmountInSelectedCurrencyVisible,
                prismUrl = prismUrl,
                baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(id),
                actionItemButtonState = actionItemButtonState,
                optedInAtRound = optedInAtRound,
                amountInPrimaryCurrency = parityValueInSelectedCurrency.amountAsCurrency
            )
        }
    }

    fun mapTo(
        ownedCollectibleImageData: OwnedCollectibleVideoData,
        actionItemButtonState: AccountAssetItemButtonState
    ): RemoveCollectibleVideoItem {
        return with(ownedCollectibleImageData) {
            RemoveCollectibleVideoItem(
                id = id,
                name = AssetName.create(name),
                shortName = AssetName.create(shortName),
                amount = amount,
                creatorPublicKey = creatorPublicKey,
                decimals = decimals,
                formattedAmount = formattedAmount,
                formattedCompactAmount = formattedCompactAmount,
                formattedSelectedCurrencyValue = parityValueInSelectedCurrency.getFormattedValue(),
                formattedSelectedCurrencyCompactValue = parityValueInSelectedCurrency.getFormattedCompactValue(),
                isAmountInSelectedCurrencyVisible = isAmountInSelectedCurrencyVisible,
                prismUrl = prismUrl,
                baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(id),
                actionItemButtonState = actionItemButtonState,
                optedInAtRound = optedInAtRound,
                amountInPrimaryCurrency = parityValueInSelectedCurrency.amountAsCurrency
            )
        }
    }

    fun mapTo(
        ownedCollectibleMixedData: OwnedCollectibleMixedData,
        actionItemButtonState: AccountAssetItemButtonState
    ): RemoveCollectibleMixedItem {
        return with(ownedCollectibleMixedData) {
            RemoveCollectibleMixedItem(
                id = id,
                name = AssetName.create(name),
                shortName = AssetName.create(shortName),
                amount = amount,
                creatorPublicKey = creatorPublicKey,
                decimals = decimals,
                formattedAmount = formattedAmount,
                formattedCompactAmount = formattedCompactAmount,
                formattedSelectedCurrencyValue = parityValueInSelectedCurrency.getFormattedValue(),
                formattedSelectedCurrencyCompactValue = parityValueInSelectedCurrency.getFormattedCompactValue(),
                isAmountInSelectedCurrencyVisible = isAmountInSelectedCurrencyVisible,
                prismUrl = prismUrl,
                baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(id),
                actionItemButtonState = actionItemButtonState,
                optedInAtRound = optedInAtRound,
                amountInPrimaryCurrency = parityValueInSelectedCurrency.amountAsCurrency
            )
        }
    }

    fun mapTo(
        ownedUnsupportedCollectibleData: OwnedUnsupportedCollectibleData,
        actionItemButtonState: AccountAssetItemButtonState
    ): RemoveNotSupportedCollectibleItem {
        return with(ownedUnsupportedCollectibleData) {
            RemoveNotSupportedCollectibleItem(
                id = id,
                name = AssetName.create(name),
                shortName = AssetName.create(shortName),
                amount = amount,
                creatorPublicKey = creatorPublicKey,
                decimals = decimals,
                formattedAmount = formattedAmount,
                formattedCompactAmount = formattedCompactAmount,
                formattedSelectedCurrencyValue = parityValueInSelectedCurrency.getFormattedValue(),
                formattedSelectedCurrencyCompactValue = parityValueInSelectedCurrency.getFormattedCompactValue(),
                isAmountInSelectedCurrencyVisible = isAmountInSelectedCurrencyVisible,
                baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(id),
                actionItemButtonState = actionItemButtonState,
                optedInAtRound = optedInAtRound,
                amountInPrimaryCurrency = parityValueInSelectedCurrency.amountAsCurrency
            )
        }
    }

    fun mapToTitleItem(@StringRes titleTextRes: Int): TitleViewItem {
        return TitleViewItem(titleTextRes)
    }

    fun mapToDescriptionItem(@StringRes descriptionTextRes: Int): DescriptionViewItem {
        return DescriptionViewItem(descriptionTextRes)
    }

    fun mapToSearchItem(@StringRes searchViewHintResId: Int): SearchViewItem {
        return SearchViewItem(searchViewHintResId)
    }
}
