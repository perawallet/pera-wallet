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

package com.algorand.android.deviceregistration.data.localsource

import android.content.SharedPreferences
import com.algorand.android.sharedpref.SharedPrefLocalSource
import javax.inject.Inject

class TestnetDeviceIdLocalSource @Inject constructor(
    sharedPreferences: SharedPreferences
) : SharedPrefLocalSource<String?>(sharedPreferences) {

    override val key: String = TESTNET_DEVICE_ID_KEY

    override fun getData(defaultValue: String?): String? {
        return sharedPref.getString(TESTNET_DEVICE_ID_KEY, defaultValue)
    }

    override fun getDataOrNull(): String? {
        return sharedPref.getString(TESTNET_DEVICE_ID_KEY, null)
    }

    override fun saveData(data: String?) {
        saveData { it.putString(TESTNET_DEVICE_ID_KEY, data) }
    }

    companion object {
        private const val TESTNET_DEVICE_ID_KEY = "testnet_device_id"
    }
}
