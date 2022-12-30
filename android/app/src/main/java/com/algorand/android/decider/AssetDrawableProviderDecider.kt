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
import com.algorand.android.models.AssetDetail
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.models.SimpleCollectibleDetail
import com.algorand.android.nft.domain.model.BaseCollectibleDetail
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.AssetName
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
            isAlgo -> createAlgoDrawableProvider()
            isCollectible -> createCollectibleDrawableProvider(assetId)
            isAsset -> crateAssetDrawableProvider(assetId)
            else -> crateAssetDrawableProvider(assetId)
        }
    }

    private fun createAlgoDrawableProvider(): AlgoDrawableProvider {
        return AlgoDrawableProvider()
    }

    private fun createCollectibleDrawableProvider(assetId: Long): CollectibleDrawableProvider {
        val collectibleDetail = simpleCollectibleUseCase.getCachedCollectibleById(assetId)?.data
        return CollectibleDrawableProvider(
            assetName = AssetName.create(collectibleDetail?.fullName),
            logoUri = collectibleDetail?.collectible?.primaryImageUrl
        )
    }

    private fun crateAssetDrawableProvider(assetId: Long): AssetDrawableProvider {
        val assetDetail = simpleAssetDetailUseCase.getCachedAssetDetail(assetId)?.data
        return AssetDrawableProvider(
            assetName = AssetName.create(assetDetail?.fullName),
            logoUri = assetDetail?.logoUri
        )
    }

    /**
     * Since the all assets are not cached in local, we should check by domain model if it's ASA or NFT in listed ASAs
     * and NFTs in searching screens
     */
    fun getAssetDrawableProvider(searchedAsset: BaseSearchedAsset): BaseAssetDrawableProvider {
        return when {
            searchedAsset.assetId == AssetInformation.ALGO_ID -> {
                // This is unnecessary check but to keep consistency, I added this check, too
                AlgoDrawableProvider()
            }
            searchedAsset is BaseSearchedAsset.SearchedAsset -> {
                AssetDrawableProvider(
                    assetName = AssetName.create(searchedAsset.fullName),
                    logoUri = searchedAsset.logo
                )
            }
            searchedAsset is BaseSearchedAsset.SearchedCollectible -> {
                CollectibleDrawableProvider(
                    assetName = AssetName.create(searchedAsset.fullName),
                    logoUri = searchedAsset.collectible?.primaryImageUrl
                )
            }
            else -> AssetDrawableProvider(
                assetName = AssetName.create(searchedAsset.fullName),
                logoUri = searchedAsset.logo
            )
        }
    }

    /**
     * Since we are caching base asset detail of opened asset in asa profile screen in somewhere else, we should check
     * by [BaseAssetDetail] if it's ASA or NFT in ASA profile screens
     */
    fun getAssetDrawableProvider(baseAssetDetail: BaseAssetDetail): BaseAssetDrawableProvider {
        return when {
            baseAssetDetail.assetId == AssetInformation.ALGO_ID -> {
                // This is unnecessary check but to keep consistency, I added this check, too
                AlgoDrawableProvider()
            }
            baseAssetDetail is AssetDetail -> {
                AssetDrawableProvider(
                    assetName = AssetName.create(baseAssetDetail.fullName),
                    logoUri = baseAssetDetail.logoUri
                )
            }
            baseAssetDetail is SimpleCollectibleDetail -> {
                CollectibleDrawableProvider(
                    assetName = AssetName.create(baseAssetDetail.fullName),
                    logoUri = baseAssetDetail.collectible?.primaryImageUrl
                )
            }
            baseAssetDetail is BaseCollectibleDetail -> {
                CollectibleDrawableProvider(
                    assetName = AssetName.create(baseAssetDetail.fullName),
                    logoUri = baseAssetDetail.prismUrl
                )
            }
            else -> AssetDrawableProvider(
                assetName = AssetName.create(baseAssetDetail.fullName),
                logoUri = baseAssetDetail.logoUri
            )
        }
    }
}
