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

package com.algorand.android.ui.notificationfilter

import android.content.SharedPreferences
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.database.NotificationFilterDao
import com.algorand.android.repository.NotificationRepository
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Resource
import com.algorand.android.utils.preference.isNotificationActivated
import com.algorand.android.utils.preference.setNotificationPreference
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class NotificationFilterViewModel @ViewModelInject constructor(
    private val sharedPref: SharedPreferences,
    private val notificationRepository: NotificationRepository,
    private val accountCacheManager: AccountCacheManager,
    private val notificationFilterDao: NotificationFilterDao
) : BaseViewModel() {

    val notificationFilterOperation = MutableStateFlow<Resource<Unit>?>(null)
    val notificationFilterListStateFlow = MutableStateFlow<List<AccountNotificationOption>>(listOf())

    init {
        viewModelScope.launch(Dispatchers.IO) {
            notificationFilterDao.getAllAsFlow().collectLatest { notificationFilterList ->
                val generatedList = mutableListOf<AccountNotificationOption>()
                accountCacheManager.accountCacheMap.value.forEach { (publicKey, accountCacheData) ->
                    val isAccountFiltered = notificationFilterList.any { it.publicKey == publicKey }
                    generatedList.add(
                        AccountNotificationOption(
                            publicKey = publicKey,
                            accountName = accountCacheData.account.name,
                            isFiltered = isAccountFiltered,
                            accountIcon = accountCacheData.account.createAccountIcon()
                        )
                    )
                }
                notificationFilterListStateFlow.value = generatedList
            }
        }
    }

    fun startFilterOperation(publicKey: String, isFiltered: Boolean) {
        viewModelScope.launch(Dispatchers.IO) {
            notificationFilterOperation.value = Resource.Loading
            notificationFilterOperation.value = notificationRepository.addNotificationFilter(publicKey, isFiltered)
        }
    }

    fun isPushNotificationsEnabled(): Boolean {
        return sharedPref.isNotificationActivated()
    }

    fun setPushNotificationPreference(notificationPreference: Boolean) {
        sharedPref.setNotificationPreference(notificationPreference)
    }
}
