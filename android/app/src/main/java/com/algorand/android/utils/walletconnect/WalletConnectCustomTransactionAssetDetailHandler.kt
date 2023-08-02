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

package com.algorand.android.utils.walletconnect

import com.algorand.android.mapper.WalletConnectTransactionAssetDetailMapper
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.models.WalletConnectTransactionAssetDetail
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.usecase.AssetFetchAndCacheUseCase.Companion.MAX_ASSET_FETCH_COUNT
import com.algorand.android.usecase.GetAssetDetailFromIndexerUseCase
import com.algorand.android.usecase.GetAssetDetailFromNodeUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import javax.inject.Inject

class WalletConnectCustomTransactionAssetDetailHandler @Inject constructor(
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val simpleCollectibleUseCase: SimpleCollectibleUseCase,
    private val getAssetDetailFromIndexerUseCase: GetAssetDetailFromIndexerUseCase,
    private val getAssetDetailFromNodeUseCase: GetAssetDetailFromNodeUseCase,
    private val walletConnectTransactionAssetDetailMapper: WalletConnectTransactionAssetDetailMapper
) {

    /**
     * Stores asset detail that wallet connect request contains
     * to fasten the process for requests that contains same asset
     */
    private val assetCacheMap = mutableMapOf<Long, WalletConnectTransactionAssetDetail>()

    suspend fun getAssetParamsDefinedWCTransactionList(
        assetIdList: List<Long>,
        scope: CoroutineScope
    ): Map<Long, WalletConnectTransactionAssetDetail?> {
        val assetIdSet = assetIdList.toSet()
        val assetIdToBeFetched = checkAssetsInLocalCacheAndReturnNonExistingIds(assetIdSet)
        fetchAssetsFromIndexerAndUpdateCache(assetIdToBeFetched, scope)
        return assetCacheMap
    }

    private fun checkAssetsInLocalCacheAndReturnNonExistingIds(assetIdSet: Set<Long>): List<Long> {
        return assetIdSet.mapNotNull { assetId ->
            val assetInWalletConnectCache = assetCacheMap.getOrDefault(assetId, null)
            if (assetInWalletConnectCache != null) return@mapNotNull null
            getAssetDetailIfAvailableInAssetDetailCache(assetId)?.let { cachedAssetDetail ->
                assetCacheMap[assetId] = cachedAssetDetail
                return@mapNotNull null
            }
            getAssetDetailIfAvailableInNFTtDetailCache(assetId)?.let { cachedNftDetail ->
                assetCacheMap[assetId] = cachedNftDetail
                return@mapNotNull null
            }
            assetId
        }
    }

    private suspend fun fetchAssetsFromIndexerAndUpdateCache(
        assetIdList: List<Long>,
        scope: CoroutineScope
    ): List<Unit> {
        val chunkedAssetIds = assetIdList.toSet().chunked(MAX_ASSET_FETCH_COUNT)
        return chunkedAssetIds.map { assetIdChunk ->
            scope.async {
                getAssetDetailFromIndexerUseCase(assetIdChunk).use(
                    onSuccess = { baseAssetDetails ->
                        baseAssetDetails.map { assetDetail ->
                            assetCacheMap[assetDetail.assetId] = mapAssetDetailToWcAssetDetail(assetDetail)
                        }
                    },
                    onFailed = { _, _ ->
                        fetchAssetsFromNodeAndUpdateCache(assetIdChunk, scope)
                    }
                )
            }
        }.awaitAll()
    }

    private suspend fun fetchAssetsFromNodeAndUpdateCache(assetIdList: List<Long>, scope: CoroutineScope) {
        assetIdList.map { assetId ->
            scope.async {
                getAssetDetailFromNodeUseCase.invoke(assetId).use(
                    onSuccess = { assetDetail ->
                        assetCacheMap[assetId] = mapAssetDetailToWcAssetDetail(assetDetail)
                    }
                )
            }
        }.awaitAll()
    }

    fun clearAssetCacheMap() {
        assetCacheMap.clear()
    }

    private fun getAssetDetailIfAvailableInAssetDetailCache(assetId: Long): WalletConnectTransactionAssetDetail? {
        val cachedAssetDetail = simpleAssetDetailUseCase.getCachedAssetDetail(assetId)?.data
        return with(cachedAssetDetail ?: return null) {
            walletConnectTransactionAssetDetailMapper.mapToWalletConnectTransactionAssetDetail(
                assetId = assetId,
                fullName = fullName,
                shortName = shortName,
                fractionDecimals = fractionDecimals,
                verificationTier = verificationTier
            )
        }
    }

    private fun getAssetDetailIfAvailableInNFTtDetailCache(assetId: Long): WalletConnectTransactionAssetDetail? {
        val cachedNFTDetail = simpleCollectibleUseCase.getCachedCollectibleById(assetId)?.data
        return with(cachedNFTDetail ?: return null) {
            walletConnectTransactionAssetDetailMapper.mapToWalletConnectTransactionAssetDetail(
                assetId = assetId,
                fullName = fullName,
                shortName = shortName,
                fractionDecimals = fractionDecimals,
                verificationTier = verificationTier
            )
        }
    }

    private fun mapAssetDetailToWcAssetDetail(assetDetail: BaseAssetDetail): WalletConnectTransactionAssetDetail {
        return with(assetDetail) {
            walletConnectTransactionAssetDetailMapper.mapToWalletConnectTransactionAssetDetail(
                assetId = assetId,
                fullName = fullName,
                shortName = shortName,
                fractionDecimals = fractionDecimals,
                verificationTier = verificationTier
            )
        }
    }
}
