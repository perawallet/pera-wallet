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
import com.algorand.android.nft.ui.model.BaseCollectibleListItem
import com.algorand.android.nft.ui.model.CollectiblesListingPreview
import com.algorand.android.nft.utils.CollectibleUtils
import com.algorand.android.repository.FailedAssetRepository
import com.algorand.android.usecase.AccountCollectibleDataUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.coremanager.AssetCacheManager
import com.algorand.android.utils.coremanager.AssetCacheManager.AssetCacheStatus.EMPTY
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import javax.inject.Inject

class CollectiblesListingPreviewUseCase @Inject constructor(
    private val collectibleListingItemMapper: CollectibleListingItemMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val failedAssetRepository: FailedAssetRepository,
    private val assetCacheManager: AssetCacheManager,
    private val collectibleUtils: CollectibleUtils,
    private val accountCollectibleDataUseCase: AccountCollectibleDataUseCase
) : BaseCollectiblesListingPreviewUseCase(collectibleListingItemMapper) {

    fun getCollectiblesListingPreviewFlow(): Flow<CollectiblesListingPreview> {
        return combine(
            accountDetailUseCase.getAccountDetailCacheFlow(),
            failedAssetRepository.getFailedAssetCacheFlow(),
            accountCollectibleDataUseCase.getAllAccountsAllCollectibleDataFlow()
        ) { accountDetailList, failedAssets, accountsAllCollectibles ->
            if (assetCacheManager.cacheStatus isAtLeast EMPTY) {
                val canUserSignTransaction = canAnyAccountSignTransaction(accountDetailList.values)
                val collectibleList = prepareCollectiblesListItems(
                    canUserSignTransaction,
                    accountsAllCollectibles
                )
                val isEmptyStateVisible = accountsAllCollectibles.isEmpty()
                collectibleListingItemMapper.mapToPreviewItem(
                    isLoadingVisible = false,
                    isEmptyStateVisible = isEmptyStateVisible,
                    isErrorVisible = failedAssets.isNotEmpty(),
                    itemList = collectibleList,
                    isReceiveButtonVisible = canUserSignTransaction
                )
            } else {
                collectibleListingItemMapper.mapToPreviewItem(
                    isLoadingVisible = true,
                    isEmptyStateVisible = false,
                    isErrorVisible = false,
                    isReceiveButtonVisible = false,
                    itemList = emptyList()
                )
            }
        }
    }

    private fun prepareCollectiblesListItems(
        canUserSignTransaction: Boolean,
        allAccountAllCollectibles: List<Pair<AccountDetail, List<BaseAccountAssetData>>>
    ): List<BaseCollectibleListItem> {
        return mutableListOf<BaseCollectibleListItem>().apply {
            allAccountAllCollectibles.forEach { accountDetailWithCollectibles ->
                val (accountDetail, collectibles) = accountDetailWithCollectibles
                collectibles.forEach { collectibleData ->
                    val isOwnedByTheUser = collectibleUtils.isCollectibleOwnedByTheUser(
                        accountDetail,
                        collectibleData.id
                    )
                    val optedInAccountAddress = accountDetail.account.address
                    val collectibleItem = createCollectibleListItem(
                        collectibleData,
                        isOwnedByTheUser,
                        optedInAccountAddress
                    )
                    if (collectibleItem != null) add(collectibleItem)
                }
            }
            sortByDescending { it is BaseCollectibleListItem.BaseCollectibleItem.BasePendingCollectibleItem }
            if (canUserSignTransaction && allAccountAllCollectibles.isNotEmpty()) {
                add(BaseCollectibleListItem.ReceiveNftItem)
            }
        }
    }

    private fun canAnyAccountSignTransaction(accountList: Collection<CacheResult<AccountDetail>?>): Boolean {
        return accountList.any {
            val publicKey = it?.data?.account?.address ?: return false
            accountDetailUseCase.canAccountSignTransaction(publicKey)
        }
    }
}
