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

package com.algorand.android.modules.asb.backedupaccountssource.data.local

import android.content.SharedPreferences
import com.algorand.android.sharedpref.SharedPrefLocalSource
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class BackedUpAccountsLocalSource @Inject constructor(
    sharedPreferences: SharedPreferences
) : SharedPrefLocalSource<Set<String>>(sharedPreferences) {

    override val key: String
        get() = BACKED_UP_ACCOUNTS_PREFERENCE_KEY

    override fun getData(defaultValue: Set<String>): Set<String> {
        return sharedPref.getStringSet(key, null) ?: emptySet()
    }

    override fun getDataOrNull(): Set<String>? {
        return sharedPref.getStringSet(key, null)
    }

    override fun saveData(data: Set<String>) {
        saveData { it.putStringSet(key, data) }
    }

    companion object {
        private const val BACKED_UP_ACCOUNTS_PREFERENCE_KEY = "backed_up_accounts_list"
    }
}
