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

package com.algorand.android.ui.register.nameregistration

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import com.algorand.android.models.AccountCreation
import com.algorand.android.usecase.NameRegistrationUseCase
import com.algorand.android.utils.getOrThrow

class NameRegistrationViewModel @ViewModelInject constructor(
    @Assisted savedStateHandle: SavedStateHandle,
    private val nameRegistrationUseCase: NameRegistrationUseCase
) : ViewModel() {

    val accountPublicKey = savedStateHandle.getOrThrow<AccountCreation>(ACCOUNT_CREATION_KEY).tempAccount.address

    fun isThereAnyAccountWithThisPublicKey(publicKey: String): Boolean {
        return nameRegistrationUseCase.isThereAnyAccountWithThisPublicKey(publicKey)
    }

    companion object {
        private const val ACCOUNT_CREATION_KEY = "accountCreation"
    }
}
