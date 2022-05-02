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
 *
 */

package com.algorand.android.ui.accountdetail

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.AccountDetailSummary
import com.algorand.android.models.AccountDetailTab
import com.algorand.android.usecase.AccountDeletionUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.getOrThrow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class AccountDetailViewModel @ViewModelInject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountDeletionUseCase: AccountDeletionUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : ViewModel() {

    val accountPublicKey: String = savedStateHandle.getOrThrow(ACCOUNT_PUBLIC_KEY)
    private val accountDetailTab = savedStateHandle.get<AccountDetailTab?>(ACCOUNT_DETAIL_TAB)

    val accountDetailSummaryFlow: StateFlow<AccountDetailSummary?> get() = _accountDetailSummaryFlow
    private val _accountDetailSummaryFlow = MutableStateFlow<AccountDetailSummary?>(null)

    private val _accountDetailTabArgFlow = MutableStateFlow<Event<Int>?>(null)
    val accountDetailTabArgFlow: StateFlow<Event<Int>?> get() = _accountDetailTabArgFlow

    init {
        initAccountDetailSummary()
        checkAccountDetailTabArg()
    }

    private fun checkAccountDetailTabArg() {
        viewModelScope.launch {
            accountDetailTab?.tabIndex?.run {
                _accountDetailTabArgFlow.emit(Event(this))
            }
        }
    }

    fun removeAccount(publicKey: String) {
        viewModelScope.launch {
            accountDeletionUseCase.removeAccount(publicKey)
        }
    }

    private fun initAccountDetailSummary() {
        viewModelScope.launch {
            _accountDetailSummaryFlow.emit(accountDetailUseCase.getAccountSummary(accountPublicKey))
        }
    }

    companion object {
        private const val ACCOUNT_PUBLIC_KEY = "publicKey"
        private const val ACCOUNT_DETAIL_TAB = "accountDetailTab"
    }
}
