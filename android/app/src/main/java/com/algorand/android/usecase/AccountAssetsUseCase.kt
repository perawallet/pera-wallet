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
import com.algorand.android.mapper.AccountDetailAssetItemMapper
import com.algorand.android.models.AccountDetailAssetsItem
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.BaseAccountAssetData.OwnedAssetData
import com.algorand.android.utils.formatAsCurrency
import java.math.BigDecimal
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine

class AccountAssetsUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val accountDetailAssetItemMapper: AccountDetailAssetItemMapper,
    private val algoPriceUseCase: AlgoPriceUseCase
) {

    fun fetchAccountDetail(publicKey: String): Flow<List<AccountDetailAssetsItem>> {
        return combine(
            accountAssetDataUseCase.getAccountAllAssetDataFlow(publicKey, true),
            algoPriceUseCase.getAlgoPriceCacheFlow()
        ) { accountAssetData, _ ->
            var accountValue = BigDecimal.ZERO
            mutableListOf<AccountDetailAssetsItem>().apply {
                add(AccountDetailAssetsItem.TitleItem(R.string.assets))
                add(AccountDetailAssetsItem.SearchViewItem)
                if (accountDetailUseCase.canAccountSignTransaction(publicKey)) {
                    add(AccountDetailAssetsItem.AssetAdditionItem)
                }
                accountAssetData.forEach { accountAssetData ->
                    accountValue += (accountAssetData as? OwnedAssetData)?.amountInSelectedCurrency ?: BigDecimal.ZERO
                    add(createAssetListItem(accountAssetData))
                }
                val selectedCurrencySymbol = algoPriceUseCase.getSelectedCurrencySymbolOrCurrencyName()
                add(0, AccountDetailAssetsItem.AccountValueItem(accountValue.formatAsCurrency(selectedCurrencySymbol)))
            }
        }
    }

    private fun createAssetListItem(assetData: BaseAccountAssetData): AccountDetailAssetsItem.BaseAssetItem {
        return with(accountDetailAssetItemMapper) {
            when (assetData) {
                is OwnedAssetData -> mapToOwnedAssetItem(assetData)
                is BaseAccountAssetData.PendingAssetData.AdditionAssetData -> mapToPendingAdditionAssetItem(assetData)
                is BaseAccountAssetData.PendingAssetData.DeletionAssetData -> mapToPendingRemovalAssetItem(assetData)
            }
        }
    }
}
