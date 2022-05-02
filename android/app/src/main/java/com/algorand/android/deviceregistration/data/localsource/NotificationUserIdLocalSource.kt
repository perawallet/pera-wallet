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

/**
 * This class is being used to support previous versions (Before 5.2.2)
 * There was only one device id but right now, there are 2 device ids for different nodes (Mainnet, Testnet)
 * This class represent previously held user id.
 */
class NotificationUserIdLocalSource @Inject constructor(
    sharedPreferences: SharedPreferences
) : SharedPrefLocalSource<String?>(sharedPreferences) {

    override val key: String = NOTIFICATION_USER_ID_KEY

    override fun getData(defaultValue: String?): String? {
        return sharedPref.getString(NOTIFICATION_USER_ID_KEY, defaultValue)
    }

    override fun getDataOrNull(): String? {
        return sharedPref.getString(NOTIFICATION_USER_ID_KEY, null)
    }

    override fun saveData(data: String?) {
        saveData { it.putString(NOTIFICATION_USER_ID_KEY, data) }
    }

    companion object {
        private const val NOTIFICATION_USER_ID_KEY = "notification_user_id"
    }
}
