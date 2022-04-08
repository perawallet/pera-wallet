/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.usecase

import com.algorand.android.mapper.AccountSelectionMapper
import com.algorand.android.mapper.AssetSelectionMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountSelection
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleImageData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleMixedData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedCollectibleVideoData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData.OwnedUnsupportedCollectibleData
import com.algorand.android.models.BaseSelectAssetItem
import com.algorand.android.utils.AccountCacheManager
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine

class AssetSelectionUseCase @Inject constructor(
    private val accountAlgoAmountUseCase: AccountAlgoAmountUseCase,
    private val transactionTipsUseCase: TransactionTipsUseCase,
    private val accountCacheManager: AccountCacheManager,
    private val accountSelectionMapper: AccountSelectionMapper,
    private val assetSelectionMapper: AssetSelectionMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val algoPriceUseCase: AlgoPriceUseCase,
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val accountCollectibleDataUseCase: AccountCollectibleDataUseCase,
) {

    fun getCachedAccountFilteredByAssetId(assetId: Long): List<AccountSelection> {
        return accountCacheManager.getAccountCacheWithSpecificAsset(assetId, listOf(Account.Type.WATCH)).map {
            val accountAssetData = accountAlgoAmountUseCase.getAccountAlgoAmount(it.first.account.address)
            accountSelectionMapper.mapToAccountSelection(accountAssetData, it)
        }
    }

    fun getAssetSelectionPreview(publicKey: String): Flow<List<BaseSelectAssetItem>> {
        return combine(
            accountDetailUseCase.getAccountDetailCacheFlow(publicKey),
            algoPriceUseCase.getAlgoPriceCacheFlow()
        ) { _, _ ->
            mutableListOf<BaseSelectAssetItem>().apply {
                val algoAssetSelectionItem = createAlgoSelectionItem(publicKey)
                add(algoAssetSelectionItem)

                val otherAssetSelectionItem = createOtherAssetSelectionItems(publicKey)
                addAll(otherAssetSelectionItem)

                val collectibleSelectionItems = createCollectibleSelectionItems(publicKey)
                addAll(collectibleSelectionItems)
            }
        }
    }

    private fun createAlgoSelectionItem(publicKey: String): BaseSelectAssetItem.SelectAssetItem {
        val algoOwnedAsset = accountAlgoAmountUseCase.getAccountAlgoAmount(publicKey)
        return assetSelectionMapper.mapToAssetItem(algoOwnedAsset)
    }

    private fun createOtherAssetSelectionItems(publicKey: String): List<BaseSelectAssetItem.SelectAssetItem> {
        return accountAssetDataUseCase.getAccountOwnedAssetData(publicKey, false).map { ownedAssetData ->
            assetSelectionMapper.mapToAssetItem(ownedAssetData)
        }
    }

    private fun createCollectibleSelectionItems(
        publicKey: String
    ): List<BaseSelectAssetItem.BaseSelectCollectibleItem> {
        return accountCollectibleDataUseCase.getAccountOwnedCollectibleDataList(publicKey).map { ownedCollectibleData ->
            when (ownedCollectibleData) {
                is OwnedCollectibleImageData -> assetSelectionMapper.mapToCollectibleImageItem(ownedCollectibleData)
                is OwnedCollectibleVideoData -> assetSelectionMapper.mapToCollectibleVideoItem(ownedCollectibleData)
                is OwnedCollectibleMixedData -> assetSelectionMapper.mapToCollectibleMixedItem(ownedCollectibleData)
                is OwnedUnsupportedCollectibleData -> {
                    assetSelectionMapper.mapToCollectibleNotSupportedItem(ownedCollectibleData)
                }
            }
        }
    }

    fun shouldShowTransactionTips(): Boolean {
        return transactionTipsUseCase.shouldShowTransactionTips()
    }
}
