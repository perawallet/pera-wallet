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
import androidx.paging.map
import com.algorand.android.assetsearch.domain.mapper.AssetSearchQueryMapper
import com.algorand.android.assetsearch.domain.pagination.AssetSearchPagerBuilder
import com.algorand.android.assetsearch.domain.usecase.SearchAssetUseCase
import com.algorand.android.assetsearch.ui.mapper.BaseAssetSearchItemMapper
import com.algorand.android.assetsearch.ui.model.BaseAssetSearchListItem
import com.algorand.android.models.AccountIcon
import com.algorand.android.models.AssetQueryType
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.nft.domain.model.BaseSimpleCollectible.ImageSimpleCollectibleDetail
import com.algorand.android.nft.domain.model.BaseSimpleCollectible.MixedSimpleCollectibleDetail
import com.algorand.android.nft.domain.model.BaseSimpleCollectible.VideoSimpleCollectibleDetail
import com.algorand.android.usecase.AccountNameIconUseCase
import com.algorand.android.utils.AssetName
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.mapNotNull

class ReceiveCollectiblePreviewUseCase @Inject constructor(
    private val searchAssetUseCase: SearchAssetUseCase,
    private val assetSearchQueryMapper: AssetSearchQueryMapper,
    private val assetSearchItemMapper: BaseAssetSearchItemMapper,
    private val accountNameIconUseCase: AccountNameIconUseCase
) {

    fun getSearchPaginationFlow(
        searchPagerBuilder: AssetSearchPagerBuilder,
        scope: CoroutineScope,
        queryText: String
    ): Flow<PagingData<BaseAssetSearchListItem>> {
        val assetSearchQuery = assetSearchQueryMapper.mapToAssetSearchQuery(queryText, AssetQueryType.ALL, true)
        return searchAssetUseCase.createPaginationFlow(searchPagerBuilder, scope, assetSearchQuery).mapNotNull {
            it.map { baseAssetDetail -> getSearchItemMappedAssetDetail(baseAssetDetail) }
        }
    }

    fun searchAsset(queryText: String) {
        val assetSearchQuery = assetSearchQueryMapper.mapToAssetSearchQuery(queryText, AssetQueryType.ALL, true)
        searchAssetUseCase.searchAsset(assetSearchQuery)
    }

    fun invalidateDataSource() {
        searchAssetUseCase.invalidateDataSource()
    }

    private fun getSearchItemMappedAssetDetail(baseAssetDetail: BaseAssetDetail): BaseAssetSearchListItem {
        val avatarDisplayText = AssetName.create(baseAssetDetail.fullName)
        return with(assetSearchItemMapper) {
            when (baseAssetDetail) {
                is ImageSimpleCollectibleDetail -> mapToImageCollectibleSearchItem(baseAssetDetail, avatarDisplayText)
                is VideoSimpleCollectibleDetail -> mapToVideoCollectibleSearchItem(baseAssetDetail, avatarDisplayText)
                is MixedSimpleCollectibleDetail -> mapToMixedCollectibleSearchItem(baseAssetDetail, avatarDisplayText)
                else -> mapToNotSupportedCollectibleSearchItem(baseAssetDetail, avatarDisplayText)
            }
        }
    }

    fun getReceiverAccountDisplayTextAndIcon(publicKey: String): Pair<String, AccountIcon?> {
        return accountNameIconUseCase.getAccountDisplayTextAndIcon(publicKey)
    }
}
