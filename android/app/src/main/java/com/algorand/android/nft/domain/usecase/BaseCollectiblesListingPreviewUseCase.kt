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

package com.algorand.android.nft.domain.usecase

import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingAdditionCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingDeletionCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingSendingCollectibleData
import com.algorand.android.nft.mapper.CollectibleListingItemMapper
import com.algorand.android.nft.ui.model.BaseCollectibleListItem

open class BaseCollectiblesListingPreviewUseCase(
    private val collectibleListingItemMapper: CollectibleListingItemMapper
) {

    private fun createOwnedCollectibleListItem(
        accountAssetData: BaseOwnedCollectibleData,
        isOwnedByTheUser: Boolean,
        optedInAccountAddress: String
    ): BaseCollectibleListItem.BaseCollectibleItem {
        with(collectibleListingItemMapper) {
            with(accountAssetData) {
                val errorDisplayText = collectibleName ?: name ?: shortName ?: id.toString()
                return when (this) {
                    is BaseOwnedCollectibleData.OwnedCollectibleImageData -> {
                        mapToImageItem(this, isOwnedByTheUser, errorDisplayText, optedInAccountAddress)
                    }
                    is BaseOwnedCollectibleData.OwnedCollectibleVideoData -> {
                        mapToVideoItem(this, isOwnedByTheUser, errorDisplayText, optedInAccountAddress)
                    }
                    is BaseOwnedCollectibleData.OwnedUnsupportedCollectibleData -> {
                        mapToNotSupportedItem(this, isOwnedByTheUser, errorDisplayText, optedInAccountAddress)
                    }
                    is BaseOwnedCollectibleData.OwnedCollectibleMixedData -> {
                        mapToMixedItem(this, isOwnedByTheUser, errorDisplayText, optedInAccountAddress)
                    }
                }
            }
        }
    }

    private fun createPendingAdditionCollectibleListItem(
        pendingCollectibleData: PendingAdditionCollectibleData,
        optedInAccountAddress: String
    ): BaseCollectibleListItem.BaseCollectibleItem.BasePendingCollectibleItem {
        with(pendingCollectibleData) {
            val errorDisplayText = collectibleName ?: name ?: shortName ?: id.toString()
            return collectibleListingItemMapper.mapToPendingAdditionItem(this, errorDisplayText, optedInAccountAddress)
        }
    }

    private fun createPendingDeletionCollectibleListItem(
        pendingCollectibleData: PendingDeletionCollectibleData,
        optedInAccountAddress: String
    ): BaseCollectibleListItem.BaseCollectibleItem.BasePendingCollectibleItem {
        with(pendingCollectibleData) {
            val errorDisplayText = collectibleName ?: name ?: shortName ?: id.toString()
            return collectibleListingItemMapper.mapToPendingRemovalItem(this, errorDisplayText, optedInAccountAddress)
        }
    }

    private fun createPendingSentCollectibleListItem(
        pendingCollectibleData: PendingSendingCollectibleData,
        optedInAccountAddress: String
    ): BaseCollectibleListItem.BaseCollectibleItem.BasePendingCollectibleItem {
        with(pendingCollectibleData) {
            val errorDisplayText = collectibleName ?: name ?: shortName ?: id.toString()
            return collectibleListingItemMapper.mapToPendingSendingItem(this, errorDisplayText, optedInAccountAddress)
        }
    }

    protected fun createCollectibleListItem(
        accountAssetData: BaseAccountAssetData,
        isOwnedByTheUser: Boolean,
        optedInAccountAddress: String
    ): BaseCollectibleListItem.BaseCollectibleItem? {
        return when (accountAssetData) {
            is BaseOwnedCollectibleData -> {
                createOwnedCollectibleListItem(accountAssetData, isOwnedByTheUser, optedInAccountAddress)
            }
            is PendingDeletionCollectibleData -> {
                createPendingDeletionCollectibleListItem(accountAssetData, optedInAccountAddress)
            }
            is PendingAdditionCollectibleData -> {
                createPendingAdditionCollectibleListItem(accountAssetData, optedInAccountAddress)
            }
            is PendingSendingCollectibleData -> {
                createPendingSentCollectibleListItem(accountAssetData, optedInAccountAddress)
            }
            else -> null
        }
    }
}
