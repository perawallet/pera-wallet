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
import com.algorand.android.modules.collectibles.filter.domain.usecase.ShouldDisplayWatchAccountNFTsPreferenceUseCase
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
import com.algorand.android.usecase.AssetCacheManagerUseCase
import com.algorand.android.utils.CacheResult
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine

@SuppressWarnings("LongParameterList")
class CollectiblesListingPreviewUseCase @Inject constructor(
    private val collectibleListingItemMapper: CollectibleListingItemMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val failedAssetRepository: FailedAssetRepository,
    private val assetCacheManagerUseCase: AssetCacheManagerUseCase,
    private val accountCollectibleDataUseCase: AccountCollectibleDataUseCase,
    private val collectibleItemSortUseCase: CollectibleItemSortUseCase,
    private val shouldDisplayWatchAccountNFTsPreferenceUseCase: ShouldDisplayWatchAccountNFTsPreferenceUseCase,
    private val getNFTListingViewTypePreferenceUseCase: GetNFTListingViewTypePreferenceUseCase,
    private val accountStateHelperUseCase: AccountStateHelperUseCase,
    clearCollectibleFiltersPreferencesUseCase: ClearCollectibleFiltersPreferencesUseCase,
    collectibleUtils: CollectibleUtils,
    shouldDisplayOptedInNFTPreferenceUseCase: ShouldDisplayOptedInNFTPreferenceUseCase,
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

    @SuppressWarnings("LongMethod")
    fun getCollectiblesListingPreviewFlow(searchKeyword: String): Flow<CollectiblesListingPreview> {
        return combine(
            accountDetailUseCase.getAccountDetailCacheFlow(),
            failedAssetRepository.getFailedAssetCacheFlow(),
            accountCollectibleDataUseCase.getAllAccountsAllCollectibleDataFlow()
        ) { accountDetailList, failedAssets, accountsAllCollectibles ->
            val hasAnyAccountAuthority = hasAnyAccountAuthority(accountDetailList.values)
            if (assetCacheManagerUseCase.isCacheStatusAtLeastEmpty()) {
                val nftListingType = getNFTListingViewTypePreferenceUseCase()
                val collectibleListData = prepareCollectiblesListItems(
                    searchKeyword = searchKeyword,
                    allAccountAllCollectibles = accountsAllCollectibles,
                    nftListingType = nftListingType
                )
                val isAllCollectiblesFilteredOut = isAllCollectiblesFilteredOut(collectibleListData, searchKeyword)
                val isEmptyStateVisible = accountsAllCollectibles.all { (_, accountNFTs) ->
                    accountNFTs.isEmpty()
                } || isAllCollectiblesFilteredOut
                val itemList = mutableListOf<BaseCollectibleListItem>().apply {
                    if (!isEmptyStateVisible) {
                        add(createTitleTextViewItem())
                        add(createSearchViewItem(query = searchKeyword, nftListingType = nftListingType))
                        add(
                            index = COLLECTIBLES_LIST_CONFIGURATION_HEADER_ITEM_INDEX,
                            element = createInfoViewItem(
                                displayedCollectibleCount = collectibleListData.displayedCollectibleCount,
                                isAddButtonVisible = hasAnyAccountAuthority
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
                    isReceiveButtonVisible = isEmptyStateVisible,
                    filteredCollectibleCount = collectibleListData.filteredOutCollectibleCount,
                    isClearFilterButtonVisible = isAllCollectiblesFilteredOut,
                    isAccountFabVisible = false,
                    isAddCollectibleFloatingActionButtonVisible = hasAnyAccountAuthority
                )
            } else {
                createLoadingPreview(hasAnyAccountAuthority, searchKeyword)
            }
        }
    }

    private suspend fun prepareCollectiblesListItems(
        searchKeyword: String,
        allAccountAllCollectibles: List<Pair<AccountDetail, List<BaseAccountAssetData>>>,
        nftListingType: NFTListingViewType
    ): BaseCollectibleListData {
        var displayedCollectibleCount = 0
        var totalCollectibleCount = 0
        val baseCollectibleItemList = mutableListOf<BaseCollectibleListItem>().apply {
            allAccountAllCollectibles.filter { (accountDetail, nftsData) ->
                filterWatchAccountsNFTsIfNeed(accountDetail).also { isNotFiltered ->
                    if (!isNotFiltered) totalCollectibleCount += nftsData.count()
                }
            }.forEach { (accountDetail, nftsData) ->
                val isOwnedByWatchAccount = accountDetail.account.type == Account.Type.WATCH
                nftsData.filter { nftData ->
                    filterOptedInNFTIfNeed(accountDetail, nftData).also { isNotFiltered ->
                        if (!isNotFiltered) totalCollectibleCount++
                    }
                }.forEach { collectibleData ->
                    totalCollectibleCount++
                    if (filterNFTBaseOnSearch(searchKeyword, collectibleData)) return@forEach
                    val collectibleItem = createCollectibleListItem(
                        accountAssetData = collectibleData,
                        optedInAccountAddress = accountDetail.account.address,
                        nftListingType = nftListingType,
                        isOwnedByWatchAccount = isOwnedByWatchAccount
                    ) ?: return@forEach
                    add(collectibleItem)
                    displayedCollectibleCount++
                }
            }
        }
        val sortedBaseCollectibleItemList = collectibleItemSortUseCase.sortCollectibles(baseCollectibleItemList)
        return collectibleListingItemMapper.mapToBaseCollectibleListData(
            collectibleList = sortedBaseCollectibleItemList,
            displayedCollectibleCount = displayedCollectibleCount,
            filteredOutCollectibleCount = totalCollectibleCount
        )
    }

    private fun hasAnyAccountAuthority(accountList: Collection<CacheResult<AccountDetail>?>): Boolean {
        return accountList.any {
            val publicKey = it?.data?.account?.address ?: return false
            accountStateHelperUseCase.hasAccountAuthority(publicKey)
        }
    }

    private fun createLoadingPreview(
        canUserSignTransaction: Boolean,
        searchKeyword: String
    ): CollectiblesListingPreview {
        return collectibleListingItemMapper.mapToPreviewItem(
            isLoadingVisible = true,
            isEmptyStateVisible = false,
            isErrorVisible = false,
            isReceiveButtonVisible = false,
            itemList = listOf(
                createTitleTextViewItem(),
                createInfoViewItem(
                    displayedCollectibleCount = 0,
                    isAddButtonVisible = canUserSignTransaction
                ),
                createSearchViewItem(query = searchKeyword, nftListingType = null)
            ),
            filteredCollectibleCount = 0,
            isClearFilterButtonVisible = false,
            isAccountFabVisible = false,
            isAddCollectibleFloatingActionButtonVisible = false
        )
    }

    private suspend fun filterWatchAccountsNFTsIfNeed(accountDetail: AccountDetail): Boolean {
        return shouldDisplayWatchAccountNFTsPreferenceUseCase() || accountDetail.account.type != Account.Type.WATCH
    }

    companion object {
        const val COLLECTIBLES_LIST_CONFIGURATION_HEADER_ITEM_INDEX = 1
    }
}
