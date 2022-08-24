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

package com.algorand.android.ui.accounts

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.decider.TransactionUserUseCase
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.TransactionTargetUser
import com.algorand.android.models.User
import com.algorand.android.utils.getOrElse
import com.algorand.android.utils.getOrThrow
import kotlinx.coroutines.launch

class AccountsAddressScanActionViewModel @ViewModelInject constructor(
    private val transactionUserUseCase: TransactionUserUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val accountAddress = savedStateHandle.getOrThrow<String>(ACCOUNT_ADDRESS_KEY)
    private val label: String? = savedStateHandle.getOrElse<String?>(LABEL_KEY, null)
    private var transactionTargetUser: TransactionTargetUser = getInitialTargetUser()

    init {
        initTransactionTargetUser()
    }

    fun getAccountAddress(): String = accountAddress

    fun getLabel(): String? = label

    fun getAssetTransactionArg(): AssetTransaction {
        return AssetTransaction(
            receiverUser = User(
                name = transactionTargetUser.displayName,
                publicKey = accountAddress,
                imageUriAsString = null
            )
        )
    }

    private fun initTransactionTargetUser() {
        viewModelScope.launch {
            transactionTargetUser = transactionUserUseCase.getTransactionTargetUser(accountAddress)
        }
    }

    private fun getInitialTargetUser(): TransactionTargetUser {
        return TransactionTargetUser(publicKey = accountAddress, displayName = accountAddress)
    }

    companion object {
        private const val ACCOUNT_ADDRESS_KEY = "accountAddress"
        private const val LABEL_KEY = "label"
    }
}
