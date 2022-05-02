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

import com.algorand.android.R
import com.algorand.android.banner.domain.model.BaseBanner
import com.algorand.android.banner.domain.model.BaseBanner.GenericBanner
import com.algorand.android.banner.domain.model.BaseBanner.GovernanceBanner
import com.algorand.android.banner.domain.usecase.BannersUseCase
import com.algorand.android.banner.ui.mapper.BaseBannerItemMapper
import com.algorand.android.core.AccountManager
import com.algorand.android.mapper.AccountListItemMapper
import com.algorand.android.mapper.AccountPreviewMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountBalance
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.CurrencyValue
import com.algorand.android.models.ui.AccountPreview
import com.algorand.android.nft.domain.usecase.SimpleCollectibleUseCase
import com.algorand.android.ui.common.listhelper.BaseAccountListItem
import com.algorand.android.ui.common.listhelper.BaseAccountListItem.HeaderItem
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.formatAsCurrency
import java.math.BigDecimal
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.withContext

// TODO Refactor this class for performance and code quality
@Suppress("LongParameterList")
class AccountsPreviewUseCase @Inject constructor(
    private val algoPriceUseCase: AlgoPriceUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val assetDetailUseCase: SimpleAssetDetailUseCase,
    private val accountManager: AccountManager,
    private val accountPreviewMapper: AccountPreviewMapper,
    private val accountListItemMapper: AccountListItemMapper,
    private val sortedAccountsUseCase: SortedAccountsUseCase,
    private val splittedAccountsUseCase: SplittedAccountsUseCase,
    private val accountListItemsUseCase: AccountListItemsUseCase,
    private val simpleCollectibleUseCase: SimpleCollectibleUseCase,
    private val bannersUseCase: BannersUseCase,
    private val baseBannerItemMapper: BaseBannerItemMapper
) {

    fun getInitialAccountPreview() = accountPreviewMapper.getFullScreenLoadingState()

    suspend fun getAccountsPreview(previousState: AccountPreview): Flow<AccountPreview> {
        return combine(
            algoPriceUseCase.getAlgoPriceCacheFlow(),
            accountDetailUseCase.getAccountDetailCacheFlow(),
            bannersUseCase.getBanners(),
            assetDetailUseCase.getCachedAssetsFlow()
        ) { algoPriceCache, accountDetailCache, banners, _ ->
            val localAccounts = accountManager.getAccounts()
            if (localAccounts.isEmpty()) {
                return@combine accountPreviewMapper.getEmptyAccountListState()
            }
            when (algoPriceCache) {
                is CacheResult.Success -> {
                    processAccountsAndAssets(accountDetailCache, localAccounts, banners)
                }
                is CacheResult.Error -> getAlgoPriceErrorState(algoPriceCache, previousState)
                else -> accountPreviewMapper.getFullScreenLoadingState()
            }
        }
    }

    suspend fun onCloseBannerClick(bannerId: Long) {
        bannersUseCase.dismissBanner(bannerId)
    }

    private fun getAlgoPriceErrorState(
        algoPriceCache: CacheResult.Error<CurrencyValue>?,
        previousState: AccountPreview
    ): AccountPreview {
        val hasPreviousCachedValue = algoPriceCache?.data != null
        if (hasPreviousCachedValue) return previousState
        val accountErrorListItems = createAccountErrorItemList()
        return accountPreviewMapper.getAlgoPriceInitialErrorState(accountErrorListItems, algoPriceCache?.code)
    }

    private suspend fun processAccountsAndAssets(
        accountDetailCache: HashMap<String, CacheResult<AccountDetail>>,
        localAccounts: List<Account>,
        banners: List<BaseBanner>
    ): AccountPreview {
        val areAllAccountsAreCached = accountDetailUseCase.areAllAccountsCached()
        return if (areAllAccountsAreCached) {
            processSuccessAccountCacheAndOthers(accountDetailCache, localAccounts, banners)
        } else {
            accountPreviewMapper.getFullScreenLoadingState()
        }
    }

    private suspend fun processSuccessAccountCacheAndOthers(
        accountDetailCache: HashMap<String, CacheResult<AccountDetail>>,
        localAccounts: List<Account>,
        banners: List<BaseBanner>
    ): AccountPreview {
        val isThereAnyAssetNeedsToBeCached = accountDetailCache.values.any {
            !it.data?.accountInformation?.assetHoldingList.isNullOrEmpty()
        }
        return if (
            assetDetailUseCase.getCachedAssetList().isEmpty() &&
            simpleCollectibleUseCase.getCachedCollectibleList().isEmpty() &&
            isThereAnyAssetNeedsToBeCached
        ) {
            accountPreviewMapper.getFullScreenLoadingState()
        } else {
            prepareAccountPreview(accountDetailCache, localAccounts, banners)
        }
    }

    private suspend fun prepareAccountPreview(
        accountDetailCache: HashMap<String, CacheResult<AccountDetail>>,
        localAccounts: List<Account>,
        banners: List<BaseBanner>
    ): AccountPreview {
        return withContext(Dispatchers.Default) {
            var algoHoldings = BigDecimal.ZERO
            var assetHoldings = BigDecimal.ZERO

            val selectedCurrencySymbol = algoPriceUseCase.getSelectedCurrencySymbolOrEmpty()

            val baseAccountListItems = getBaseAccountListItems(accountDetailCache, localAccounts) {
                algoHoldings += it.algoHoldingsInSelectedCurrency
                assetHoldings += it.assetHoldingsInSelectedCurrency
            }.apply {
                val isThereAnyErrorInAccountCache = accountDetailCache.any {
                    it.value is CacheResult.Error<*> && it.value.data == null
                }
                val portfolioValueItem = if (isThereAnyErrorInAccountCache) {
                    accountListItemMapper.mapToPortfolioValuesPartialErrorItem()
                } else {
                    getPortfolioItem(algoHoldings, assetHoldings, selectedCurrencySymbol)
                }
                add(PORTFOLIO_VALUES_ITEM_INDEX, portfolioValueItem)
                val banner = getBannerItemOrNull(banners)
                if (banner != null) add(BANNER_ITEM_INDEX, banner)
                insertMoonpayBuyAlgoButton(banner != null, this)
            }
            accountPreviewMapper.getSuccessAccountPreview(baseAccountListItems)
        }
    }

    private fun insertMoonpayBuyAlgoButton(hasBanner: Boolean, accountsList: MutableList<BaseAccountListItem>) {
        val buyAlgoItemIndex = if (hasBanner) MOONPAY_BUY_ALGO_ITEM_INDEX else MOONPAY_BUY_ALGO_ITEM_INDEX - 1
        accountsList.add(buyAlgoItemIndex, BaseAccountListItem.MoonpayBuyAlgoItem)
    }

    private fun getBannerItemOrNull(bannerList: List<BaseBanner>): BaseAccountListItem.BaseBannerItem? {
        return bannerList.firstOrNull()?.let { banner ->
            val isButtonVisible = !banner.buttonTitle.isNullOrBlank() && !banner.buttonUrl.isNullOrBlank()
            val isTitleVisible = !banner.title.isNullOrBlank()
            val isDescriptionVisible = !banner.description.isNullOrBlank()
            with(baseBannerItemMapper) {
                when (banner) {
                    is GovernanceBanner -> {
                        mapToGovernanceBannerItem(banner, isButtonVisible, isTitleVisible, isDescriptionVisible)
                    }
                    is GenericBanner -> {
                        mapToGenericBannerItem(banner, isButtonVisible, isTitleVisible, isDescriptionVisible)
                    }
                }
            }
        }
    }

    private fun getBaseAccountListItems(
        accountDetailCache: HashMap<String, CacheResult<AccountDetail>>,
        localAccounts: List<Account>,
        onAccountBalanceCalculated: (AccountBalance) -> Unit
    ): MutableList<BaseAccountListItem> {

        val (normalAccounts, watchAccounts) = splittedAccountsUseCase
            .getWatchAccountSplittedAccountDetails(accountDetailCache.values)

        val (sortedNormalLocalAccounts, sortedWatchLocalAccounts) = sortedAccountsUseCase
            .getSortedLocalAccounts(localAccounts)

        val normalAccountListItems = accountListItemsUseCase.createAccountListItems(
            normalAccounts,
            sortedNormalLocalAccounts,
            onAccountBalanceCalculated
        )
        val watchAccountListItems = accountListItemsUseCase.createAccountListItems(
            watchAccounts,
            sortedWatchLocalAccounts
        )

        return mutableListOf<BaseAccountListItem>().apply {
            if (normalAccountListItems.isNotEmpty()) {
                add(HeaderItem(R.string.accounts, false))
                addAll(normalAccountListItems)
            }
            if (watchAccountListItems.isNotEmpty()) {
                add(HeaderItem(R.string.watch_account, true))
                addAll(watchAccountListItems)
            }
        }
    }

    private fun getPortfolioItem(
        algoHoldings: BigDecimal,
        assetHoldings: BigDecimal,
        symbol: String
    ): BaseAccountListItem.BasePortfolioValueItem.PortfolioValuesItem {
        val totalHoldings = algoHoldings.add(assetHoldings)
        return accountListItemMapper.mapToPortfolioValuesSuccessItem(
            totalHoldings.formatAsCurrency(symbol),
            algoHoldings.formatAsCurrency(symbol),
            assetHoldings.formatAsCurrency(symbol)
        )
    }

    private fun createAccountErrorItemList(): List<BaseAccountListItem> {
        val (normalAccounts, watchAccounts) = accountManager.getAccounts().partition {
            it.type != Account.Type.WATCH
        }
        return mutableListOf<BaseAccountListItem>().apply {
            add(accountListItemMapper.mapToPortfolioValuesInitializationErrorItem())
            if (normalAccounts.isNotEmpty()) {
                add(HeaderItem(R.string.accounts, false))
                val normalAccountErrorListItems = normalAccounts.map { account ->
                    accountListItemMapper.mapToErrorAccountItem(account, true)
                }
                addAll(normalAccountErrorListItems)
            }
            if (watchAccounts.isNotEmpty()) {
                add(HeaderItem(R.string.watch_account, true))
                val watchAccountErrorListItems = watchAccounts.map { account ->
                    accountListItemMapper.mapToErrorAccountItem(account, true)
                }
                addAll(watchAccountErrorListItems)
            }
        }
    }

    companion object {
        private const val PORTFOLIO_VALUES_ITEM_INDEX = 0
        private const val BANNER_ITEM_INDEX = 1
        private const val MOONPAY_BUY_ALGO_ITEM_INDEX = 2
    }
}
