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
import javax.inject.Inject
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.customviews.accountandassetitem.mapper.AccountItemConfigurationMapper
import com.algorand.android.database.NotificationFilterDao
import com.algorand.android.models.AccountIconResource
import com.algorand.android.modules.accounts.domain.usecase.GetAccountValueUseCase
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.AccountSortPreferenceUseCase
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.GetSortedAccountsByPreferenceUseCase
import com.algorand.android.repository.NotificationRepository
import com.algorand.android.utils.Resource
import com.algorand.android.utils.preference.isNotificationActivated
import com.algorand.android.utils.preference.setNotificationPreference
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@HiltViewModel
class NotificationFilterViewModel @Inject constructor(
    private val sharedPref: SharedPreferences,
    private val notificationRepository: NotificationRepository,
    private val notificationFilterDao: NotificationFilterDao,
    private val getSortedAccountsByPreferenceUseCase: GetSortedAccountsByPreferenceUseCase,
    private val accountItemConfigurationMapper: AccountItemConfigurationMapper,
    private val getAccountValueUseCase: GetAccountValueUseCase,
    private val accountSortPreferenceUseCase: AccountSortPreferenceUseCase
) : BaseViewModel() {

    val notificationFilterOperation = MutableStateFlow<Resource<Unit>?>(null)
    val notificationFilterListStateFlow = MutableStateFlow<List<AccountNotificationOption>>(listOf())

    init {
        viewModelScope.launch(Dispatchers.IO) {
            notificationFilterDao.getAllAsFlow().collectLatest { notificationFilterList ->
                val sortedAccountListItem = getSortedAccountsByPreferenceUseCase.getSortedAccountListItems(
                    sortingPreferences = accountSortPreferenceUseCase.getAccountSortPreference(),
                    onLoadedAccountConfiguration = {
                        val accountValue = getAccountValueUseCase.getAccountValue(this)
                        accountItemConfigurationMapper.mapTo(
                            accountAddress = account.address,
                            accountName = account.name,
                            accountType = account.type,
                            accountIconResource = AccountIconResource.getAccountIconResourceByAccountType(account.type),
                            accountPrimaryValue = accountValue.primaryAccountValue
                        )
                    },
                    onFailedAccountConfiguration = {
                        this?.run {
                            accountItemConfigurationMapper.mapTo(
                                accountAddress = address,
                                accountName = name,
                                accountType = type,
                                accountIconResource = AccountIconResource.getAccountIconResourceByAccountType(type),
                                showWarningIcon = true
                            )
                        }
                    }
                )
                val generatedList = sortedAccountListItem.map { accountListItem ->
                    val isAccountFiltered = notificationFilterList.any {
                        it.publicKey == accountListItem.itemConfiguration.accountAddress
                    }
                    AccountNotificationOption(accountListItem = accountListItem, isFiltered = isAccountFiltered)
                }
                notificationFilterListStateFlow.emit(generatedList)
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
