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

package com.algorand.android.ui.contacts

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.Result
import com.algorand.android.models.User
import com.algorand.android.usecase.AccountInformationUseCase
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Resource
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class ContactInfoViewModel @ViewModelInject constructor(
    private val accountInformationUseCase: AccountInformationUseCase,
    private val accountCacheManager: AccountCacheManager,
    @Assisted private val savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val contactInfo = savedStateHandle.get<User>(CONTACT_KEY)

    private val _accountInformationFlow = MutableStateFlow<Resource<AccountInformation>?>(null)
    val accountInformationFlow: StateFlow<Resource<AccountInformation>?> get() = _accountInformationFlow

    init {
        getAccountInformation()
    }

    private fun getAccountInformation() {
        viewModelScope.launch {
            val contactPublicKey = contactInfo?.publicKey ?: return@launch
            when (val result = accountInformationUseCase.getAccountInformationAndFetchAssets(contactPublicKey)) {
                is Result.Success -> _accountInformationFlow.emit(Resource.Success(result.data))
                is Result.Error -> _accountInformationFlow.emit(result.getAsResourceError())
            }
        }
    }

    fun filterCachedAccountByAssetId(assetId: Long): List<Pair<AccountCacheData, AssetInformation>> {
        return accountCacheManager.getAccountCacheWithSpecificAsset(assetId, listOf(Account.Type.WATCH))
    }

    fun getAccountAssets(accountInformation: AccountInformation): List<AssetInformation> {
        return accountInformation.getAssetInformationList(accountCacheManager)
    }

    companion object {
        private const val CONTACT_KEY = "contact"
    }
}
