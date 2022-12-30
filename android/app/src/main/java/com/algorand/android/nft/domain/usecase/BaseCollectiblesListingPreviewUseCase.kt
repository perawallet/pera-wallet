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

import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData
import com.algorand.android.modules.collectibles.filter.domain.usecase.ClearCollectibleFiltersPreferencesUseCase
import com.algorand.android.modules.collectibles.filter.domain.usecase.ShouldDisplayOptedInNFTPreferenceUseCase
import com.algorand.android.modules.collectibles.listingviewtype.domain.model.NFTListingViewType
import com.algorand.android.modules.collectibles.listingviewtype.domain.model.NFTListingViewType.GRID
import com.algorand.android.modules.collectibles.listingviewtype.domain.model.NFTListingViewType.LINEAR_VERTICAL
import com.algorand.android.modules.collectibles.listingviewtype.domain.usecase.AddOnListingViewTypeChangeListenerUseCase
import com.algorand.android.modules.collectibles.listingviewtype.domain.usecase.RemoveOnListingViewTypeChangeListenerUseCase
import com.algorand.android.modules.collectibles.listingviewtype.domain.usecase.SaveNFTListingViewTypePreferenceUseCase
import com.algorand.android.nft.mapper.CollectibleListingItemMapper
import com.algorand.android.nft.ui.model.BaseCollectibleListData
import com.algorand.android.nft.ui.model.BaseCollectibleListItem
import com.algorand.android.nft.utils.CollectibleUtils
import com.algorand.android.sharedpref.SharedPrefLocalSource
import com.algorand.android.utils.Event
import java.math.BigInteger

open class BaseCollectiblesListingPreviewUseCase(
    private val collectibleListingItemMapper: CollectibleListingItemMapper,
    private val saveNFTListingViewTypePreferenceUseCase: SaveNFTListingViewTypePreferenceUseCase,
    private val addOnListingViewTypeChangeListenerUseCase: AddOnListingViewTypeChangeListenerUseCase,
    private val removeOnListingViewTypeChangeListenerUseCase: RemoveOnListingViewTypeChangeListenerUseCase,
    private val shouldDisplayOptedInNFTPreferenceUseCase: ShouldDisplayOptedInNFTPreferenceUseCase,
    private val collectibleUtils: CollectibleUtils,
    private val clearCollectibleFiltersPreferencesUseCase: ClearCollectibleFiltersPreferencesUseCase
) {

    fun addOnListingViewTypeChangeListener(listener: SharedPrefLocalSource.OnChangeListener<Int>) {
        addOnListingViewTypeChangeListenerUseCase.invoke(listener)
    }

    fun removeOnListingViewTypeChangeListener(listener: SharedPrefLocalSource.OnChangeListener<Int>) {
        removeOnListingViewTypeChangeListenerUseCase.invoke(listener)
    }

    suspend fun clearCollectibleFilters() {
        clearCollectibleFiltersPreferencesUseCase.invoke()
    }

    suspend fun saveNFTListingViewTypePreference(nftListingViewType: NFTListingViewType) {
        saveNFTListingViewTypePreferenceUseCase.invoke(nftListingViewType)
    }

    protected fun createCollectibleListItem(
        accountAssetData: BaseAccountAssetData,
        optedInAccountAddress: String,
        nftListingType: NFTListingViewType,
        isOwnedByWatchAccount: Boolean
    ): BaseCollectibleListItem.BaseCollectibleItem? {
        return when (accountAssetData) {
            is BaseOwnedCollectibleData -> {
                createOwnedCollectibleListItem(
                    accountAssetData = accountAssetData,
                    optedInAccountAddress = optedInAccountAddress,
                    nftListingType = nftListingType,
                    isOwnedByWatchAccount = isOwnedByWatchAccount
                )
            }
            is BasePendingCollectibleData -> {
                createPendingCollectibleListItem(
                    pendingCollectibleData = accountAssetData,
                    optedInAccountAddress = optedInAccountAddress,
                    nftListingType = nftListingType
                )
            }
            else -> null
        }
    }

    protected fun isAllCollectiblesFilteredOut(
        collectibleListData: BaseCollectibleListData,
        searchKeyword: String
    ): Boolean {
        return with(collectibleListData) {
            displayedCollectibleCount == 0 && filteredOutCollectibleCount > 0 && searchKeyword.isBlank()
        }
    }

    protected fun filterNFTBaseOnSearch(searchKeyword: String, collectibleData: BaseAccountAssetData): Boolean {
        return with(collectibleData) {
            name?.contains(searchKeyword, ignoreCase = true) != true &&
                shortName?.contains(searchKeyword, ignoreCase = true) != true &&
                !id.toString().contains(searchKeyword, ignoreCase = true)
        }
    }

    protected suspend fun filterOptedInNFTIfNeed(
        accountDetail: AccountDetail?,
        nftData: BaseAccountAssetData
    ): Boolean {
        return shouldDisplayOptedInNFTPreferenceUseCase() ||
            collectibleUtils.isCollectibleOwnedByTheUser(accountDetail, nftData.id)
    }

    private fun createOwnedCollectibleListItem(
        accountAssetData: BaseOwnedCollectibleData,
        optedInAccountAddress: String,
        nftListingType: NFTListingViewType,
        isOwnedByWatchAccount: Boolean
    ): BaseCollectibleListItem.BaseCollectibleItem {
        with(collectibleListingItemMapper) {
            with(accountAssetData) {
                val isAmountVisible = accountAssetData.amount > BigInteger.ONE
                return mapToSimpleNFTItem(
                    collectible = this,
                    optedInAccountAddress = optedInAccountAddress,
                    isAmountVisible = isAmountVisible,
                    nftListingViewType = nftListingType,
                    isOptedIn = accountAssetData.isOwnedByTheUser,
                    isOwnedByWatchAccount = isOwnedByWatchAccount
                )
            }
        }
    }

    private fun createPendingCollectibleListItem(
        pendingCollectibleData: BasePendingCollectibleData,
        optedInAccountAddress: String,
        nftListingType: NFTListingViewType,
    ): BaseCollectibleListItem.BaseCollectibleItem.BasePendingNFTItem {
        with(pendingCollectibleData) {
            return collectibleListingItemMapper.mapToSimplePendingNFTItem(
                collectible = this,
                optedInAccountAddress = optedInAccountAddress,
                nftListingViewType = nftListingType
            )
        }
    }

    protected fun createTitleTextViewItem(): BaseCollectibleListItem.TitleTextViewItem {
        return collectibleListingItemMapper.mapToTitleTextItem()
    }

    protected fun createSearchViewItem(
        @StringRes searchViewHintResId: Int = R.string.search_nfts,
        query: String,
        nftListingType: NFTListingViewType?
    ): BaseCollectibleListItem.SearchViewItem {
        return collectibleListingItemMapper.mapToSearchViewItem(
            searchViewHintResId = searchViewHintResId,
            query = query,
            onLinearListViewSelectedEvent = if (nftListingType == LINEAR_VERTICAL) Event(Unit) else null,
            onGridListViewSelectedEvent = if (nftListingType == GRID) Event(Unit) else null
        )
    }

    protected fun createInfoViewItem(
        displayedCollectibleCount: Int,
        isAddButtonVisible: Boolean
    ): BaseCollectibleListItem.InfoViewItem {
        return collectibleListingItemMapper.mapToInfoViewItem(
            displayedCollectibleCount = displayedCollectibleCount,
            isAddButtonVisible = isAddButtonVisible
        )
    }
}
