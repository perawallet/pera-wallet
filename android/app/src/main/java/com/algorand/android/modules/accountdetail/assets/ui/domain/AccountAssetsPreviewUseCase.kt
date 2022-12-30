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

package com.algorand.android.modules.accountdetail.assets.ui.domain

import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.BaseAccountAssetData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.BaseOwnedCollectibleData
import com.algorand.android.models.BaseAccountAssetData.BaseOwnedAssetData.OwnedAssetData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.AdditionAssetData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingAdditionCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.BasePendingCollectibleData.PendingDeletionCollectibleData
import com.algorand.android.models.BaseAccountAssetData.PendingAssetData.DeletionAssetData
import com.algorand.android.modules.accountdetail.assets.ui.mapper.AccountDetailAssetItemMapper
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem
import com.algorand.android.modules.accountdetail.assets.ui.model.AccountDetailAssetsItem.AccountPortfolioItem
import com.algorand.android.modules.assets.filter.domain.usecase.ShouldDisplayNFTInAssetsPreferenceUseCase
import com.algorand.android.modules.assets.filter.domain.usecase.ShouldDisplayOptedInNFTInAssetsPreferenceUseCase
import com.algorand.android.modules.assets.filter.domain.usecase.ShouldHideZeroBalanceAssetsPreferenceUseCase
import com.algorand.android.modules.collectibles.listingviewtype.domain.model.NFTListingViewType
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.modules.sorting.assetsorting.ui.usecase.AssetItemSortUseCase
import com.algorand.android.modules.swap.reddot.domain.usecase.GetSwapFeatureRedDotVisibilityUseCase
import com.algorand.android.usecase.AccountAssetDataUseCase
import com.algorand.android.usecase.AccountCollectibleDataUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.GetFormattedAccountMinimumBalanceUseCase
import com.algorand.android.utils.formatAsAlgoAmount
import com.algorand.android.utils.formatAsCurrency
import com.algorand.android.utils.isGreaterThan
import java.math.BigDecimal
import java.math.BigInteger
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine

