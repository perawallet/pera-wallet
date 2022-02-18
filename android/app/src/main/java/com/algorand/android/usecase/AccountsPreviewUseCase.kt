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
import com.algorand.android.core.AccountManager
import com.algorand.android.mapper.AccountListItemMapper
import com.algorand.android.mapper.AccountPreviewMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountBalance
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.CurrencyValue
import com.algorand.android.models.ui.AccountPreview
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
class AccountsPreviewUseCase @Inject constructor(
    private val algoPriceUseCase: AlgoPriceUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val assetDetailUseCase: SimpleAssetDetailUseCase,
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val accountManager: AccountManager,
    private val accountPreviewMapper: AccountPreviewMapper,
    private val accountListItemMapper: AccountListItemMapper,
    private val sortedAccountsUseCase: SortedAccountsUseCase,
    private val splittedAccountsUseCase: SplittedAccountsUseCase,
    private val accountListItemsUseCase: AccountListItemsUseCase
) {

    fun getInitialAccountPreview() = accountPreviewMapper.getFullScreenLoadingState()

    suspend fun getAccountsPreview(previousState: AccountPreview): Flow<AccountPreview> {
        return combine(
            algoPriceUseCase.getAlgoPriceCacheFlow(),
            accountDetailUseCase.getAccountDetailCacheFlow(),
            assetDetailUseCase.getCachedAssetsFlow()
        ) { algoPriceCache, accountDetailCache, _ ->
            val localAccounts = accountManager.getAccounts()
            if (localAccounts.isEmpty()) {
                return@combine accountPreviewMapper.getEmptyAccountListState()
            }
            when (algoPriceCache) {
                is CacheResult.Success -> {
                    processAccountsAndAssets(algoPriceCache, accountDetailCache, localAccounts)
                }
                is CacheResult.Error -> getAlgoPriceErrorState(algoPriceCache, previousState)
                else -> accountPreviewMapper.getFullScreenLoadingState()
            }
        }
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
        algoPriceCache: CacheResult.Success<CurrencyValue>,
        accountDetailCache: HashMap<String, CacheResult<AccountDetail>>,
        localAccounts: List<Account>
    ): AccountPreview {
        val areAllAccountsAreCached = accountDetailUseCase.areAllAccountsCached()
        return if (areAllAccountsAreCached) {
            processSuccessAccountCacheAndOthers(algoPriceCache, accountDetailCache, localAccounts)
        } else {
            accountPreviewMapper.getFullScreenLoadingState()
        }
    }

    private suspend fun processSuccessAccountCacheAndOthers(
        algoPriceCache: CacheResult.Success<CurrencyValue>,
        accountDetailCache: HashMap<String, CacheResult<AccountDetail>>,
        localAccounts: List<Account>
    ): AccountPreview {
        val isThereAnyAssetNeedsToBeCached = accountDetailCache.values.any {
            !it.data?.accountInformation?.assetHoldingList.isNullOrEmpty()
        }
        return if (assetDetailUseCase.getCachedAssetList().isEmpty() && isThereAnyAssetNeedsToBeCached) {
            accountPreviewMapper.getFullScreenLoadingState()
        } else {
            prepareAccountPreview(algoPriceCache, accountDetailCache, localAccounts)
        }
    }

    private suspend fun prepareAccountPreview(
        algoPriceCache: CacheResult.Success<CurrencyValue>,
        accountDetailCache: HashMap<String, CacheResult<AccountDetail>>,
        localAccounts: List<Account>
    ): AccountPreview {
        return withContext(Dispatchers.Default) {
            var algoHoldings = BigDecimal.ZERO
            var assetHoldings = BigDecimal.ZERO

            val selectedCurrencySymbol = algoPriceCache.data.symbol.orEmpty()

            val baseAccountListItems = getBaseAccountListItems(algoPriceCache, accountDetailCache, localAccounts) {
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
            }
            accountPreviewMapper.getSuccessAccountPreview(baseAccountListItems)
        }
    }

    private fun getBaseAccountListItems(
        algoPriceCache: CacheResult.Success<CurrencyValue>,
        accountDetailCache: HashMap<String, CacheResult<AccountDetail>>,
        localAccounts: List<Account>,
        onAccountBalanceCalculated: (AccountBalance) -> Unit
    ): MutableList<BaseAccountListItem> {

        val (normalAccounts, watchAccounts) = splittedAccountsUseCase
            .getWatchAccountSplittedAccountDetails(accountDetailCache.values)

        val (sortedNormalLocalAccounts, sortedWatchLocalAccounts) = sortedAccountsUseCase
            .getSortedLocalAccounts(localAccounts)

        val normalAccountListItems = accountListItemsUseCase.createAccountListItems(
            algoPriceCache,
            normalAccounts,
            sortedNormalLocalAccounts,
            onAccountBalanceCalculated
        )
        val watchAccountListItems = accountListItemsUseCase.createAccountListItems(
            algoPriceCache,
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
    }
}
