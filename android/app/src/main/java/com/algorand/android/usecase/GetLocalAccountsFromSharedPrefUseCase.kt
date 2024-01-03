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

import android.content.SharedPreferences
import com.algorand.android.models.Account
import com.algorand.android.utils.decryptString
import com.algorand.android.utils.fromJson
import com.algorand.android.utils.preference.getEncryptedAlgorandAccounts
import com.google.crypto.tink.Aead
import com.google.gson.Gson
import javax.inject.Inject

class GetLocalAccountsFromSharedPrefUseCase @Inject constructor(
    private val aead: Aead,
    private val gson: Gson,
    private val sharedPref: SharedPreferences
) {
    fun getLocalAccountsFromSharedPref(): List<Account>? {
        val accountJson = aead.decryptString(sharedPref.getEncryptedAlgorandAccounts())
        return accountJson?.let {
            gson.fromJson(accountJson)
        }
    }
}