@SuppressWarnings("LongParameterList")
class AccountAssetsPreviewUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val accountDetailAssetItemMapper: AccountDetailAssetItemMapper,
    private val parityUseCase: ParityUseCase,
    private val assetItemSortUseCase: AssetItemSortUseCase,
    private val getSwapFeatureRedDotVisibilityUseCase: GetSwapFeatureRedDotVisibilityUseCase,
    private val getFormattedAccountMinimumBalanceUseCase: GetFormattedAccountMinimumBalanceUseCase,
    private val shouldHideZeroBalanceAssetsPreferenceUseCase: ShouldHideZeroBalanceAssetsPreferenceUseCase,
    private val shouldDisplayNFTInAssetsPreferenceUseCase: ShouldDisplayNFTInAssetsPreferenceUseCase,
    private val shouldDisplayOptedInNFTInAssetsPreferenceUseCase: ShouldDisplayOptedInNFTInAssetsPreferenceUseCase,
    private val accountCollectibleDataUseCase: AccountCollectibleDataUseCase
) {

    fun fetchAccountDetail(accountAddress: String, query: String): Flow<List<AccountDetailAssetsItem>> {
        return combine(
            accountAssetDataUseCase.getAccountAllAssetDataFlow(accountAddress, true),
            accountCollectibleDataUseCase.getAccountAllCollectibleDataFlow(accountAddress),
            parityUseCase.getSelectedCurrencyDetailCacheFlow()
        ) { accountAssetData, accountNFTData, _ ->
            var primaryAccountValue = BigDecimal.ZERO
            var secondaryAccountValue = BigDecimal.ZERO
            val assetItemList = createAssetListItems(
                accountAssetData = accountAssetData,
                query = query,
                onCalculationDone = { primaryAssetsValue, secondaryAssetsValue ->
                    primaryAccountValue += primaryAssetsValue
                    secondaryAccountValue += secondaryAssetsValue
                }
            )
            val collectibleItemList = createNFTListItems(
                accountAddress = accountAddress,
                accountNFTData = accountNFTData,
                query = query,
                onCalculationDone = { primaryNFTsValue, secondaryNFTsValue ->
                    primaryAccountValue += primaryNFTsValue
                    secondaryAccountValue += secondaryNFTsValue
                }
            )
            mutableListOf<AccountDetailAssetsItem>().apply {
                val accountPortfolioItem = createAccountPortfolioItem(primaryAccountValue, secondaryAccountValue)
                add(accountPortfolioItem)
                val canAccountSignTransaction = accountDetailUseCase.canAccountSignTransaction(accountAddress)
                if (canAccountSignTransaction) {
                    val requiredMinimumBalanceItem = createRequiredMinimumBalanceItem(accountAddress)
                    add(requiredMinimumBalanceItem)
                    val quickActionsItem = accountDetailAssetItemMapper.mapToQuickActionsItem(
                        isSwapButtonSelected = getSwapFeatureRedDotVisibilityUseCase.getSwapFeatureRedDotVisibility()
                    )
                    add(quickActionsItem)
                }
                add(accountDetailAssetItemMapper.mapToTitleItem(R.string.assets, canAccountSignTransaction))
                add(accountDetailAssetItemMapper.mapToSearchViewItem(query))
                addAll(assetItemSortUseCase.sortAssets(assetItemList + collectibleItemList))
                if (assetItemList.isEmpty() && collectibleItemList.isEmpty()) {
                    add(accountDetailAssetItemMapper.mapToNoAssetFoundViewItem())
                }
            }
        }
    }

    private suspend fun createAssetListItems(
        accountAssetData: List<BaseAccountAssetData>,
        query: String,
        onCalculationDone: (BigDecimal, BigDecimal) -> Unit
    ): List<AccountDetailAssetsItem.BaseAssetItem> {
        var primaryAssetsValue = BigDecimal.ZERO
        var secondaryAssetsValue = BigDecimal.ZERO
        val eliminatedAssetList = eliminateAssetsRegardingByFilteringPreferenceIfNeed(accountAssetData)
        return mutableListOf<AccountDetailAssetsItem.BaseAssetItem>().apply {
            eliminatedAssetList.forEach { accountAssetData ->
                (accountAssetData as? OwnedAssetData)?.let { assetData ->
                    primaryAssetsValue += assetData.parityValueInSelectedCurrency.amountAsCurrency
                    secondaryAssetsValue += assetData.parityValueInSecondaryCurrency.amountAsCurrency
                }
                if (shouldDisplayAsset(accountAssetData, query)) {
                    add(createAssetListItem(accountAssetData) ?: return@forEach)
                }
            }
        }.also { onCalculationDone.invoke(primaryAssetsValue, secondaryAssetsValue) }
    }

    private suspend fun eliminateAssetsRegardingByFilteringPreferenceIfNeed(
        accountAssetData: List<BaseAccountAssetData>
    ): List<BaseAccountAssetData> {
        return if (shouldHideZeroBalanceAssetsPreferenceUseCase()) {
            accountAssetData.filter {
                it.isAlgo ||
                    it is BaseAccountAssetData.PendingAssetData ||
                    (it is BaseAccountAssetData.BaseOwnedAssetData && it.amount > BigInteger.ZERO)
            }
        } else {
            accountAssetData
        }
    }

    private suspend fun createNFTListItems(
        accountAddress: String,
        accountNFTData: List<BaseAccountAssetData>,
        query: String,
        onCalculationDone: (BigDecimal, BigDecimal) -> Unit
    ): MutableList<AccountDetailAssetsItem.BaseAssetItem> {
        var primaryNFTsValue = BigDecimal.ZERO
        var secondaryNFTsValue = BigDecimal.ZERO
        val isHoldingByWatchAccount = accountDetailUseCase.getAccountType(accountAddress) == Account.Type.WATCH
        val eliminatedNFTList = eliminateNFTsRegardingByFilteringPreferenceIfNeed(accountNFTData)
        return mutableListOf<AccountDetailAssetsItem.BaseAssetItem>().apply {
            eliminatedNFTList.forEach { accountNftData ->
                (accountNftData as? BaseOwnedCollectibleData)?.let { nftData ->
                    primaryNFTsValue += nftData.parityValueInSelectedCurrency.amountAsCurrency
                    secondaryNFTsValue += nftData.parityValueInSecondaryCurrency.amountAsCurrency
                }
                if (shouldDisplayAsset(accountNftData, query)) {
                    add(
                        createNFTListItem(
                            assetData = accountNftData,
                            isHoldingByWatchAccount = isHoldingByWatchAccount,
                            nftListingViewType = NFTListingViewType.LINEAR_VERTICAL
                        ) ?: return@forEach
                    )
                }
            }
        }.also { onCalculationDone.invoke(primaryNFTsValue, secondaryNFTsValue) }
    }

    private suspend fun eliminateNFTsRegardingByFilteringPreferenceIfNeed(
        accountNFTData: List<BaseAccountAssetData>
    ): List<BaseAccountAssetData> {
        val shouldDisplayNFTInAssetsPreference = shouldDisplayNFTInAssetsPreferenceUseCase()
        val shouldDisplayOptedInNFTInAssetsPreference = shouldDisplayOptedInNFTInAssetsPreferenceUseCase()
        return when {
            shouldDisplayNFTInAssetsPreference && !shouldDisplayOptedInNFTInAssetsPreference -> {
                accountNFTData.filter { it is BaseOwnedCollectibleData && it.isOwnedByTheUser }
            }
            shouldDisplayNFTInAssetsPreference -> accountNFTData
            else -> emptyList()
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

    private fun createRequiredMinimumBalanceItem(
        accountAddress: String
    ): AccountDetailAssetsItem.RequiredMinimumBalanceItem {
        val accountMinimumBalance = getFormattedAccountMinimumBalanceUseCase.getFormattedAccountMinimumBalance(
            accountAddress = accountAddress
        )
        val formattedRequiredMinimumBalance = accountMinimumBalance.formatAsAlgoAmount()
        return accountDetailAssetItemMapper.mapToRequiredMinimumBalanceItem(
            formattedRequiredMinimumBalance = formattedRequiredMinimumBalance
        )
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

    private fun createNFTListItem(
        assetData: BaseAccountAssetData,
        isHoldingByWatchAccount: Boolean,
        nftListingViewType: NFTListingViewType
    ): AccountDetailAssetsItem.BaseAssetItem? {
        return with(accountDetailAssetItemMapper) {
            when (assetData) {
                is BaseOwnedCollectibleData -> {
                    val isOwned = assetData.amount isGreaterThan BigInteger.ZERO
                    val isAmountVisible = assetData.amount isGreaterThan BigInteger.ONE
                    mapToOwnedNFTItem(
                        accountAssetData = assetData,
                        isHoldingByWatchAccount = isHoldingByWatchAccount,
                        isOwned = isOwned,
                        isAmountVisible = isAmountVisible,
                        shouldDecreaseOpacity = !isOwned || isHoldingByWatchAccount,
                        nftListingViewType = nftListingViewType
                    )
                }
                is PendingAdditionCollectibleData -> mapToPendingAdditionNFTITem(assetData)
                is PendingDeletionCollectibleData -> mapToPendingRemovalNFTItem(assetData)
                // TODO: We should use interface instead of using when
                else -> null
            }
        }
    }

    fun canAccountSignTransactions(publicKey: String): Boolean {
        return accountDetailUseCase.canAccountSignTransaction(publicKey)
    }

    companion object {
        const val QUICK_ACTIONS_INDEX = 2
    }
}
