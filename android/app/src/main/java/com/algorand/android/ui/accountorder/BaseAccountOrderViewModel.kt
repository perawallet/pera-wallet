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

package com.algorand.android.ui.accountorder

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.ui.AccountOrderItem
import com.algorand.android.usecase.BaseAccountOrderUseCase
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.launch

abstract class BaseAccountOrderViewModel : BaseViewModel() {

    abstract val accountOrderUseCase: BaseAccountOrderUseCase

    val accountListFlow: Flow<List<AccountOrderItem>>
        get() = accountOrderUseCase.getAccountsFlow()

    fun saveAccounts(accountList: List<AccountOrderItem>) {
        viewModelScope.launch {
            accountOrderUseCase.saveAccountsWithSelectedOrder(accountList)
        }
    }

    fun onAccountItemMoved(fromPosition: Int, toPosition: Int) {
        accountOrderUseCase.swapItemsAndUpdateList(fromPosition, toPosition)
    }
}
