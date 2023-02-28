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
import com.algorand.android.models.Result
import com.algorand.android.models.WalletConnectTransactionAssetDetail
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.usecase.GetAssetDetailFromIndexerUseCase
import com.algorand.android.usecase.GetAssetDetailFromNodeUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
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

    @SuppressWarnings("ReturnCount")
    suspend fun getAssetParams(assetId: Long): WalletConnectTransactionAssetDetail? {
        val cachedAsset = getAssetDetailIfAvailableInWalletConnectCache(assetId)
        if (cachedAsset != null) {
            return cachedAsset
        }

        val cachedAssetDetail = getAssetDetailIfAvailableInAssetDetailCache(assetId)
        if (cachedAssetDetail != null) {
            return cachedAssetDetail
        }

        val cachedNFTDetail = getAssetDetailIfAvailableInNFTtDetailCache(assetId)
        if (cachedNFTDetail != null) {
            return cachedNFTDetail
        }

        val indexerResult = getAsstDetailFromIndexer(assetId)
        if (indexerResult is Result.Success) {
            assetCacheMap[assetId] = indexerResult.data
            return indexerResult.data
        }

        val nodeResult = getAsstDetailFromNode(assetId)
        if (nodeResult is Result.Success) {
            assetCacheMap[assetId] = nodeResult.data
            return nodeResult.data
        }

        return null
    }

    fun clearAssetCacheMap() {
        assetCacheMap.clear()
    }

    private fun getAssetDetailIfAvailableInWalletConnectCache(assetId: Long): WalletConnectTransactionAssetDetail? {
        return assetCacheMap.getOrDefault(assetId, null)
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

    private suspend fun getAsstDetailFromIndexer(assetId: Long): Result<WalletConnectTransactionAssetDetail> {
        return getAssetDetailFromIndexerUseCase.invoke(assetId).map { assetDetail ->
            with(assetDetail) {
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

    private suspend fun getAsstDetailFromNode(assetId: Long): Result<WalletConnectTransactionAssetDetail> {
        return getAssetDetailFromNodeUseCase.invoke(assetId).map { assetDetail ->
            with(assetDetail) {
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
}
