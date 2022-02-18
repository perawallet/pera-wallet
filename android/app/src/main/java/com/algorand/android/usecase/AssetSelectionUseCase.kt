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
import com.algorand.android.models.AssetSelection
import com.algorand.android.utils.AccountCacheManager
import javax.inject.Inject

class AssetSelectionUseCase @Inject constructor(
    private val accountAlgoAmountUseCase: AccountAlgoAmountUseCase,
    private val transactionTipsUseCase: TransactionTipsUseCase,
    private val accountCacheManager: AccountCacheManager,
    private val accountSelectionMapper: AccountSelectionMapper,
    private val assetSelectionMapper: AssetSelectionMapper
) {

    fun getCachedAccountFilteredByAssetId(assetId: Long): List<AccountSelection> {
        return accountCacheManager.getAccountCacheWithSpecificAsset(assetId, listOf(Account.Type.WATCH)).map {
            val accountAssetData = accountAlgoAmountUseCase.getAccountAlgoAmount(it.first.account.address)
            accountSelectionMapper.mapToAccountSelection(accountAssetData, it)
        }
    }

    fun getAssets(publicKey: String): List<AssetSelection> {
        return accountCacheManager.getCacheData(publicKey)?.assetsInformation?.map { assetInformation ->
            val accountAssetData = if (assetInformation.isAlgo()) {
                accountAlgoAmountUseCase.getAccountAlgoAmount(publicKey)
            } else {
                null
            }
            assetSelectionMapper.mapTo(assetInformation, accountAssetData)
        }.orEmpty()
    }

    fun shouldShowTransactionTips(): Boolean {
        return transactionTipsUseCase.shouldShowTransactionTips()
    }
}
