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

import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.nft.domain.decider.CollectibleBadgeDecider
import com.algorand.android.nft.ui.model.BaseCollectibleListData
import com.algorand.android.nft.ui.model.BaseCollectibleListItem
import com.algorand.android.nft.ui.model.CollectiblesListingPreview
import javax.inject.Inject

class CollectibleListingItemMapper @Inject constructor(
    private val collectibleBadgeDecider: CollectibleBadgeDecider
) {

    fun mapToNotSupportedItem(
        collectible: BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedUnsupportedCollectibleData,
        isOwnedByTheUser: Boolean,
        optedInAccountAddress: String
    ): BaseCollectibleListItem.BaseCollectibleItem.NotSupportedCollectibleItem {
        return BaseCollectibleListItem.BaseCollectibleItem.NotSupportedCollectibleItem(
            collectibleId = collectible.id,
            collectibleName = collectible.collectibleName,
            collectionName = collectible.collectionName,
            avatarDisplayText = collectible.avatarDisplayText,
            isOwnedByTheUser = isOwnedByTheUser,
            badgeImageResId = collectibleBadgeDecider.decideCollectibleBadgeResId(collectible),
            optedInAccountAddress = optedInAccountAddress
        )
    }

    fun mapToImageItem(
        collectible: BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleImageData,
        isOwnedByTheUser: Boolean,
        optedInAccountAddress: String
    ): BaseCollectibleListItem.BaseCollectibleItem.CollectibleImageItem {
        return BaseCollectibleListItem.BaseCollectibleItem.CollectibleImageItem(
            collectibleId = collectible.id,
            collectibleName = collectible.collectibleName,
            collectionName = collectible.collectionName,
            isOwnedByTheUser = isOwnedByTheUser,
            avatarDisplayText = collectible.avatarDisplayText,
            badgeImageResId = collectibleBadgeDecider.decideCollectibleBadgeResId(collectible),
            prismUrl = collectible.prismUrl,
            optedInAccountAddress = optedInAccountAddress
        )
    }

    fun mapToVideoItem(
        collectible: BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleVideoData,
        isOwnedByTheUser: Boolean,
        optedInAccountAddress: String
    ): BaseCollectibleListItem.BaseCollectibleItem.CollectibleVideoItem {
        return BaseCollectibleListItem.BaseCollectibleItem.CollectibleVideoItem(
            collectibleId = collectible.id,
            collectibleName = collectible.collectibleName,
            collectionName = collectible.collectionName,
            isOwnedByTheUser = isOwnedByTheUser,
            avatarDisplayText = collectible.avatarDisplayText,
            badgeImageResId = collectibleBadgeDecider.decideCollectibleBadgeResId(collectible),
            thumbnailPrismUrl = collectible.thumbnailPrismUrl,
            optedInAccountAddress = optedInAccountAddress
        )
    }

    fun mapToMixedItem(
        collectible: BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleMixedData,
        isOwnedByTheUser: Boolean,
        optedInAccountAddress: String
    ): BaseCollectibleListItem.BaseCollectibleItem.CollectibleMixedItem {
        return BaseCollectibleListItem.BaseCollectibleItem.CollectibleMixedItem(
            collectibleId = collectible.id,
            collectibleName = collectible.collectibleName,
            collectionName = collectible.collectionName,
            isOwnedByTheUser = isOwnedByTheUser,
            avatarDisplayText = collectible.avatarDisplayText,
            badgeImageResId = collectibleBadgeDecider.decideCollectibleBadgeResId(collectible),
            thumbnailPrismUrl = collectible.thumbnailPrismUrl,
            optedInAccountAddress = optedInAccountAddress
        )
    }

    fun mapToPreviewItem(
        isLoadingVisible: Boolean,
        isEmptyStateVisible: Boolean,
        isErrorVisible: Boolean,
        isReceiveButtonVisible: Boolean,
        isFilterActive: Boolean,
        displayedCollectibleCount: Int,
        filteredCollectibleCount: Int,
        isClearFilterButtonVisible: Boolean,
        itemList: List<BaseCollectibleListItem>,
        isAccountFabVisible: Boolean
    ): CollectiblesListingPreview {
        return CollectiblesListingPreview(
            isLoadingVisible = isLoadingVisible,
            isEmptyStateVisible = isEmptyStateVisible,
            isErrorVisible = isErrorVisible,
            isReceiveButtonVisible = isReceiveButtonVisible,
            baseCollectibleListItems = itemList,
            isFilterActive = isFilterActive,
            isClearFilterButtonVisible = isClearFilterButtonVisible,
            displayedCollectibleCount = displayedCollectibleCount,
            filteredCollectibleCount = filteredCollectibleCount,
            isAccountFabVisible = isAccountFabVisible
        )
    }

    fun mapToPendingRemovalItem(
        collectible: BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingDeletionCollectibleData,
        optedInAccountAddress: String
    ): BaseCollectibleListItem.BaseCollectibleItem.BasePendingCollectibleItem.PendingRemovalItem {
        return BaseCollectibleListItem.BaseCollectibleItem.BasePendingCollectibleItem.PendingRemovalItem(
            collectibleId = collectible.id,
            collectibleName = collectible.collectibleName,
            collectionName = collectible.collectionName,
            isOwnedByTheUser = false,
            avatarDisplayText = collectible.avatarDisplayText,
            primaryImageUrl = collectible.primaryImageUrl,
            badgeImageResId = collectibleBadgeDecider.decidePendingCollectibleBadgeResId(collectible),
            optedInAccountAddress = optedInAccountAddress
        )
    }

    fun mapToPendingAdditionItem(
        collectible: BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingAdditionCollectibleData,
        optedInAccountAddress: String
    ): BaseCollectibleListItem.BaseCollectibleItem.BasePendingCollectibleItem.PendingAdditionItem {
        return BaseCollectibleListItem.BaseCollectibleItem.BasePendingCollectibleItem.PendingAdditionItem(
            collectibleId = collectible.id,
            collectibleName = collectible.collectibleName,
            collectionName = collectible.collectionName,
            isOwnedByTheUser = false,
            avatarDisplayText = collectible.avatarDisplayText,
            primaryImageUrl = collectible.primaryImageUrl,
            badgeImageResId = collectibleBadgeDecider.decidePendingCollectibleBadgeResId(collectible),
            optedInAccountAddress = optedInAccountAddress
        )
    }

    fun mapToPendingSendingItem(
        collectible: BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingSendingCollectibleData,
        optedInAccountAddress: String
    ): BaseCollectibleListItem.BaseCollectibleItem.BasePendingCollectibleItem.PendingSendingItem {
        return BaseCollectibleListItem.BaseCollectibleItem.BasePendingCollectibleItem.PendingSendingItem(
            collectibleId = collectible.id,
            collectibleName = collectible.collectibleName,
            collectionName = collectible.collectionName,
            isOwnedByTheUser = false,
            avatarDisplayText = collectible.avatarDisplayText,
            primaryImageUrl = collectible.primaryImageUrl,
            badgeImageResId = collectibleBadgeDecider.decidePendingCollectibleBadgeResId(collectible),
            optedInAccountAddress = optedInAccountAddress
        )
    }

    fun mapToBaseCollectibleListData(
        collectibleList: List<BaseCollectibleListItem>,
        isFilterActive: Boolean,
        displayedCollectibleCount: Int,
        filteredOutCollectibleCount: Int
    ): BaseCollectibleListData {
        return BaseCollectibleListData(
            baseCollectibleItemList = collectibleList,
            isFilterActive = isFilterActive,
            displayedCollectibleCount = displayedCollectibleCount,
            filteredOutCollectibleCount = filteredOutCollectibleCount
        )
    }
}
