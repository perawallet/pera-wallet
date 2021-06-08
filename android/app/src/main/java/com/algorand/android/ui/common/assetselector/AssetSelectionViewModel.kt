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

package com.algorand.android.ui.common.assetselector

import androidx.hilt.lifecycle.ViewModelInject
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.models.AssetInformation
import com.algorand.android.utils.AccountCacheManager

class AssetSelectionViewModel @ViewModelInject constructor(
    private val accountCacheManager: AccountCacheManager
) : BaseViewModel() {

    fun getAssetSelectionList(selectedAssetInformation: AssetInformation?): List<AssetSelectorBaseItem> {
        val result = mutableListOf<AssetSelectorBaseItem>()
        accountCacheManager.accountCacheMap.value
            .filter { (_, accountCacheData) -> accountCacheData.account.type != Account.Type.WATCH }
            .forEach { (_, accountCacheData) ->
                val assetListMaxIndex = accountCacheData.assetsInformation.size - 1
                for ((index, asset) in accountCacheData.assetsInformation.withIndex()) {
                    if (index == 0) {
                        result.add(AssetSelectorBaseItem.AssetSelectorHeaderItem(accountCacheData))
                    }
                    if (selectedAssetInformation != null) {
                        if (selectedAssetInformation.assetId == asset.assetId) {
                            result.add(AssetSelectorBaseItem.AssetSelectorItem(accountCacheData, asset, false))
                            continue
                        }
                    } else {
                        result.add(
                            AssetSelectorBaseItem.AssetSelectorItem(
                                accountCacheData, asset, index != assetListMaxIndex
                            )
                        )
                    }
                }
            }
        return result
    }
}
