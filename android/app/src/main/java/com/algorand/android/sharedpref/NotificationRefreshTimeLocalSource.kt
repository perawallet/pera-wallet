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

// ISO-8601 ISO_DATE_TIME
class NotificationRefreshTimeLocalSource @Inject constructor(
    sharedPreferences: SharedPreferences
) : SharedPrefLocalSource<String?>(sharedPreferences) {

    override val key: String
        get() = NOTIFICATION_REFRESH_DATE_KEY

    override fun getData(defaultValue: String?): String? {
        return sharedPref.getString(key, defaultValue)
    }

    override fun getDataOrNull(): String? {
        return sharedPref.getString(key, defaultNotificationRefreshTimePreferences)
    }

    override fun saveData(data: String?) {
        saveData { it.putString(key, data) }
    }

    companion object {
        val defaultNotificationRefreshTimePreferences: String? = null
        private const val NOTIFICATION_REFRESH_DATE_KEY = "notification_refresh_date_key"
    }
}
