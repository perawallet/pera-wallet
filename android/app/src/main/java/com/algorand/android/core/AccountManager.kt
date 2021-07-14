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

package com.algorand.android.core

import android.app.NotificationManager
import android.content.Context
import android.content.SharedPreferences
import androidx.lifecycle.MutableLiveData
import com.algorand.android.models.Account
import com.algorand.android.ui.splash.LauncherActivity
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Event
import com.algorand.android.utils.decrpytString
import com.algorand.android.utils.finishAffinityFromFragment
import com.algorand.android.utils.preference.getEncryptedAlgorandAccounts
import com.algorand.android.utils.preference.removeAll
import com.algorand.android.utils.preference.saveAlgorandAccounts
import com.google.crypto.tink.Aead
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import kotlinx.coroutines.flow.MutableStateFlow

// DAGGER
class AccountManager(private val aead: Aead, private val gson: Gson, private val sharedPref: SharedPreferences) {

    val accounts = MutableStateFlow<List<Account>>(listOf())

    val isFirebaseTokenChanged = MutableLiveData<Event<Unit>>()

    private var firebaseMessagingToken: String? = null

    fun initAccounts() {
        val accountJson = aead.decrpytString(sharedPref.getEncryptedAlgorandAccounts())
        accountJson?.let {
            val listType = object : TypeToken<List<Account>>() {}.type
            accounts.value = gson.fromJson<List<Account>>(accountJson, listType)
        }
    }

    fun addNewAccount(newAccount: Account) {
        val sameSavedAccount = getAccounts().find { account -> account.address == newAccount.address }
        if (sameSavedAccount == null) {
            accounts.value = getAccounts() + newAccount
            sharedPref.saveAlgorandAccounts(gson, getAccounts(), aead)
        } else {
            accounts.value = (getAccounts() - sameSavedAccount) + newAccount
            sharedPref.saveAlgorandAccounts(gson, getAccounts(), aead)
        }
    }

    fun getAccount(publicKey: String): Account? {
        getAccounts().forEach { iteratedAccount ->
            if (iteratedAccount.address == publicKey) {
                return iteratedAccount
            }
        }
        return null
    }

    fun removeAccount(publicKey: String?, accountCacheManager: AccountCacheManager) {
        if (publicKey.isNullOrBlank()) {
            return
        }

        getAccounts().forEach { accountFromList ->
            if (publicKey == accountFromList.address) {
                accounts.value = getAccounts().filterNot { account -> account.address == publicKey }
                accountCacheManager.removeCacheData(publicKey)
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

    fun removeAllDataAndStartFromLogin(context: Context?, accountCacheManager: AccountCacheManager) {
        if (context == null) {
            return
        }
        // Cancel all notifications pending.
        (context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager)?.cancelAll()
        accounts.value = listOf()
        sharedPref.removeAll()
        accountCacheManager.removeAllData()
        context.startActivity(LauncherActivity.newIntent(context))
        context.finishAffinityFromFragment()
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

    fun setFirebaseToken(token: String, isRegisterNeeded: Boolean) {
        if (firebaseMessagingToken != token) {
            firebaseMessagingToken = token
            if (isRegisterNeeded) {
                isFirebaseTokenChanged.postValue(Event(Unit))
            }
        }
    }
}
