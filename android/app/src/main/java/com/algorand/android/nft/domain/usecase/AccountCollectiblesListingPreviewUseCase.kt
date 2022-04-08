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
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine

class AccountCollectiblesListingPreviewUseCase @Inject constructor(
    private val collectibleListingItemMapper: CollectibleListingItemMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val failedAssetRepository: FailedAssetRepository,
    private val collectibleUtils: CollectibleUtils,
    private val accountCollectibleDataUseCase: AccountCollectibleDataUseCase
) : BaseCollectiblesListingPreviewUseCase(collectibleListingItemMapper) {

    fun getCollectiblesListingPreviewFlow(publicKey: String): Flow<CollectiblesListingPreview> {
        return combine(
            accountDetailUseCase.getAccountDetailCacheFlow(publicKey),
            failedAssetRepository.getFailedAssetCacheFlow(),
            accountCollectibleDataUseCase.getAccountAllCollectibleDataFlow(publicKey)
        ) { accountDetail, failedAssets, accountCollectibleData ->
            val canAccountSignTransaction = canAccountSignTransaction(accountDetail)
            val collectibleList = prepareCollectiblesListItems(
                accountDetail,
                canAccountSignTransaction,
                accountCollectibleData
            )
            val isEmptyStateVisible = accountCollectibleData.isEmpty()
            collectibleListingItemMapper.mapToPreviewItem(
                isLoadingVisible = false,
                isEmptyStateVisible = isEmptyStateVisible,
                isErrorVisible = failedAssets.isNotEmpty(),
                itemList = collectibleList,
                isReceiveButtonVisible = isEmptyStateVisible && canAccountSignTransaction
            )
        }
    }

    private fun prepareCollectiblesListItems(
        accountDetail: CacheResult<AccountDetail>?,
        canAccountSignTransaction: Boolean,
        accountCollectibleData: List<BaseAccountAssetData>
    ): List<BaseCollectibleListItem> {
        return mutableListOf<BaseCollectibleListItem>().apply {
            accountCollectibleData.forEach { collectibleData ->
                val isOwnedByTheUser = collectibleUtils.isCollectibleOwnedByTheUser(accountDetail, collectibleData.id)
                val accountAddress = accountDetail?.data?.account?.address.orEmpty()
                add(createCollectibleListItem(collectibleData, isOwnedByTheUser, accountAddress) ?: return@forEach)
            }
            if (canAccountSignTransaction && accountCollectibleData.isNotEmpty()) {
                add(BaseCollectibleListItem.ReceiveNftItem)
            }
        }
    }

    private fun canAccountSignTransaction(accountDetail: CacheResult<AccountDetail>?): Boolean {
        val publicKey = accountDetail?.data?.account?.address ?: return false
        return accountDetailUseCase.canAccountSignTransaction(publicKey)
    }
}
