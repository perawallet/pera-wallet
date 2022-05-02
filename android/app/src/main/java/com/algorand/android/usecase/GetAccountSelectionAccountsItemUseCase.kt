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
 */

package com.algorand.android.usecase

import com.algorand.android.mapper.AccountSelectionListItemMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.formatAsCurrency
import javax.inject.Inject

class GetAccountSelectionAccountsItemUseCase @Inject constructor(
    private val algoPriceUseCase: AlgoPriceUseCase,
    private val splittedAccountsUseCase: SplittedAccountsUseCase,
    private val sortedAccountsUseCase: SortedAccountsUseCase,
    private val accountTotalBalanceUseCase: AccountTotalBalanceUseCase,
    private val accountSelectionListItemMapper: AccountSelectionListItemMapper,
    private val getAccountCollectibleCountUseCase: GetAccountCollectibleCountUseCase
) {

    // TODO: 11.03.2022 Use flow here to get realtime updates
    fun getAccountSelectionAccounts(
        showAssetCount: Boolean,
        showHoldings: Boolean,
        shouldIncludeWatchAccounts: Boolean,
        showFailedAccounts: Boolean,
        assetId: Long? = null,
    ): List<BaseAccountSelectionListItem.BaseAccountItem> {
        val accounts = getRequiredAccounts(shouldIncludeWatchAccounts, assetId)
        val sortedAccounts = getRequiredSortedAccounts(shouldIncludeWatchAccounts)
        val selectedCurrencySymbol = algoPriceUseCase.getSelectedCurrencySymbolOrEmpty()

        return sortedAccounts.map { localAccount ->
            accounts.firstOrNull { cachedAccount ->
                cachedAccount.data?.account?.address == localAccount.address
            }?.data?.run {
                val accountBalance = accountTotalBalanceUseCase.getAccountBalance(this)
                val accountTotalHoldings = with(accountBalance) {
                    algoHoldingsInSelectedCurrency.add(assetHoldingsInSelectedCurrency)
                }
                val collectibleCount = getAccountCollectibleCountUseCase.getAccountCollectibleCount(account.address)
                accountSelectionListItemMapper.mapToAccountItem(
                    publicKey = account.address,
                    name = account.name,
                    accountIcon = account.createAccountIcon(),
                    formattedHoldings = accountTotalHoldings.formatAsCurrency(selectedCurrencySymbol, true),
                    assetCount = accountBalance.assetCount,
                    collectibleCount = collectibleCount,
                    showAssetCount = showAssetCount,
                    showHoldings = showHoldings
                )
            } ?: accountSelectionListItemMapper.mapToErrorAccountItem(localAccount, true)
        }.filter {
            if (showFailedAccounts) true else it !is BaseAccountSelectionListItem.BaseAccountItem.AccountErrorItem
        }
    }

    private fun getRequiredAccounts(
        shouldIncludeWatchAccounts: Boolean,
        assetId: Long?
    ): List<CacheResult<AccountDetail>> {
        val (normalAccounts, watchAccounts) = splittedAccountsUseCase.getWatchAccountSplittedAccountDetails()
        val requiredAccounts = if (shouldIncludeWatchAccounts) {
            normalAccounts + watchAccounts
        } else {
            normalAccounts
        }

        if (assetId == null || assetId == ALGORAND_ID) return requiredAccounts

        return requiredAccounts.filter { accountDetail ->
            accountDetail.data?.accountInformation?.assetHoldingList?.any { assetHolding ->
                assetHolding.assetId == assetId
            } == true
        }
    }

    private fun getRequiredSortedAccounts(shouldIncludeWatchAccounts: Boolean): List<Account> {
        val (sortedNormalLocalAccounts, sortedWatchLocalAccounts) = sortedAccountsUseCase.getSortedLocalAccounts()
        return if (shouldIncludeWatchAccounts) {
            sortedNormalLocalAccounts + sortedWatchLocalAccounts
        } else {
            sortedNormalLocalAccounts
        }
    }
}
