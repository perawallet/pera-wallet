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

package com.algorand.android.modules.asb.backedupaccountssource.domain.usecase

import javax.inject.Inject

class RemoveBackedUpAccountUseCase @Inject constructor(
    private val clearBackedUpAccountsUseCase: ClearBackedUpAccountsUseCase,
    private val getBackedUpAccountsUseCase: GetBackedUpAccountsUseCase,
    private val addBackedUpAccountsUseCase: AddBackedUpAccountsUseCase
) {

    suspend operator fun invoke(removedAccountAddress: String) {
        val backedUpAccountsAddresses = getBackedUpAccountsUseCase.invoke().toMutableSet()
        val isRemovedAccountExist = backedUpAccountsAddresses.remove(removedAccountAddress)
        if (isRemovedAccountExist) {
            clearBackedUpAccountsUseCase.invoke()
            addBackedUpAccountsUseCase.invoke(backedUpAccountsAddresses)
        }
    }
}
