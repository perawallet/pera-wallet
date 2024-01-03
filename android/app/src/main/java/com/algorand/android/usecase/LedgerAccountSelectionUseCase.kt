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

import com.algorand.android.core.BaseUseCase
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AccountSelectionListItem
import kotlinx.coroutines.coroutineScope

abstract class LedgerAccountSelectionUseCase constructor(
    private val assetFetchAndCacheUseCase: AssetFetchAndCacheUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase
) : BaseUseCase() {

    fun getAuthAccountOf(
        accountSelectionListItem: AccountSelectionListItem.AccountItem,
        accountSelectionAccountList: List<AccountSelectionListItem.AccountItem>?
    ): AccountSelectionListItem.AccountItem? {
        return accountSelectionAccountList?.run {
            if (accountSelectionListItem.accountInformation.isRekeyed()) {
                val rekeyAdminAddress = accountSelectionListItem.accountInformation.rekeyAdminAddress
                firstOrNull { rekeyAdminAddress == it.account.address }
            } else {
                null
            }
        }
    }

    fun getRekeyedAccountOf(
        accountSelectionListItem: AccountSelectionListItem.AccountItem,
        accountSelectionAccountList: List<AccountSelectionListItem.AccountItem>?
    ): Array<AccountSelectionListItem.AccountItem>? {
        val accountAddress = accountSelectionListItem.account.address
        return accountSelectionAccountList?.filter {
            it.account.address != accountAddress && it.accountInformation.rekeyAdminAddress == accountAddress
        }?.toTypedArray()
    }

    protected suspend fun cacheLedgerAccountAssets(accountInformation: AccountInformation) {
        val assetIds = accountInformation.getAssetIdList().toSet()
        val filteredAssetList = simpleAssetDetailUseCase.getChunkedAndFilteredAssetList(assetIds)
        coroutineScope { assetFetchAndCacheUseCase.processFilteredAssetIdList(filteredAssetList, this) }
    }
}
