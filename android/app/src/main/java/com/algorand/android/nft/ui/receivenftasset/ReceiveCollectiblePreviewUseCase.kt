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

package com.algorand.android.nft.ui.receivenftasset

import androidx.paging.PagingData
import androidx.paging.insertHeaderItem
import androidx.paging.map
import com.algorand.android.R
import com.algorand.android.assetsearch.domain.mapper.AssetSearchQueryMapper
import com.algorand.android.assetsearch.domain.model.BaseSearchedAsset
import com.algorand.android.assetsearch.domain.pagination.AssetSearchPagerBuilder
import com.algorand.android.assetsearch.domain.usecase.SearchAssetUseCase
import com.algorand.android.assetsearch.ui.mapper.BaseAssetSearchItemMapper
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.ui.AccountAssetItemButtonState
import com.algorand.android.modules.assets.addition.domain.usecase.AssetItemActionButtonStateDecider
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.AccountNameIconUseCase
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged

class ReceiveCollectiblePreviewUseCase @Inject constructor(
    private val searchAssetUseCase: SearchAssetUseCase,
    private val assetSearchQueryMapper: AssetSearchQueryMapper,
    private val assetSearchItemMapper: BaseAssetSearchItemMapper,
    private val accountNameIconUseCase: AccountNameIconUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val assetItemActionButtonStateDecider: AssetItemActionButtonStateDecider
) {

    fun getSearchPaginationFlow(
        searchPagerBuilder: AssetSearchPagerBuilder,
        scope: CoroutineScope,
        queryText: String,
        accountAddress: String
    ): Flow<PagingData<BaseAssetSearchListItem>> {
        val assetSearchQuery = assetSearchQueryMapper.mapToAssetSearchQuery(
            queryText = queryText,
            hasCollectibles = true,
            availableOnDiscoverMobile = null
        )
        val searchedAssetsFlow = searchAssetUseCase.createPaginationFlow(
            builder = searchPagerBuilder,
            scope = scope,
            defaultQuery = assetSearchQuery
        )

        val accountCollectiblesFlow = accountDetailUseCase.getAccountDetailCacheFlow(
            publicKey = accountAddress
        )

        val searchViewItem = assetSearchItemMapper.mapToSearchViewItem(
            searchViewHintResId = R.string.search_asset_id_or_nft
        )

        val infoViewItem = assetSearchItemMapper.mapToInfoViewItem()

        return combine(searchedAssetsFlow, accountCollectiblesFlow) { searchedAssets, accountDetail ->
            searchedAssets.map { baseSearchedAsset ->
                val accountInformation = accountDetail?.data?.accountInformation
                val assetHolding = accountInformation?.assetHoldingList?.firstOrNull {
                    it.assetId == baseSearchedAsset.assetId
                }
                val assetActionButtonState = assetItemActionButtonStateDecider.decideAssetItemActionButtonState(
                    assetHolding = assetHolding
                )
                getSearchItemMappedAssetDetail(baseSearchedAsset, assetActionButtonState)
            }.insertHeaderItem(item = searchViewItem).insertHeaderItem(item = infoViewItem)
        }.distinctUntilChanged()
    }

    suspend fun searchAsset(queryText: String) {
        val assetSearchQuery = assetSearchQueryMapper.mapToAssetSearchQuery(
            queryText = queryText,
            hasCollectibles = true,
            availableOnDiscoverMobile = null
        )
        searchAssetUseCase.searchAsset(assetSearchQuery)
    }

    fun invalidateDataSource() {
        searchAssetUseCase.invalidateDataSource()
    }

    private fun getSearchItemMappedAssetDetail(
        baseSearchedAsset: BaseSearchedAsset,
        assetActionButtonState: AccountAssetItemButtonState
    ): BaseAssetSearchListItem {
        return with(assetSearchItemMapper) {
            when (baseSearchedAsset) {
                is BaseSearchedAsset.SearchedAsset -> {
                    mapToAssetSearchItem(
                        searchedAsset = baseSearchedAsset,
                        accountAssetItemButtonState = assetActionButtonState
                    )
                }
                is BaseSearchedAsset.SearchedCollectible -> {
                    mapToCollectibleSearchItem(
                        searchedCollectible = baseSearchedAsset,
                        accountAssetItemButtonState = assetActionButtonState
                    )
                }
                else -> throw Exception("Unable to handle this kind of searched item.")
            }
        }
    }

    fun getReceiverAccountDisplayTextAndIcon(publicKey: String): Pair<String, AccountIconResource?> {
        return accountNameIconUseCase.getAccountDisplayTextAndIcon(publicKey)
    }
}
