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

import com.algorand.android.R
import com.algorand.android.core.BaseUseCase
import com.algorand.android.mapper.AccountDetailAssetItemMapper
import com.algorand.android.models.AccountDetailAssetsItem
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.Result
import javax.inject.Inject
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow

class AssetSearchUseCase @Inject constructor(
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val accountDetailAssetItemMapper: AccountDetailAssetItemMapper
) : BaseUseCase() {

    suspend fun fetchAccountAssets(publicKey: String, query: String) = flow<Result<List<AccountDetailAssetsItem>>> {
        accountAssetDataUseCase.getAccountOwnedAssetDataFlow(publicKey, true).collect {
            val accountDetailAssetItems = mutableListOf<AccountDetailAssetsItem>().apply {
                it.forEach { accountAssetData ->
                    if (isQueriedAsset(accountAssetData, query)) {
                        add(accountDetailAssetItemMapper.mapToOwnedAssetItem(accountAssetData))
                    }
                }
            }
            if (accountDetailAssetItems.isNotEmpty()) {
                accountDetailAssetItems.add(0, AccountDetailAssetsItem.TitleItem(R.string.assets))
            }
            emit(Result.Success(accountDetailAssetItems))
        }
    }

    private fun isQueriedAsset(accountAssetData: BaseAccountAssetData, query: String): Boolean {
        return with(accountAssetData) {
            shortName?.contains(query, true) == true ||
                name?.contains(query, true) == true ||
                id.toString().contains(query, true)
        }
    }
}
