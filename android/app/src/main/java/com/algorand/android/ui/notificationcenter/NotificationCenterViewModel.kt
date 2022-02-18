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

package com.algorand.android.ui.notificationcenter

import android.content.SharedPreferences
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.LiveData
import androidx.lifecycle.Transformations
import androidx.lifecycle.viewModelScope
import androidx.paging.Pager
import androidx.paging.PagingConfig
import androidx.paging.cachedIn
import com.algorand.android.core.AccountManager
import com.algorand.android.core.BaseViewModel
import com.algorand.android.database.ContactDao
import com.algorand.android.models.AssetInformation
import com.algorand.android.notification.PeraNotificationManager
import com.algorand.android.repository.NotificationRepository
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.preference.getNotificationRefreshDateTime
import com.algorand.android.utils.preference.setNotificationRefreshDate
import java.time.ZonedDateTime

class NotificationCenterViewModel @ViewModelInject constructor(
    private val peraNotificationManager: PeraNotificationManager,
    private val sharedPref: SharedPreferences,
    private val contactDao: ContactDao,
    private val accountManager: AccountManager,
    private val accountCacheManager: AccountCacheManager,
    private val notificationRepository: NotificationRepository
) : BaseViewModel() {

    private var notificationDataSource: NotificationDataSource? = null

    val notificationPaginationFlow = Pager(PagingConfig(pageSize = DEFAULT_NOTIFICATION_COUNT)) {
        NotificationDataSource(
            notificationRepository = notificationRepository,
            sharedPref = sharedPref,
            contactDao = contactDao,
            accountManager = accountManager
        ).also { notificationDataSource ->
            this.notificationDataSource = notificationDataSource
        }
    }.flow.cachedIn(viewModelScope)

    fun refreshNotificationData(refreshDateTime: ZonedDateTime? = null) {
        if (refreshDateTime != null) {
            setLastRefreshedDateTime(refreshDateTime)
        }
        notificationDataSource?.invalidate()
    }

    fun getLastRefreshedDateTime(): ZonedDateTime {
        return sharedPref.getNotificationRefreshDateTime()
    }

    fun setLastRefreshedDateTime(zonedDateTime: ZonedDateTime) {
        sharedPref.setNotificationRefreshDate(zonedDateTime)
    }

    fun isAssetAvailableOnAccount(publicKey: String, assetInformation: AssetInformation): Boolean {
        return accountCacheManager.getAssetInformation(publicKey, assetInformation.assetId) != null
    }

    fun isRefreshNeededLiveData(): LiveData<Boolean> {
        var newNotificationCount = 0
        return Transformations.map(peraNotificationManager.newNotificationLiveData) {
            newNotificationCount++
            return@map newNotificationCount > 1
        }
    }

    companion object {
        private const val DEFAULT_NOTIFICATION_COUNT = 15
    }
}
