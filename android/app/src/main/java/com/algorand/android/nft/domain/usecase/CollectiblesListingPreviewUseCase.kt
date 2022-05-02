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
    private val collectibleFilterUseCase: CollectibleFilterUseCase
) : BaseCollectiblesListingPreviewUseCase(collectibleListingItemMapper, collectibleFilterUseCase) {

    fun getCollectiblesListingPreviewFlow(searchKeyword: String): Flow<CollectiblesListingPreview> {
        return combine(
            accountDetailUseCase.getAccountDetailCacheFlow(),
            failedAssetRepository.getFailedAssetCacheFlow(),
            accountCollectibleDataUseCase.getAllAccountsAllCollectibleDataFlow()
        ) { accountDetailList, failedAssets, accountsAllCollectibles ->
            if (assetCacheManager.cacheStatus isAtLeast EMPTY) {
                val canUserSignTransaction = canAnyAccountSignTransaction(accountDetailList.values)
                val collectibleListData = prepareCollectiblesListItems(
                    searchKeyword,
                    canUserSignTransaction,
                    accountsAllCollectibles
                )
                val isAllCollectiblesFilteredOut = isAllCollectiblesFilteredOut(collectibleListData)
                val isEmptyStateVisible = accountsAllCollectibles.isEmpty() || isAllCollectiblesFilteredOut
                collectibleListingItemMapper.mapToPreviewItem(
                    isLoadingVisible = false,
                    isEmptyStateVisible = isEmptyStateVisible,
                    isErrorVisible = failedAssets.isNotEmpty(),
                    itemList = collectibleListData.baseCollectibleItemList,
                    isReceiveButtonVisible = isEmptyStateVisible,
                    isFilterActive = collectibleListData.isFilterActive,
                    displayedCollectibleCount = collectibleListData.displayedCollectibleCount,
                    filteredCollectibleCount = collectibleListData.filteredOutCollectibleCount,
                    isClearFilterButtonVisible = isAllCollectiblesFilteredOut
                )
            } else {
                collectibleListingItemMapper.mapToPreviewItem(
                    isLoadingVisible = true,
                    isEmptyStateVisible = false,
                    isErrorVisible = false,
                    isReceiveButtonVisible = false,
                    itemList = emptyList(),
                    isFilterActive = false,
                    displayedCollectibleCount = 0,
                    filteredCollectibleCount = 0,
                    isClearFilterButtonVisible = false
                )
            }
        }
    }

    private fun prepareCollectiblesListItems(
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

        return collectibleListingItemMapper.mapToBaseCollectibleListData(
            baseCollectibleItemList,
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
}
