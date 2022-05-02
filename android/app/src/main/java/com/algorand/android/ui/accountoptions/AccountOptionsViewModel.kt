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

package com.algorand.android.ui.accountoptions

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.database.NotificationFilterDao
import com.algorand.android.models.Account
import com.algorand.android.models.WarningConfirmation
import com.algorand.android.repository.NotificationRepository
import com.algorand.android.usecase.AccountOptionsUseCase
import com.algorand.android.utils.Resource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch

class AccountOptionsViewModel @ViewModelInject constructor(
    private val notificationFilterDao: NotificationFilterDao,
    private val notificationRepository: NotificationRepository,
    private val accountOptionsUseCase: AccountOptionsUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val publicKey by lazy { savedStateHandle.get<String>(ACCOUNT_PUBLIC_KEY).orEmpty() }

    val notificationFilterOperationFlow = MutableStateFlow<Resource<Unit>?>(null)
    val notificationFilterCheckFlow = MutableStateFlow<Boolean?>(null)

    init {
        checkIfNotificationFiltered()
    }

    private fun checkIfNotificationFiltered() {
        viewModelScope.launch(Dispatchers.IO) {
            notificationFilterCheckFlow.value =
                notificationFilterDao.getNotificationFilterForUser(publicKey).isNotEmpty()
        }
    }

    fun startFilterOperation(isFiltered: Boolean) {
        viewModelScope.launch(Dispatchers.IO) {
            notificationFilterOperationFlow.value = Resource.Loading
            notificationFilterOperationFlow.value = notificationRepository.addNotificationFilter(publicKey, isFiltered)
        }
    }

    fun isThereAnyAsset(): Boolean {
        return accountOptionsUseCase.isThereAnyAsset(publicKey)
    }

    fun isRekeyedToAnotherAccount(): Boolean {
        return accountOptionsUseCase.isAccountRekeyed(publicKey)
    }

    fun getAuthAddress(): String? {
        return accountOptionsUseCase.getAuthAddress(publicKey)
    }

    fun getAccountAddress(): String? {
        return accountOptionsUseCase.getAccountAddress(publicKey)
    }

    fun getAccountType(): Account.Type {
        return accountOptionsUseCase.getAccountType(publicKey)
    }

    fun getAccountName(): String {
        return accountOptionsUseCase.getAccountName(publicKey)
    }

    fun getRemovingAccountWarningConfirmationModel(): WarningConfirmation {
        return accountOptionsUseCase.getRemovingAccountWarningConfirmationModel(publicKey)
    }

    companion object {
        private const val ACCOUNT_PUBLIC_KEY = "publicKey"
    }
}
