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

package com.algorand.android.modules.asb.backedupaccountssource.data.repository

import com.algorand.android.modules.asb.backedupaccountssource.data.local.BackedUpAccountsLocalSource
import com.algorand.android.modules.asb.backedupaccountssource.domain.repository.BackedUpAccountsRepository
import com.algorand.android.sharedpref.SharedPrefLocalSource

class BackedUpAccountsRepositoryImpl constructor(
    private val backedUpAccountsLocalSource: BackedUpAccountsLocalSource
) : BackedUpAccountsRepository {

    override fun addBackedUpAccountListener(listener: SharedPrefLocalSource.OnChangeListener<Set<String>>) {
        backedUpAccountsLocalSource.addListener(listener)
    }

    override fun removeBackedUpAccountListener(listener: SharedPrefLocalSource.OnChangeListener<Set<String>>) {
        backedUpAccountsLocalSource.removeListener(listener)
    }

    override suspend fun getBackedUpAccounts(): Set<String>? {
        return backedUpAccountsLocalSource.getDataOrNull()
    }

    override suspend fun updateBackedUpAccounts(backedUpAccounts: Set<String>) {
        backedUpAccountsLocalSource.saveData(backedUpAccounts)
    }

    override suspend fun clearBackedUpAccounts() {
        backedUpAccountsLocalSource.clear()
    }
}
