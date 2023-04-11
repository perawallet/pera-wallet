package com.algorand.android.modules.notification.data.local

import android.content.SharedPreferences
import com.algorand.android.sharedpref.SharedPrefLocalSource
import javax.inject.Inject

class LastSeenNotificationIdLocalSource @Inject constructor(
    sharedPreferences: SharedPreferences
) : SharedPrefLocalSource<Long>(sharedPreferences) {

    override val key: String = LAST_SEEN_NOTIFICATION_ID_SHARED_PREF_KEY

    override fun getData(defaultValue: Long): Long {
        return sharedPref.getLong(key, defaultValue)
    }

    override fun getDataOrNull(): Long? {
        val data = sharedPref.getLong(key, DATA_DEFAULT_VALUE)
        return if (data == DATA_DEFAULT_VALUE) null else data
    }

    override fun saveData(data: Long) {
        saveData { it.putLong(key, data) }
    }

    companion object {
        private const val LAST_SEEN_NOTIFICATION_ID_SHARED_PREF_KEY = "last_seen_notification_id"
        private const val DATA_DEFAULT_VALUE = Long.MIN_VALUE
    }
}
