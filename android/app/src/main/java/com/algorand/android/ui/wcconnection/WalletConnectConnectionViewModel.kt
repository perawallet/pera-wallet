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

package com.algorand.android.ui.wcconnection

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCacheData
import com.algorand.android.utils.AccountCacheManager

class WalletConnectConnectionViewModel @ViewModelInject constructor(
    private val accountCacheManager: AccountCacheManager
) : BaseViewModel() {

    val accountLiveData: LiveData<AccountCacheData?>
        get() = _accountLiveData
    private val _accountLiveData = MutableLiveData<AccountCacheData?>()

    init {
        initDefaultAccount()
    }

    private fun initDefaultAccount() {
        _accountLiveData.value = getFilteredAccounts()
    }

    private fun getFilteredAccounts(): AccountCacheData? {
        return accountCacheManager.accountCacheMap.value.values.firstOrNull {
            it.account.type != Account.Type.WATCH
        }
    }
}
