/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.accounts

import androidx.hilt.lifecycle.ViewModelInject
import com.algorand.android.core.AccountManager
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.ui.common.listhelper.BaseAccountListItem
import com.algorand.android.ui.common.listhelper.viewholders.AddAssetListItem
import com.algorand.android.ui.common.listhelper.viewholders.AssetListItem
import com.algorand.android.ui.common.listhelper.viewholders.HeaderAccountListItem
import com.algorand.android.utils.AccountCacheManager
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combineTransform
import kotlinx.coroutines.flow.map

class AccountsViewModel @ViewModelInject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val accountManager: AccountManager
) : BaseViewModel() {

    val listFlow: Flow<List<BaseAccountListItem>>
        get() {
            return accountCacheManager.accountCacheMap.combineTransform(accountManager.accounts) { cacheMap, accounts ->
                emit(mutableListOf<BaseAccountListItem>().apply {
                    cacheMap.forEach { (address, cacheData) ->
                        val accountName = accounts.find { it.address == address }?.name.orEmpty()
                        val isWatchAccount = cacheData.account.type == Account.Type.WATCH
                        add(HeaderAccountListItem(cacheData))
                        val assetsInformation = cacheData.assetsInformation
                        addAll(assetsInformation.mapIndexed { index, assetInformation ->
                            val isRoundedCornerNeeded = isWatchAccount && index + 1 == assetsInformation.size
                            AssetListItem(address, accountName, assetInformation, isRoundedCornerNeeded)
                        })
                        if (isWatchAccount.not()) {
                            add(AddAssetListItem(address))
                        }
                    }
                })
            }
        }

    val isAnyAccountRegisteredFlow: Flow<Boolean>
        get() {
            return accountManager.accounts.map { it.isNotEmpty() }
        }
}
