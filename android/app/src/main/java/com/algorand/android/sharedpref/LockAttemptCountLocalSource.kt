/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.sharedpref

import android.content.SharedPreferences
import javax.inject.Inject

class LockAttemptCountLocalSource @Inject constructor(
    sharedPreferences: SharedPreferences
) : SharedPrefLocalSource<Int>(sharedPreferences) {

    override val key: String
        get() = LOCK_ATTEMPT_COUNT_KEY

    override fun getData(defaultValue: Int): Int {
        return sharedPref.getInt(key, defaultValue)
    }

    override fun getDataOrNull(): Int {
        return sharedPref.getInt(key, defaultLockAttemptCountPreference)
    }

    override fun saveData(data: Int) {
        saveData { it.putInt(key, data) }
    }

    companion object {
        private const val LOCK_ATTEMPT_COUNT_KEY = "lock_attempt_count"
        const val defaultLockAttemptCountPreference = 0
    }
}
