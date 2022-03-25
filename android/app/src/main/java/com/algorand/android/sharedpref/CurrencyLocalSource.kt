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

package com.algorand.android.sharedpref

import android.content.SharedPreferences
import com.algorand.android.models.Currency
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class CurrencyLocalSource @Inject constructor(
    sharedPref: SharedPreferences
) : SharedPrefLocalSource<String>(sharedPref) {

    override val key: String
        get() = CURRENCY_PREFERENCE_KEY

    override fun getData(defaultValue: String): String {
        return sharedPref.getString(key, defaultValue) ?: defaultValue
    }

    override fun saveData(data: String) {
        saveData { it.putString(key, data) }
    }

    override fun getDataOrNull(): String? {
        return sharedPref.getString(key, null)
    }

    companion object {
        val defaultCurrencyPreference = Currency.ALGO.id
        private const val CURRENCY_PREFERENCE_KEY = "currency_preference_key"
    }
}
