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

import com.algorand.android.ui.common.listhelper.BaseAccountListItem
import javax.inject.Inject

class AccountSelectionPreviewUseCase @Inject constructor(
    private val algoPriceUseCase: AlgoPriceUseCase,
    private val splittedAccountsUseCase: SplittedAccountsUseCase,
    private val sortedAccountsUseCase: SortedAccountsUseCase,
    private val accountListItemsUseCase: AccountListItemsUseCase
) {

    fun getBaseNormalAccountListItems(): List<BaseAccountListItem.BaseAccountItem> {
        val (normalAccounts, watchAccounts) = splittedAccountsUseCase.getWatchAccountSplittedAccountDetails()
        val (sortedNormalLocalAccounts, sortedWatchLocalAccounts) = sortedAccountsUseCase.getSortedLocalAccounts()
        val algoPriceCache = algoPriceUseCase.getCachedAlgoPrice()
        return accountListItemsUseCase.createAccountListItems(
            algoPriceCache,
            normalAccounts,
            sortedNormalLocalAccounts
        )
    }

    fun getBaseNormalAccountListItemsFilteredByAssetId(
        assetId: Long
    ): List<BaseAccountListItem.BaseAccountItem> {
        val (normalAccounts, watchAccounts) = splittedAccountsUseCase.getWatchAccountSplittedAccountDetails()
        val (sortedNormalLocalAccounts, sortedWatchLocalAccounts) = sortedAccountsUseCase.getSortedLocalAccounts()
        val algoPriceCache = algoPriceUseCase.getCachedAlgoPrice()
        val filteredAccountList = normalAccounts.filter { accountDetail ->
            accountDetail.data?.accountInformation?.assetHoldingList?.any { assetHolding ->
                assetHolding.assetId == assetId
            } == true
        }
        return accountListItemsUseCase.createAccountListItems(
            algoPriceCache,
            filteredAccountList,
            sortedNormalLocalAccounts
        )
    }
}
