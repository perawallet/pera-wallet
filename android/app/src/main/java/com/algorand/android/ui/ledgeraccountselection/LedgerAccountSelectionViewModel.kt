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

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.usecase.LedgerAccountSelectionUseCase
import com.algorand.android.utils.Resource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class LedgerAccountSelectionViewModel @ViewModelInject constructor(
    private val ledgerAccountSelectionUseCase: LedgerAccountSelectionUseCase
) : BaseViewModel() {

    private val _accountSelectionListLiveData = MutableLiveData<Resource<List<AccountSelectionListItem>>>()
    val accountSelectionListLiveData: LiveData<Resource<List<AccountSelectionListItem>>> = _accountSelectionListLiveData

    private val accountSelectionList: List<AccountSelectionListItem>?
        get() = (accountSelectionListLiveData.value as? Resource.Success)?.data

    private val accountSelectionAccountList: List<AccountSelectionListItem.AccountItem>?
        get() = accountSelectionList?.filterIsInstance<AccountSelectionListItem.AccountItem>()

    val isAccountSelectionListEmpty: Boolean
        get() = accountSelectionList.isNullOrEmpty()

    val selectedCount: Int
        get() = accountSelectionAccountList?.count { it.isSelected } ?: 0

    val selectedAccounts: List<Account>?
        get() = accountSelectionAccountList?.filter { it.isSelected }?.map { it.account }

    val allAuthAccounts: List<Account>?
        get() = accountSelectionAccountList?.map { it.account }?.filter { it.type == Account.Type.LEDGER }

    fun getAccountSelectionListItems(
        ledgerAccountsInformation: Array<AccountInformation>,
        bluetoothAddress: String,
        bluetoothName: String?
    ) {
        viewModelScope.launch(Dispatchers.IO) {
            ledgerAccountSelectionUseCase.getAccountSelectionListItems(
                ledgerAccountsInformation,
                bluetoothAddress,
                bluetoothName,
                this
            ).collectLatest {
                _accountSelectionListLiveData.postValue(it)
            }
        }
    }

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

    fun onNewAccountSelected(accountItem: AccountSelectionListItem.AccountItem, searchType: SearchType) {
        accountSelectionList?.apply {
            filterIsInstance<AccountSelectionListItem.AccountItem>().run {
                if (searchType == SearchType.REKEY) {
                    forEach { it.isSelected = false }
                }
                find {
                    it.account.address == accountItem.account.address
                }?.isSelected = accountItem.isSelected.not()
                _accountSelectionListLiveData.postValue(Resource.Success(this@apply))
            }
        }
    }
}
