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
import com.algorand.android.models.AccountSelection
import com.algorand.android.usecase.WalletConnectConnectionUseCase
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow

class WalletConnectConnectionViewModel @ViewModelInject constructor(
    private val walletConnectConnectionUseCase: WalletConnectConnectionUseCase
) : BaseViewModel() {

    val selectedAccountFlow: Flow<AccountSelection?>
        get() = _selectedAccountFlow
    private val _selectedAccountFlow = MutableStateFlow<AccountSelection?>(null)

    init {
        initDefaultSelectedAccount()
    }

    fun getSelectedAccount(): AccountSelection? = _selectedAccountFlow.value

    fun setSelectedAccount(accountSelection: AccountSelection) {
        _selectedAccountFlow.value = accountSelection
    }

    private fun initDefaultSelectedAccount() {
        val cachedAccounts = walletConnectConnectionUseCase.getNormalAccounts()
        if (cachedAccounts.size == 1) {
            _selectedAccountFlow.value = cachedAccounts.first()
        }
    }
}
