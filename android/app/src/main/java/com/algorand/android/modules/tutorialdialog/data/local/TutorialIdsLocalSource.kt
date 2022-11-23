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

package com.algorand.android.modules.tutorialdialog.data.local

import android.content.SharedPreferences
import com.algorand.android.sharedpref.SharedPrefLocalSource
import com.algorand.android.utils.fromJson
import com.google.gson.Gson
import javax.inject.Inject

class TutorialIdsLocalSource @Inject constructor(
    private val gson: Gson,
    sharedPreferences: SharedPreferences
) : SharedPrefLocalSource<List<Int>>(sharedPreferences) {

    override val key: String = TUTORIAL_IDS_KEY

    override fun getData(defaultValue: List<Int>): List<Int> {
        val defaultList = gson.toJson(defaultValue)
        return getParsedData(defaultList).orEmpty()
    }

    override fun getDataOrNull(): List<Int>? {
        return getParsedData(null)
    }

    override fun saveData(data: List<Int>) {
        val previousList = getDataOrNull().orEmpty()
        val currentList = (previousList + data).toSet()
        saveData { it.putString(key, gson.toJson(currentList)) }
    }

    private fun getParsedData(defaultValue: String?): List<Int>? {
        return gson.fromJson<List<Int>>(sharedPref.getString(key, defaultValue).orEmpty())
    }

    companion object {
        private const val TUTORIAL_IDS_KEY = "tutorialIds"
    }
}
