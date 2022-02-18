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

package com.algorand.android.ui.wcconnection

import androidx.hilt.lifecycle.ViewModelInject
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCacheData
import com.algorand.android.utils.AccountCacheManager
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow

class WalletConnectConnectionViewModel @ViewModelInject constructor(
    private val accountCacheManager: AccountCacheManager
) : BaseViewModel() {

    val selectedAccountFlow: Flow<AccountCacheData?>
        get() = _selectedAccountFlow
    private val _selectedAccountFlow = MutableStateFlow<AccountCacheData?>(null)

    init {
        initDefaultSelectedAccount()
    }

    fun getSelectedAccount(): AccountCacheData? = _selectedAccountFlow.value

    fun setSelectedAccount(selectedAccount: AccountCacheData) {
        _selectedAccountFlow.value = selectedAccount
    }

    private fun initDefaultSelectedAccount() {
        val cachedAccounts = accountCacheManager.getCachedAccounts(listOf(Account.Type.WATCH))
        if (cachedAccounts.size == 1) {
            _selectedAccountFlow.value = cachedAccounts.first()
        }
    }
}