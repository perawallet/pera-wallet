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

package com.algorand.android.usecase

import com.algorand.android.models.AssetInformation
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import javax.inject.Inject

class GetBaseOwnedAssetDataUseCase @Inject constructor(
    private val accountAlgoAmountUseCase: AccountAlgoAmountUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val simpleCollectibleUseCase: SimpleCollectibleUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val accountAssetAmountUseCase: AccountAssetAmountUseCase,
    private val accountCollectibleDataUseCase: AccountCollectibleDataUseCase
) {

    fun getBaseOwnedAssetData(assetId: Long, publicKey: String): BaseAccountAssetData.BaseOwnedAssetData? {
        val isAlgo = assetId == AssetInformation.ALGORAND_ID
        val isAsset = simpleAssetDetailUseCase.isAssetCached(assetId)
        val isCollectible = simpleCollectibleUseCase.isCollectibleCached(assetId)
        return when {
            isAlgo -> createOwnedAlgoData(publicKey)
            isAsset -> createOwnedAssetData(publicKey, assetId)
            isCollectible -> createOwnedCollectibleData(publicKey, assetId)
            else -> null
        }
    }

    private fun createOwnedAlgoData(publicKey: String): BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData {
        return accountAlgoAmountUseCase.getAccountAlgoAmount(publicKey)
    }

    private fun createOwnedAssetData(
        publicKey: String,
        assetId: Long
    ): BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData? {
        val accountDetail = accountDetailUseCase.getCachedAccountDetail(publicKey)
        val assetQueryItem = simpleAssetDetailUseCase.getCachedAssetDetail(assetId)?.data ?: return null
        val assetHolding = accountDetail?.data?.accountInformation?.assetHoldingList?.firstOrNull {
            it.assetId == assetId
        } ?: return null
        return accountAssetAmountUseCase.getAssetAmount(assetHolding, assetQueryItem)
    }

    private fun createOwnedCollectibleData(
        publicKey: String,
        collectibleAssetId: Long
    ): BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData? {
        return accountCollectibleDataUseCase.getAccountOwnedCollectibleDataList(publicKey).firstOrNull {
            it.id == collectibleAssetId
        }
    }
}
