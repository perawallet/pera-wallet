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

import com.algorand.android.core.AccountManager
import com.algorand.android.mapper.AccountOrderItemMapper
import com.algorand.android.models.Account
import com.algorand.android.models.ui.AccountOrderItem
import com.algorand.android.utils.toShortenedAddress
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow

abstract class BaseAccountOrderUseCase(
    protected open val accountManager: AccountManager,
    private val accountOrderItemMapper: AccountOrderItemMapper
) {

    protected abstract fun getFilteredAccounts(): List<Account>

    abstract fun saveAccountsWithSelectedOrder(accountOrderList: List<AccountOrderItem>)

    abstract val defaultAccountType: Account.Type

    private val _accountOrderItemFlow = MutableStateFlow<List<AccountOrderItem>>(emptyList())

    fun getAccountsFlow(): SharedFlow<List<AccountOrderItem>> {
        val accountList = getFilteredAccounts().map { it ->
            val displayName = it.name.takeIf { it.isNotBlank() } ?: it.address.toShortenedAddress()
            accountOrderItemMapper.mapToAccountOrderItem(it, displayName, defaultAccountType)
        }
        _accountOrderItemFlow.value = accountList
        return _accountOrderItemFlow
    }

    fun swapItemsAndUpdateList(fromPosition: Int, toPosition: Int) {
        val currentList = _accountOrderItemFlow.value.toMutableList()
        val fromItem = currentList.removeAt(fromPosition)
        currentList.add(toPosition, fromItem)
        _accountOrderItemFlow.value = currentList
    }

    companion object {
        const val NOT_INITIALIZED_ACCOUNT_INDEX = -1
    }
}
