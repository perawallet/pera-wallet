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
import javax.inject.Inject

class PeraIntroductionLocalSource @Inject constructor(
    sharedPreferences: SharedPreferences
) : SharedPrefLocalSource<Boolean>(sharedPreferences) {

    override val key: String
        get() = PERA_INTRODUCTION_PREFERENCE_KEY

    override fun getData(defaultValue: Boolean): Boolean {
        return sharedPref.getBoolean(key, defaultValue)
    }

    override fun getDataOrNull(): Boolean? {
        return if (sharedPref.contains(key)) {
            sharedPref.getBoolean(key, DEFAULT_PERA_INTRODUCTION_PREFERENCE)
        } else {
            null
        }
    }

    override fun saveData(data: Boolean) {
        saveData { it.putBoolean(key, data) }
    }

    companion object {
        const val DEFAULT_PERA_INTRODUCTION_PREFERENCE = false
        private const val PERA_INTRODUCTION_PREFERENCE_KEY = "pera_introduction_preference_key"
    }
}
