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

package com.algorand.android.decider

import com.algorand.android.assetsearch.domain.model.BaseSearchedAsset
import com.algorand.android.models.AssetInformation
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.assetdrawable.AlgoDrawableProvider
import com.algorand.android.utils.assetdrawable.AssetDrawableProvider
import com.algorand.android.utils.assetdrawable.BaseAssetDrawableProvider
import com.algorand.android.utils.assetdrawable.CollectibleDrawableProvider
import javax.inject.Inject

class AssetDrawableProviderDecider @Inject constructor(
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val simpleCollectibleUseCase: SimpleCollectibleUseCase
) {

    fun getAssetDrawableProvider(assetId: Long): BaseAssetDrawableProvider {
        val isAlgo = assetId == AssetInformation.ALGO_ID
        val isAsset = simpleAssetDetailUseCase.isAssetCached(assetId)
        val isCollectible = simpleCollectibleUseCase.isCollectibleCached(assetId)
        return when {
            isAlgo -> AlgoDrawableProvider()
            isAsset -> AssetDrawableProvider()
            isCollectible -> CollectibleDrawableProvider()
            else -> AssetDrawableProvider()
        }
    }

    /**
     * Since the all assets are not cached in local, we should check by domain model if it's ASA or NFT in listed ASAs
     * and NFTs in searching screens
     */
    fun getAssetDrawableProvider(searchedAsset: BaseSearchedAsset): BaseAssetDrawableProvider {
        // This is unnecessary check but to keep consistency, I added this check, too
        val isAlgo = searchedAsset.assetId == AssetInformation.ALGO_ID
        val isAsset = searchedAsset is BaseSearchedAsset.SearchedAsset ||
            searchedAsset is BaseSearchedAsset.DiscoverSearchedAsset
        val isCollectible = searchedAsset is BaseSearchedAsset.SearchedCollectible ||
            searchedAsset is BaseSearchedAsset.DiscoverSearchedCollectible
        return when {
            isAlgo -> AlgoDrawableProvider()
            isAsset -> AssetDrawableProvider()
            isCollectible -> CollectibleDrawableProvider()
            else -> AssetDrawableProvider()
        }
    }
}
