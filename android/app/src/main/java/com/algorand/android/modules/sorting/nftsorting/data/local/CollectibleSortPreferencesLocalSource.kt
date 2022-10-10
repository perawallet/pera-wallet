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

package com.algorand.android.modules.sorting.nftsorting.data.local

import android.content.SharedPreferences
import com.algorand.android.sharedpref.SharedPrefLocalSource
import javax.inject.Inject

class CollectibleSortPreferencesLocalSource @Inject constructor(
    sharedPreferences: SharedPreferences
) : SharedPrefLocalSource<String>(sharedPreferences) {

    override val key: String
        get() = COLLECTIBLE_SORT_PREFERENCE_KEY

    override fun getData(defaultValue: String): String {
        return sharedPref.getString(key, defaultValue) ?: defaultValue
    }

    override fun getDataOrNull(): String? {
        return sharedPref.getString(key, null)
    }

    override fun saveData(data: String) {
        saveData { it.putString(key, data) }
    }

    companion object {
        private const val COLLECTIBLE_SORT_PREFERENCE_KEY = "collectible_sort_preference"
    }
}
