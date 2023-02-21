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

package com.algorand.android.ui.ledgeraccountselection

import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.usecase.LedgerAccountSelectionUseCase

abstract class LedgerAccountSelectionViewModel constructor(
    private val ledgerAccountSelectionUseCase: LedgerAccountSelectionUseCase
) : BaseViewModel() {

    abstract fun onNewAccountSelected(accountItem: AccountSelectionListItem.AccountItem)

    abstract val accountSelectionList: List<AccountSelectionListItem>

    private val accountSelectionAccountList: List<AccountSelectionListItem.AccountItem>
        get() = accountSelectionList.filterIsInstance<AccountSelectionListItem.AccountItem>()

    val selectedAccounts: List<Account>
        get() = accountSelectionAccountList.filter { it.isSelected }.map { it.account }

    val allAuthAccounts: List<Account>
        get() = accountSelectionAccountList.map { it.account }.filter { it.type == Account.Type.LEDGER }

    fun getAuthAccountOf(
        accountSelectionListItem: AccountSelectionListItem.AccountItem
    ): AccountSelectionListItem.AccountItem? {
        return ledgerAccountSelectionUseCase.getAuthAccountOf(accountSelectionListItem, accountSelectionAccountList)
    }

    fun getRekeyedAccountOf(
        accountSelectionListItem: AccountSelectionListItem.AccountItem
    ): Array<AccountSelectionListItem.AccountItem>? {
        return ledgerAccountSelectionUseCase.getRekeyedAccountOf(accountSelectionListItem, accountSelectionAccountList)
    }
}
