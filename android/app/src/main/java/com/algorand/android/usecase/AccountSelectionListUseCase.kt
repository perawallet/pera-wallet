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

import com.algorand.android.models.Account
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.modules.nftdomain.ui.usecase.GetAccountSelectionNftDomainItemsUseCase
import javax.inject.Inject

class AccountSelectionListUseCase @Inject constructor(
    private val getAccountSelectionAccountsItemUseCase: GetAccountSelectionAccountsItemUseCase,
    private val getAccountSelectionContactsItemUseCase: GetAccountSelectionContactsItemUseCase,
    private val getAccountSelectionNftDomainItemsUseCase: GetAccountSelectionNftDomainItemsUseCase,
    private val createAccountSelectionAccountItemUseCase: CreateAccountSelectionAccountItemUseCase
) {
    suspend fun createAccountSelectionListAccountItems(
        showHoldings: Boolean,
        showFailedAccounts: Boolean
    ): List<BaseAccountSelectionListItem.BaseAccountItem> {
        return getAccountSelectionAccountsItemUseCase.getAccountSelectionAccounts(
            showHoldings = showHoldings,
            showFailedAccounts = showFailedAccounts,
        )
    }

    suspend fun createAccountSelectionListAccountItemsWhichNotBackedUp(
        showHoldings: Boolean,
        showFailedAccounts: Boolean
    ): List<BaseAccountSelectionListItem.BaseAccountItem> {
        return getAccountSelectionAccountsItemUseCase.getAccountSelectionAccountsWhichNotBackedUp(
            showHoldings = showHoldings,
            showFailedAccounts = showFailedAccounts
        )
    }

    suspend fun createAccountSelectionListAccountItemsWhichCanSignTransaction(
        showHoldings: Boolean,
        showFailedAccounts: Boolean,
        excludedAccountTypes: List<Account.Type>? = null
    ): List<BaseAccountSelectionListItem.BaseAccountItem> {
        return getAccountSelectionAccountsItemUseCase.getAccountSelectionAccountsWhichCanSignTransaction(
            showHoldings = showHoldings,
            showFailedAccounts = showFailedAccounts,
            excludedAccountTypes = excludedAccountTypes
        )
    }

    suspend fun createAccountSelectionListAccountItemsFilteredByAssetId(
        assetId: Long,
        showHoldings: Boolean,
        showFailedAccounts: Boolean
    ): List<BaseAccountSelectionListItem.BaseAccountItem> {
        return getAccountSelectionAccountsItemUseCase.getAccountSelectionAccounts(
            assetId = assetId,
            showHoldings = showHoldings,
            showFailedAccounts = showFailedAccounts,
        )
    }

    suspend fun createAccountSelectionListAccountItemsFilteredByAssetIdWhichCanSignTransaction(
        assetId: Long,
        showHoldings: Boolean,
        showFailedAccounts: Boolean
    ): List<BaseAccountSelectionListItem.BaseAccountItem> {
        return getAccountSelectionAccountsItemUseCase.getAccountSelectionAccountsWhichCanSignTransaction(
            assetId = assetId,
            showHoldings = showHoldings,
            showFailedAccounts = showFailedAccounts,
        )
    }

    suspend fun createAccountSelectionListContactItems(): List<BaseAccountSelectionListItem.BaseAccountItem> {
        return getAccountSelectionContactsItemUseCase.getAccountSelectionContacts()
    }

    suspend fun createAccountSelectionNftDomainItems(
        query: String
    ): List<BaseAccountSelectionListItem.BaseAccountItem> {
        return getAccountSelectionNftDomainItemsUseCase.getAccountSelectionNftDomainAccounts(query)
    }

    fun createAccountSelectionItemFromAccountAddress(
        accountAddress: String?
    ): BaseAccountSelectionListItem.BaseAccountItem.AccountItem? {
        if (accountAddress.isNullOrBlank()) return null
        return createAccountSelectionAccountItemUseCase.createAccountSelectionAccountItemFromAccountAddress(
            accountAddress
        )
    }
}
