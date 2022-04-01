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

package com.algorand.android.banner.data.cache

import android.content.SharedPreferences
import com.algorand.android.sharedpref.SharedPrefLocalSource
import com.algorand.android.utils.fromJson
import com.google.gson.Gson
import javax.inject.Inject

class BannerIdsLocalSource @Inject constructor(
    sharedPreferences: SharedPreferences,
    private val gson: Gson
) : SharedPrefLocalSource<List<Long>>(sharedPreferences) {

    override val key: String = BANNER_ID_LIST_SHARED_PREF_KEY

    override fun saveData(data: List<Long>) {
        val previousList = getDataOrNull().orEmpty()
        val newList = (previousList + data).toSet()
        saveData { it.putString(key, gson.toJson(newList)) }
    }

    override fun getDataOrNull(): List<Long>? {
        return getParsedData()
    }

    override fun getData(defaultValue: List<Long>): List<Long> {
        val defaultList = gson.toJson(defaultValue)
        return getParsedData(defaultList).orEmpty()
    }

    private fun getParsedData(defaultValue: String? = null): List<Long>? {
        return gson.fromJson<List<Long>>(sharedPref.getString(key, defaultValue).orEmpty())
    }

    companion object {
        private const val BANNER_ID_LIST_SHARED_PREF_KEY = "banner_id_list"
    }
}
