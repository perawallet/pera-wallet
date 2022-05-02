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

package com.algorand.android.core

import android.content.SharedPreferences
import com.algorand.android.models.Account
import com.algorand.android.usecase.StandardAccountOrderUseCase.Companion.STANDARD_ACCOUNT_START_INDEX
import com.algorand.android.usecase.WatchAccountOrderUseCase.Companion.WATCH_ACCOUNT_START_INDEX
import com.algorand.android.utils.AccountMigrationHelper
import com.algorand.android.utils.decrpytString
import com.algorand.android.utils.fromJson
import com.algorand.android.utils.preference.getEncryptedAlgorandAccounts
import com.algorand.android.utils.preference.removeAll
import com.algorand.android.utils.preference.saveAlgorandAccounts
import com.google.crypto.tink.Aead
import com.google.gson.Gson
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

// DAGGER
class AccountManager(
    private val aead: Aead,
    private val gson: Gson,
    private val sharedPref: SharedPreferences,
    private val accountMigrationHelper: AccountMigrationHelper
) {

    val accounts = MutableStateFlow<List<Account>>(listOf())

    private val accountTypeChangeMutex = Mutex()

    fun initAccounts() {
        checkForMigrations()

        val localAccounts = getLocalAccounts()
        if (localAccounts != null) {
            accounts.value = localAccounts
        }
    }

    fun addNewAccount(newAccount: Account) {
        val sameSavedAccount = getAccounts().find { account -> account.address == newAccount.address }
        val indexedNewAccount = getIndexedAccount(newAccount)
        if (sameSavedAccount == null) {
            accounts.value = getAccounts() + indexedNewAccount
            sharedPref.saveAlgorandAccounts(gson, getAccounts(), aead)
        } else {
            accounts.value = (getAccounts() - sameSavedAccount) + indexedNewAccount
            sharedPref.saveAlgorandAccounts(gson, getAccounts(), aead)
        }
    }

    fun saveAccounts(accountList: List<Account>) {
        sharedPref.saveAlgorandAccounts(gson, accountList, aead)
        accounts.value = accountList
    }

    fun getAccount(publicKey: String): Account? {
        getAccounts().forEach { iteratedAccount ->
            if (iteratedAccount.address == publicKey) {
                return iteratedAccount
            }
        }
        return null
    }

    fun removeAccount(publicKey: String?) {
        if (publicKey.isNullOrBlank()) {
            return
        }

        getAccounts().forEach { accountFromList ->
            if (publicKey == accountFromList.address) {
                accounts.value = getAccounts().filterNot { account -> account.address == publicKey }
                sharedPref.saveAlgorandAccounts(gson, getAccounts(), aead)
            }
        }
    }

    fun changeAccountName(accountPublicKey: String?, newAccountName: String) {
        if (accountPublicKey.isNullOrBlank()) {
            return
        }

        getAccounts().forEach { accountFromList ->
            if (accountFromList.address == accountPublicKey) {
                accountFromList.name = newAccountName
                sharedPref.saveAlgorandAccounts(gson, getAccounts(), aead)
                return
            }
        }
    }

    suspend fun changeAccountType(accountPublicKey: String, newType: Account.Type) {
        accountTypeChangeMutex.withLock {
            val updatedAccountList = getAccounts().map { accountFromList ->
                if (accountFromList.address == accountPublicKey) {
                    accountFromList.copy(type = newType)
                } else {
                    accountFromList
                }
            }
            sharedPref.saveAlgorandAccounts(gson, updatedAccountList, aead)
        }
    }

    fun removeAllData() {
        accounts.value = listOf()
        sharedPref.removeAll()
    }

    fun isThereAnyAccountWithPublicKey(publicKey: String?): Boolean {
        return publicKey != null && getAccount(publicKey) != null
    }

    fun isThereAnyRegisteredAccount(): Boolean {
        return getAccounts().isEmpty().not()
    }

    fun getAccounts(): List<Account> {
        return accounts.value
    }

    private fun getIndexedAccount(account: Account): Account {
        return account.copy(
            index = if (account.type == Account.Type.WATCH) {
                getAccounts().filter { it.type == Account.Type.WATCH }.size + WATCH_ACCOUNT_START_INDEX
            } else {
                getAccounts().filterNot { it.type == Account.Type.WATCH }.size + STANDARD_ACCOUNT_START_INDEX
            }
        )
    }

    private fun checkForMigrations() {
        val localAccounts = getLocalAccounts() ?: return
        if (accountMigrationHelper.isMigrationNeed(localAccounts)) {
            val migratedAccountList = accountMigrationHelper.migrateAccounts(localAccounts)
            sharedPref.saveAlgorandAccounts(gson, migratedAccountList, aead)
        }
    }

    private fun getLocalAccounts(): List<Account>? {
        val accountJson = aead.decrpytString(sharedPref.getEncryptedAlgorandAccounts())
        return accountJson?.let {
            gson.fromJson(accountJson)
        }
    }
}
