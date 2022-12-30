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

package com.algorand.android.modules.accountdetail.assets.ui.mapper

import com.algorand.android.R
import com.algorand.android.decider.AssetDrawableProviderDecider
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData
import com.algorand.android.modules.accountdetail.assets.ui.decider.NFTIndicatorDrawableDecider
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem
import com.algorand.android.modules.collectibles.listingviewtype.domain.model.NFTListingViewType
import com.algorand.android.modules.collectibles.util.deciders.NFTAmountFormatDecider
import com.algorand.android.modules.verificationtier.ui.decider.VerificationTierConfigurationDecider
import com.algorand.android.utils.AssetName
import javax.inject.Inject

// TODO Rename this function to make it screen independent
class AccountDetailAssetItemMapper @Inject constructor(
    private val verificationTierConfigurationDecider: VerificationTierConfigurationDecider,
    private val assetDrawableProviderDecider: AssetDrawableProviderDecider,
    private val nftIndicatorDrawableDecider: NFTIndicatorDrawableDecider,
    private val nftAmountFormatDecider: NFTAmountFormatDecider
) {

    fun mapToOwnedAssetItem(
        accountAssetData: BaseAccountAssetData.BaseOwnedAssetData
    ): AccountDetailAssetsItem.BaseAssetItem.BaseOwnedItem.AssetItem {
        return with(accountAssetData) {
            AccountDetailAssetsItem.BaseAssetItem.BaseOwnedItem.AssetItem(
                id = id,
                name = AssetName.create(name),
                shortName = AssetName.createShortName(shortName),
                formattedAmount = formattedCompactAmount,
                formattedDisplayedCurrencyValue = getSelectedCurrencyParityValue()
                    .getFormattedCompactValue(),
                isAmountInDisplayedCurrencyVisible = isAmountInSelectedCurrencyVisible,
                verificationTierConfiguration = verificationTierConfigurationDecider
                    .decideVerificationTierConfiguration(verificationTier),
                baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(id),
                amountInSelectedCurrency = parityValueInSelectedCurrency.amountAsCurrency
            )
        }
    }

    fun mapToPendingAdditionAssetItem(
        accountAssetData: PendingAssetData.AdditionAssetData
    ): AccountDetailAssetsItem.BaseAssetItem.BasePendingItem.AssetItem.AdditionItem {
        return AccountDetailAssetsItem.BaseAssetItem.BasePendingItem.AssetItem.AdditionItem(
            id = accountAssetData.id,
            name = AssetName.create(accountAssetData.name),
            shortName = AssetName.createShortName(accountAssetData.shortName),
            actionDescriptionResId = R.string.adding_asset,
            verificationTierConfiguration = verificationTierConfigurationDecider.decideVerificationTierConfiguration(
                accountAssetData.verificationTier
            ),
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(accountAssetData.id)
        )
    }

    fun mapToPendingRemovalAssetItem(
        accountAssetData: PendingAssetData.DeletionAssetData
    ): AccountDetailAssetsItem.BaseAssetItem.BasePendingItem.AssetItem.RemovalItem {
        return AccountDetailAssetsItem.BaseAssetItem.BasePendingItem.AssetItem.RemovalItem(
            id = accountAssetData.id,
            name = AssetName.create(accountAssetData.name),
            shortName = AssetName.createShortName(accountAssetData.shortName),
            actionDescriptionResId = R.string.removing_asset,
            verificationTierConfiguration = verificationTierConfigurationDecider.decideVerificationTierConfiguration(
                accountAssetData.verificationTier
            ),
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(accountAssetData.id)
        )
    }

    fun mapToQuickActionsItem(isSwapButtonSelected: Boolean): AccountDetailAssetsItem.QuickActionsItem {
        return AccountDetailAssetsItem.QuickActionsItem(isSwapButtonSelected = isSwapButtonSelected)
    }

    fun mapToSearchViewItem(query: String): AccountDetailAssetsItem.SearchViewItem {
        return AccountDetailAssetsItem.SearchViewItem(query = query)
    }

    fun mapToTitleItem(titleRes: Int, isAddAssetButtonVisible: Boolean): AccountDetailAssetsItem.TitleItem {
        return AccountDetailAssetsItem.TitleItem(titleRes, isAddAssetButtonVisible)
    }

    fun mapToNoAssetFoundViewItem(): AccountDetailAssetsItem.NoAssetFoundViewItem {
        return AccountDetailAssetsItem.NoAssetFoundViewItem
    }

    fun mapToRequiredMinimumBalanceItem(
        formattedRequiredMinimumBalance: String
    ): AccountDetailAssetsItem.RequiredMinimumBalanceItem {
        return AccountDetailAssetsItem.RequiredMinimumBalanceItem(
            formattedRequiredMinimumBalance = formattedRequiredMinimumBalance
        )
    }

    fun mapToOwnedNFTItem(
        accountAssetData: BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData,
        isHoldingByWatchAccount: Boolean,
        isOwned: Boolean,
        nftListingViewType: NFTListingViewType,
        isAmountVisible: Boolean,
        shouldDecreaseOpacity: Boolean
    ): AccountDetailAssetsItem.BaseAssetItem.BaseOwnedItem.NFTItem {
        return with(accountAssetData) {
            AccountDetailAssetsItem.BaseAssetItem.BaseOwnedItem.NFTItem(
                id = id,
                name = AssetName.create(name),
                shortName = AssetName.createShortName(shortName),
                baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(id),
                formattedAmount = nftAmountFormatDecider.decideNFTAmountFormat(
                    nftAmount = amount,
                    fractionalDecimal = decimals,
                    formattedAmount = formattedAmount,
                    formattedCompactAmount = formattedCompactAmount
                ),
                nftIndicatorDrawable = nftIndicatorDrawableDecider.decideNFTIndicatorDrawable(
                    isOwned = isOwned,
                    isHoldingByWatchAccount = isHoldingByWatchAccount,
                    nftListingViewType = nftListingViewType
                ),
                shouldDecreaseOpacity = shouldDecreaseOpacity,
                isAmountVisible = isAmountVisible,
                collectionName = accountAssetData.collectionName
            )
        }
    }

    fun mapToPendingAdditionNFTITem(
        accountAssetData: PendingAssetData.BasePendingCollectibleData
    ): AccountDetailAssetsItem.BaseAssetItem.BasePendingItem.NFTItem.AdditionItem {
        return AccountDetailAssetsItem.BaseAssetItem.BasePendingItem.NFTItem.AdditionItem(
            id = accountAssetData.id,
            name = AssetName.create(accountAssetData.name),
            shortName = AssetName.createShortName(accountAssetData.shortName),
            actionDescriptionResId = R.string.adding_asset,
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(accountAssetData.id),
            collectionName = accountAssetData.collectionName
        )
    }

    fun mapToPendingRemovalNFTItem(
        accountAssetData: PendingAssetData.BasePendingCollectibleData
    ): AccountDetailAssetsItem.BaseAssetItem.BasePendingItem.NFTItem.RemovalItem {
        return AccountDetailAssetsItem.BaseAssetItem.BasePendingItem.NFTItem.RemovalItem(
            id = accountAssetData.id,
            name = AssetName.create(accountAssetData.name),
            shortName = AssetName.createShortName(accountAssetData.shortName),
            actionDescriptionResId = R.string.removing_asset,
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(accountAssetData.id),
            collectionName = accountAssetData.collectionName
        )
    }
}
