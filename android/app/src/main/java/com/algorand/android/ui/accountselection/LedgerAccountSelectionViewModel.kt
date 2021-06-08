/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.accountselection

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.R
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.repository.AccountRepository
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Resource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class LedgerAccountSelectionViewModel @ViewModelInject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val accountRepository: AccountRepository
) : BaseViewModel() {

    val accountSelectionListLiveData = MutableLiveData<Resource<List<AccountSelectionListItem>>>()

    fun getAccountSelectionListItems(
        ledgerAccountsInformation: Array<AccountInformation>,
        bluetoothAddress: String,
        bluetoothName: String?
    ) {
        viewModelScope.launch(Dispatchers.IO) {
            accountSelectionListLiveData.postValue(Resource.Loading)
            val result = mutableListOf<AccountSelectionListItem>()
            for ((index, ledgerAccountInformation) in ledgerAccountsInformation.withIndex()) {
                val authImageResource: Int = if (ledgerAccountInformation.isRekeyed()) {
                    R.drawable.ic_rekeyed_ledger
                } else {
                    R.drawable.ic_ledger_vectorized
                }
                val authAccountDetail = Account.Detail.Ledger(bluetoothAddress, bluetoothName, index)
                val authAccountSelectionListItem = AccountSelectionListItem.create(
                    accountInformation = ledgerAccountInformation,
                    accountDetail = authAccountDetail,
                    accountCacheManager = accountCacheManager,
                    accountImageResource = authImageResource
                )
                result.add(authAccountSelectionListItem)
                val rekeyedAccountSelectionListItems = getRekeyedAccountsOfAuthAccount(
                    ledgerAccountInformation.address, authAccountDetail
                )
                result.addAll(rekeyedAccountSelectionListItems)
            }
            accountSelectionListLiveData.postValue(Resource.Success(result))
        }
    }

    private suspend fun getRekeyedAccountsOfAuthAccount(
        rekeyAdminAddress: String,
        ledgerDetail: Account.Detail.Ledger,
    ): List<AccountSelectionListItem> {
        val deferredAccountSelectionListItems = mutableListOf<AccountSelectionListItem>()
        accountRepository.getRekeyedAccounts(rekeyAdminAddress).use(
            onSuccess = { rekeyedAccountsList ->
                deferredAccountSelectionListItems.addAll(
                    rekeyedAccountsList.filterNot { it.address == rekeyAdminAddress }.map { accountInformation ->
                        val detail = Account.Detail.RekeyedAuth.create(null, mapOf(rekeyAdminAddress to ledgerDetail))
                        AccountSelectionListItem.create(
                            accountInformation = accountInformation,
                            accountDetail = detail,
                            accountCacheManager = accountCacheManager,
                            accountImageResource = R.drawable.ic_rekeyed_ledger
                        )
                    }
                )
            }
        )
        return deferredAccountSelectionListItems
    }

    fun getAuthAccountOf(accountSelectionListItem: AccountSelectionListItem): AccountSelectionListItem? {
        return (accountSelectionListLiveData.value as? Resource.Success)?.data?.run {
            if (accountSelectionListItem.accountInformation.isRekeyed()) {
                val rekeyAdminAddress = accountSelectionListItem.accountInformation.rekeyAdminAddress
                this.firstOrNull { rekeyAdminAddress == it.account.address }
            } else {
                null
            }
        }
    }

    fun getRekeyedAccountOf(accountSelectionListItem: AccountSelectionListItem): Array<AccountSelectionListItem>? {
        val accountAddress = accountSelectionListItem.account.address
        return (accountSelectionListLiveData.value as? Resource.Success)?.data?.run {
            this.filter {
                it.account.address != accountAddress && it.accountInformation.rekeyAdminAddress == accountAddress
            }.toTypedArray()
        }
    }
}
