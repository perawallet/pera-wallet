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
import com.algorand.android.models.AccountDetailAssetsItem.AccountPortfolioItem
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.AdditionAssetData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.DeletionAssetData
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.modules.swap.reddot.domain.usecase.GetSwapFeatureRedDotVisibilityUseCase
import com.algorand.android.modules.sorting.assetsorting.ui.usecase.AssetItemSortUseCase
import com.algorand.android.utils.extensions.addFirst
import com.algorand.android.utils.formatAsCurrency
import java.math.BigDecimal
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine

class AccountAssetsPreviewUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val accountDetailAssetItemMapper: AccountDetailAssetItemMapper,
    private val parityUseCase: ParityUseCase,
    private val assetItemSortUseCase: AssetItemSortUseCase,
    private val getSwapFeatureRedDotVisibilityUseCase: GetSwapFeatureRedDotVisibilityUseCase
) {

    fun fetchAccountDetail(publicKey: String, query: String): Flow<List<AccountDetailAssetsItem>> {
        return combine(
            accountAssetDataUseCase.getAccountAllAssetDataFlow(publicKey, true),
            parityUseCase.getSelectedCurrencyDetailCacheFlow()
        ) { accountAssetData, _ ->
            var primaryAccountValue = BigDecimal.ZERO
            var secondaryAccountValue = BigDecimal.ZERO
            val assetItemList = mutableListOf<AccountDetailAssetsItem.BaseAssetItem>().apply {
                accountAssetData.forEach { accountAssetData ->
                    (accountAssetData as? OwnedAssetData)?.let { assetData ->
                        primaryAccountValue += assetData.parityValueInSelectedCurrency.amountAsCurrency
                        secondaryAccountValue += assetData.parityValueInSecondaryCurrency.amountAsCurrency
                    }
                    if (shouldDisplayAsset(accountAssetData, query)) {
                        add(createAssetListItem(accountAssetData) ?: return@forEach)
                    }
                }
            }
            mutableListOf<AccountDetailAssetsItem>().apply {
                val isAddAssetButtonVisible = accountDetailUseCase.canAccountSignTransaction(publicKey)
                add(accountDetailAssetItemMapper.mapToTitleItem(R.string.assets, isAddAssetButtonVisible))
                add(accountDetailAssetItemMapper.mapToSearchViewItem(query))
                addAll(assetItemSortUseCase.sortAssets(assetItemList))
                if (assetItemList.isEmpty()) {
                    add(accountDetailAssetItemMapper.mapToNoAssetFoundViewItem())
                }
                val accountPortfolioItem = createAccountPortfolioItem(primaryAccountValue, secondaryAccountValue)
                addFirst(accountPortfolioItem)

                if (accountDetailUseCase.canAccountSignTransaction(publicKey)) {
                    val quickActionsItem = accountDetailAssetItemMapper.mapToQuickActionsItem(
                        isSwapButtonSelected = getSwapFeatureRedDotVisibilityUseCase.getSwapFeatureRedDotVisibility()
                    )
                    add(QUICK_ACTIONS_INDEX, quickActionsItem)
                }
            }
        }
    }

    private fun shouldDisplayAsset(asset: BaseAccountAssetData, query: String): Boolean {
        val trimmedQuery = query.trim()
        with(asset) {
            return id.toString().contains(trimmedQuery, ignoreCase = true) ||
                shortName?.contains(trimmedQuery, ignoreCase = true) == true ||
                name?.contains(trimmedQuery, ignoreCase = true) == true
        }
    }

    private fun createAccountPortfolioItem(
        primaryAccountValue: BigDecimal,
        secondaryAccountValue: BigDecimal
    ): AccountPortfolioItem {
        val selectedCurrencySymbol = parityUseCase.getPrimaryCurrencySymbolOrName()
        val secondaryCurrencySymbol = parityUseCase.getSecondaryCurrencySymbol()
        val formattedPrimaryAccountValue = primaryAccountValue.formatAsCurrency(selectedCurrencySymbol)
        val formattedSecondaryAccountValue = secondaryAccountValue.formatAsCurrency(secondaryCurrencySymbol)
        return AccountPortfolioItem(formattedPrimaryAccountValue, formattedSecondaryAccountValue)
    }

    private fun createAssetListItem(
        assetData: BaseAccountAssetData
    ): AccountDetailAssetsItem.BaseAssetItem? {
        return with(accountDetailAssetItemMapper) {
            when (assetData) {
                is OwnedAssetData -> mapToOwnedAssetItem(assetData)
                is AdditionAssetData -> mapToPendingAdditionAssetItem(assetData)
                is DeletionAssetData -> mapToPendingRemovalAssetItem(assetData)
                // TODO: 24.03.2022 We should use interface instead of using when
                else -> null
            }
        }
    }

    fun canAccountSignTransactions(publicKey: String): Boolean {
        return accountDetailUseCase.canAccountSignTransaction(publicKey)
    }

    companion object {
        const val QUICK_ACTIONS_INDEX = 1
    }
}
