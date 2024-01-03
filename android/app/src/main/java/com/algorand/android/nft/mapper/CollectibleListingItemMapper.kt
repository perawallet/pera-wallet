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

package com.algorand.android.nft.mapper

import androidx.annotation.StringRes
import com.algorand.android.decider.AssetDrawableProviderDecider
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.modules.accountdetail.assets.ui.decider.NFTIndicatorDrawableDecider
import com.algorand.android.modules.collectibles.listingviewtype.domain.model.NFTListingViewType
import com.algorand.android.modules.collectibles.util.deciders.NFTAmountFormatDecider
import com.algorand.android.nft.domain.decider.BaseCollectibleListItemItemTypeDecider
import com.algorand.android.nft.ui.model.BaseCollectibleListData
import com.algorand.android.nft.ui.model.BaseCollectibleListItem
import com.algorand.android.nft.ui.model.CollectiblesListingPreview
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.Event
import javax.inject.Inject

class CollectibleListingItemMapper @Inject constructor(
    private val assetDrawableProviderDecider: AssetDrawableProviderDecider,
    private val baseCollectibleListItemItemTypeDecider: BaseCollectibleListItemItemTypeDecider,
    private val nftIndicatorDrawableDecider: NFTIndicatorDrawableDecider,
    private val nftAmountFormatDecider: NFTAmountFormatDecider
) {

    @SuppressWarnings("LongParameterList")
    fun mapToPreviewItem(
        isLoadingVisible: Boolean,
        isEmptyStateVisible: Boolean,
        isErrorVisible: Boolean,
        isReceiveButtonVisible: Boolean,
        filteredCollectibleCount: Int,
        isClearFilterButtonVisible: Boolean,
        itemList: List<BaseCollectibleListItem>,
        isAccountFabVisible: Boolean,
        isAddCollectibleFloatingActionButtonVisible: Boolean
    ): CollectiblesListingPreview {
        return CollectiblesListingPreview(
            isLoadingVisible = isLoadingVisible,
            isEmptyStateVisible = isEmptyStateVisible,
            isErrorVisible = isErrorVisible,
            isReceiveButtonVisible = isReceiveButtonVisible,
            baseCollectibleListItems = itemList,
            isClearFilterButtonVisible = isClearFilterButtonVisible,
            filteredCollectibleCount = filteredCollectibleCount,
            isAccountFabVisible = isAccountFabVisible,
            isAddCollectibleFloatingActionButtonVisible = isAddCollectibleFloatingActionButtonVisible
        )
    }

    fun mapToSimpleNFTItem(
        collectible: BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData,
        optedInAccountAddress: String,
        isAmountVisible: Boolean,
        nftListingViewType: NFTListingViewType,
        isOptedIn: Boolean,
        isOwnedByWatchAccount: Boolean
    ): BaseCollectibleListItem.BaseCollectibleItem.BaseOwnedNFTItem.SimpleNFTItem {
        return BaseCollectibleListItem.BaseCollectibleItem.BaseOwnedNFTItem.SimpleNFTItem(
            collectibleId = collectible.id,
            collectibleName = AssetName.create(collectible.collectibleName),
            collectionName = collectible.collectionName,
            optedInAccountAddress = optedInAccountAddress,
            optedInAtRound = collectible.optedInAtRound,
            formattedCollectibleAmount = nftAmountFormatDecider.decideNFTAmountFormat(
                nftAmount = collectible.amount,
                fractionalDecimal = collectible.decimals,
                formattedAmount = collectible.formattedAmount,
                formattedCompactAmount = collectible.formattedCompactAmount
            ),
            isAmountVisible = isAmountVisible,
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(collectible.id),
            itemType = baseCollectibleListItemItemTypeDecider.decideSimpleNFTViewType(nftListingViewType),
            nftIndicatorDrawable = nftIndicatorDrawableDecider.decideNFTIndicatorDrawable(
                isOwned = isOptedIn,
                isHoldingByWatchAccount = isOwnedByWatchAccount,
                nftListingViewType = nftListingViewType
            ),
            shouldDecreaseOpacity = !isOptedIn,
        )
    }

    fun mapToSimplePendingNFTItem(
        collectible: BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData,
        optedInAccountAddress: String,
        nftListingViewType: NFTListingViewType
    ): BaseCollectibleListItem.BaseCollectibleItem.BasePendingNFTItem.SimplePendingNFTItem {
        return BaseCollectibleListItem.BaseCollectibleItem.BasePendingNFTItem.SimplePendingNFTItem(
            collectibleId = collectible.id,
            collectibleName = AssetName.create(collectible.collectibleName),
            collectionName = collectible.collectionName,
            optedInAccountAddress = optedInAccountAddress,
            optedInAtRound = null,
            baseAssetDrawableProvider = assetDrawableProviderDecider.getAssetDrawableProvider(collectible.id),
            itemType = baseCollectibleListItemItemTypeDecider.decideSimplePendingNFTViewType(nftListingViewType)
        )
    }

    fun mapToBaseCollectibleListData(
        collectibleList: List<BaseCollectibleListItem>,
        displayedCollectibleCount: Int,
        filteredOutCollectibleCount: Int
    ): BaseCollectibleListData {
        return BaseCollectibleListData(
            baseCollectibleItemList = collectibleList,
            displayedCollectibleCount = displayedCollectibleCount,
            filteredOutCollectibleCount = filteredOutCollectibleCount
        )
    }

    fun mapToTitleTextItem(): BaseCollectibleListItem.TitleTextViewItem {
        return BaseCollectibleListItem.TitleTextViewItem
    }

    fun mapToSearchViewItem(
        @StringRes searchViewHintResId: Int,
        query: String,
        onGridListViewSelectedEvent: Event<Unit>? = null,
        onLinearListViewSelectedEvent: Event<Unit>? = null
    ): BaseCollectibleListItem.SearchViewItem {
        return BaseCollectibleListItem.SearchViewItem(
            searchViewHintResId = searchViewHintResId,
            query = query,
            onGridListViewSelectedEvent = onGridListViewSelectedEvent,
            onLinearListViewSelectedEvent = onLinearListViewSelectedEvent
        )
    }

    fun mapToInfoViewItem(
        displayedCollectibleCount: Int,
        isAddButtonVisible: Boolean
    ): BaseCollectibleListItem.InfoViewItem {
        return BaseCollectibleListItem.InfoViewItem(
            displayedCollectibleCount = displayedCollectibleCount,
            isAddButtonVisible = isAddButtonVisible
        )
    }
}
