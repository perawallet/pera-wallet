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

import com.algorand.android.models.AccountDetail
import com.algorand.android.models.BaseAccountAssetData
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
import com.algorand.android.utils.coremanager.AssetCacheManager
import com.algorand.android.utils.coremanager.AssetCacheManager.AssetCacheStatus.EMPTY
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine

class CollectiblesListingPreviewUseCase @Inject constructor(
    private val collectibleListingItemMapper: CollectibleListingItemMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val failedAssetRepository: FailedAssetRepository,
    private val assetCacheManager: AssetCacheManager,
    private val collectibleUtils: CollectibleUtils,
    private val accountCollectibleDataUseCase: AccountCollectibleDataUseCase,
    private val collectibleFilterUseCase: CollectibleFilterUseCase,
    private val collectibleItemSortUseCase: CollectibleItemSortUseCase
) : BaseCollectiblesListingPreviewUseCase(collectibleListingItemMapper, collectibleFilterUseCase) {

    @SuppressWarnings("LongMethod")
    fun getCollectiblesListingPreviewFlow(searchKeyword: String): Flow<CollectiblesListingPreview> {
        return combine(
            accountDetailUseCase.getAccountDetailCacheFlow(),
            failedAssetRepository.getFailedAssetCacheFlow(),
            accountCollectibleDataUseCase.getAllAccountsAllCollectibleDataFlow()
        ) { accountDetailList, failedAssets, accountsAllCollectibles ->
            val canUserSignTransaction = canAnyAccountSignTransaction(accountDetailList.values)
            if (assetCacheManager.cacheStatus isAtLeast EMPTY) {
                val collectibleListData = prepareCollectiblesListItems(
                    searchKeyword,
                    canUserSignTransaction,
                    accountsAllCollectibles
                )
                val isAllCollectiblesFilteredOut = isAllCollectiblesFilteredOut(collectibleListData)
                val isEmptyStateVisible =
                    accountsAllCollectibles.all { it.second.isEmpty() } || isAllCollectiblesFilteredOut
                val itemList = mutableListOf(
                    createTitleTextViewItem(isVisible = !isEmptyStateVisible),
                    createSearchViewItem(isVisible = !isEmptyStateVisible),
                ).apply { addAll(collectibleListData.baseCollectibleItemList) }
                val infoViewItem = createInfoViewItem(
                    displayedCollectibleCount = collectibleListData.displayedCollectibleCount,
                    isVisible = !isEmptyStateVisible,
                    isFilterActive = collectibleListData.isFilterActive,
                    isAddButtonVisible = canUserSignTransaction
                )
                itemList.add(COLLECTIBLES_LIST_CONFIGURATION_HEADER_ITEM_INDEX, infoViewItem)
                collectibleListingItemMapper.mapToPreviewItem(
                    isLoadingVisible = false,
                    isEmptyStateVisible = isEmptyStateVisible,
                    isErrorVisible = failedAssets.isNotEmpty(),
                    itemList = itemList,
                    isReceiveButtonVisible = isEmptyStateVisible,
                    filteredCollectibleCount = collectibleListData.filteredOutCollectibleCount,
                    isClearFilterButtonVisible = isAllCollectiblesFilteredOut,
                    isAccountFabVisible = false,
                    isAddCollectibleFloatingActionButtonVisible = canUserSignTransaction
                )
            } else {
                collectibleListingItemMapper.mapToPreviewItem(
                    isLoadingVisible = true,
                    isEmptyStateVisible = false,
                    isErrorVisible = false,
                    isReceiveButtonVisible = false,
                    itemList = listOf(
                        createTitleTextViewItem(isVisible = true),
                        createInfoViewItem(
                            displayedCollectibleCount = 0,
                            isVisible = true,
                            isFilterActive = false,
                            isAddButtonVisible = canUserSignTransaction
                        ),
                        createSearchViewItem(isVisible = true)
                    ),
                    filteredCollectibleCount = 0,
                    isClearFilterButtonVisible = false,
                    isAccountFabVisible = false,
                    isAddCollectibleFloatingActionButtonVisible = false
                )
            }
        }
    }

    private suspend fun prepareCollectiblesListItems(
        searchKeyword: String,
        canUserSignTransaction: Boolean,
        allAccountAllCollectibles: List<Pair<AccountDetail, List<BaseAccountAssetData>>>
    ): BaseCollectibleListData {
        var displayedCollectibleCount = 0
        var totalCollectibleCount = 0
        val isFilterActive = collectibleFilterUseCase.isFilterActive()
        val baseCollectibleItemList = mutableListOf<BaseCollectibleListItem>().apply {
            allAccountAllCollectibles.forEach { accountDetailWithCollectibles ->
                val (accountDetail, collectibles) = accountDetailWithCollectibles
                collectibles.forEach { collectibleData ->
                    if (shouldFilterOutBasedOnSearch(searchKeyword, collectibleData)) return@forEach
                    totalCollectibleCount++
                    val shouldFilterOutCollectible = collectibleFilterUseCase.shouldFilterOutCollectible(
                        collectibleData,
                        accountDetail
                    )
                    if (shouldFilterOutCollectible) return@forEach
                    val isOwnedByTheUser = collectibleUtils.isCollectibleOwnedByTheUser(
                        accountDetail,
                        collectibleData.id
                    )
                    val optedInAccountAddress = accountDetail.account.address
                    val collectibleItem = createCollectibleListItem(
                        collectibleData,
                        isOwnedByTheUser,
                        optedInAccountAddress
                    ) ?: return@forEach

                    add(collectibleItem)
                    displayedCollectibleCount++
                }
            }
            sortByDescending { it is BaseCollectibleListItem.BaseCollectibleItem.BasePendingCollectibleItem }
            if (canUserSignTransaction && allAccountAllCollectibles.isNotEmpty()) {
                add(BaseCollectibleListItem.ReceiveNftItem)
            }
        }
        val sortedBaseCollectibleItemList = collectibleItemSortUseCase.sortCollectibles(baseCollectibleItemList)

        return collectibleListingItemMapper.mapToBaseCollectibleListData(
            sortedBaseCollectibleItemList,
            isFilterActive,
            displayedCollectibleCount,
            totalCollectibleCount
        )
    }

    private fun canAnyAccountSignTransaction(accountList: Collection<CacheResult<AccountDetail>?>): Boolean {
        return accountList.any {
            val publicKey = it?.data?.account?.address ?: return false
            accountDetailUseCase.canAccountSignTransaction(publicKey)
        }
    }

    companion object {
        const val COLLECTIBLES_LIST_CONFIGURATION_HEADER_ITEM_INDEX = 1
    }
}
