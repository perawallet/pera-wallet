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

import com.algorand.android.models.Account
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.modules.accountstatehelper.domain.usecase.AccountStateHelperUseCase
import com.algorand.android.modules.collectibles.filter.domain.usecase.ClearCollectibleFiltersPreferencesUseCase
import com.algorand.android.modules.collectibles.filter.domain.usecase.ShouldDisplayOptedInNFTPreferenceUseCase
import com.algorand.android.modules.collectibles.listingviewtype.domain.model.NFTListingViewType
import com.algorand.android.modules.collectibles.listingviewtype.domain.usecase.AddOnListingViewTypeChangeListenerUseCase
import com.algorand.android.modules.collectibles.listingviewtype.domain.usecase.GetNFTListingViewTypePreferenceUseCase
import com.algorand.android.modules.collectibles.listingviewtype.domain.usecase.RemoveOnListingViewTypeChangeListenerUseCase
import com.algorand.android.modules.collectibles.listingviewtype.domain.usecase.SaveNFTListingViewTypePreferenceUseCase
import com.algorand.android.modules.sorting.nftsorting.ui.usecase.CollectibleItemSortUseCase
import com.algorand.android.nft.mapper.CollectibleListingItemMapper
import com.algorand.android.nft.ui.model.BaseCollectibleListData
import com.algorand.android.nft.ui.model.BaseCollectibleListItem
import com.algorand.android.nft.ui.model.CollectiblesListingPreview
import com.algorand.android.nft.utils.CollectibleUtils
import com.algorand.android.repository.FailedAssetRepository
import com.algorand.android.usecase.AccountCollectibleDataUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.CacheResult
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine

@SuppressWarnings("LongParameterList")
class AccountCollectiblesListingPreviewUseCase @Inject constructor(
    private val collectibleListingItemMapper: CollectibleListingItemMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val failedAssetRepository: FailedAssetRepository,
    private val accountCollectibleDataUseCase: AccountCollectibleDataUseCase,
    private val collectibleItemSortUseCase: CollectibleItemSortUseCase,
    private val getNFTListingViewTypePreferenceUseCase: GetNFTListingViewTypePreferenceUseCase,
    private val accountStateHelperUseCase: AccountStateHelperUseCase,
    clearCollectibleFiltersPreferencesUseCase: ClearCollectibleFiltersPreferencesUseCase,
    shouldDisplayOptedInNFTPreferenceUseCase: ShouldDisplayOptedInNFTPreferenceUseCase,
    collectibleUtils: CollectibleUtils,
    addOnListingViewTypeChangeListenerUseCase: AddOnListingViewTypeChangeListenerUseCase,
    removeOnListingViewTypeChangeListenerUseCase: RemoveOnListingViewTypeChangeListenerUseCase,
    saveNFTListingViewTypePreferenceUseCase: SaveNFTListingViewTypePreferenceUseCase
) : BaseCollectiblesListingPreviewUseCase(
    collectibleListingItemMapper,
    saveNFTListingViewTypePreferenceUseCase,
    addOnListingViewTypeChangeListenerUseCase,
    removeOnListingViewTypeChangeListenerUseCase,
    shouldDisplayOptedInNFTPreferenceUseCase,
    collectibleUtils,
    clearCollectibleFiltersPreferencesUseCase
) {

    fun getCollectiblesListingPreviewFlow(searchKeyword: String, publicKey: String): Flow<CollectiblesListingPreview> {
        return combine(
            accountDetailUseCase.getAccountDetailCacheFlow(publicKey),
            failedAssetRepository.getFailedAssetCacheFlow(),
            accountCollectibleDataUseCase.getAccountAllCollectibleDataFlow(publicKey)
        ) { accountDetail, failedAssets, accountCollectibleData ->
            val hasAccountAuthority = hasAccountAuthority(accountDetail)
            val nftListingType = getNFTListingViewTypePreferenceUseCase()
            val collectibleListData = prepareCollectiblesListItems(
                searchKeyword = searchKeyword,
                cachedAccountDetail = accountDetail,
                accountCollectibleData = accountCollectibleData,
                nftListingType = nftListingType
            )
            val isAllCollectiblesFilteredOut = isAllCollectiblesFilteredOut(collectibleListData, searchKeyword)
            val isEmptyStateVisible = accountCollectibleData.isEmpty() || isAllCollectiblesFilteredOut
            val itemList = mutableListOf<BaseCollectibleListItem>().apply {
                if (!isEmptyStateVisible) {
                    add(createSearchViewItem(query = searchKeyword, nftListingType = nftListingType))
                    add(
                        ACCOUNT_COLLECTIBLES_LIST_CONFIGURATION_HEADER_ITEM_INDEX,
                        createInfoViewItem(
                            displayedCollectibleCount = collectibleListData.displayedCollectibleCount,
                            isAddButtonVisible = hasAccountAuthority
                        )
                    )
                }
                addAll(collectibleListData.baseCollectibleItemList)
            }
            collectibleListingItemMapper.mapToPreviewItem(
                isLoadingVisible = false,
                isEmptyStateVisible = isEmptyStateVisible,
                isErrorVisible = failedAssets.isNotEmpty(),
                itemList = itemList,
                isReceiveButtonVisible = isEmptyStateVisible && hasAccountAuthority,
                filteredCollectibleCount = collectibleListData.filteredOutCollectibleCount,
                isClearFilterButtonVisible = isAllCollectiblesFilteredOut,
                isAccountFabVisible = hasAccountAuthority,
                isAddCollectibleFloatingActionButtonVisible = hasAccountAuthority
            )
        }
    }

    private suspend fun prepareCollectiblesListItems(
        searchKeyword: String,
        cachedAccountDetail: CacheResult<AccountDetail>?,
        accountCollectibleData: List<BaseAccountAssetData>,
        nftListingType: NFTListingViewType
    ): BaseCollectibleListData {
        val accountDetail = cachedAccountDetail?.data
        var displayedCollectibleCount = 0
        var filteredOutCollectibleCount = 0
        val collectibleList = mutableListOf<BaseCollectibleListItem>().apply {
            accountCollectibleData.filter { nftData ->
                filterOptedInNFTIfNeed(accountDetail, nftData).also { isNotFiltered ->
                    if (!isNotFiltered) filteredOutCollectibleCount++
                }
            }.forEach { collectibleData ->
                filteredOutCollectibleCount++
                if (filterNFTBaseOnSearch(searchKeyword, collectibleData)) return@forEach
                val collectibleListItem = createCollectibleListItem(
                    accountAssetData = collectibleData,
                    optedInAccountAddress = accountDetail?.account?.address.orEmpty(),
                    nftListingType = nftListingType,
                    isOwnedByWatchAccount = accountDetail?.account?.type == Account.Type.WATCH
                ) ?: return@forEach
                add(collectibleListItem)
                displayedCollectibleCount++
            }
        }
        val sortedCollectibleItemList = collectibleItemSortUseCase.sortCollectibles(collectibleList)
        return collectibleListingItemMapper.mapToBaseCollectibleListData(
            sortedCollectibleItemList,
            displayedCollectibleCount,
            filteredOutCollectibleCount
        )
    }

    private fun hasAccountAuthority(accountDetail: CacheResult<AccountDetail>?): Boolean {
        val accountAddress = accountDetail?.data?.account?.address ?: return false
        return accountStateHelperUseCase.hasAccountAuthority(accountAddress)
    }

    companion object {
        const val ACCOUNT_COLLECTIBLES_LIST_CONFIGURATION_HEADER_ITEM_INDEX = 0
    }
}
