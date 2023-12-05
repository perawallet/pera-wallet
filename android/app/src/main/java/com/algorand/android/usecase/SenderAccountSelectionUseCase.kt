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

import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AssetInformation
import com.algorand.android.modules.accountasset.GetAccountAssetUseCase
import com.algorand.android.utils.AccountCacheManager
import javax.inject.Inject

class SenderAccountSelectionUseCase @Inject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val transactionTipsUseCase: TransactionTipsUseCase,
    accountInformationUseCase: AccountInformationUseCase,
    getAccountAssetUseCase: GetAccountAssetUseCase
) : BaseSendAccountSelectionUseCase(accountInformationUseCase, getAccountAssetUseCase) {

    fun shouldShowTransactionTips(): Boolean {
        return transactionTipsUseCase.shouldShowTransactionTips()
    }

    fun getAssetInformation(publicKey: String, assetId: Long): AssetInformation? {
        return accountCacheManager.getAssetInformation(publicKey, assetId)
    }

    fun getAccountInformation(publicKey: String): AccountCacheData? {
        return accountCacheManager.getCacheData(publicKey)
    }
}
