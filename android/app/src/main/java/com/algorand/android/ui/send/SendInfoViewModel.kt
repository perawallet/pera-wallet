/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.send

import android.content.SharedPreferences
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AssetSupportRequest
import com.algorand.android.models.Result
import com.algorand.android.network.getAsResourceError
import com.algorand.android.repository.AccountRepository
import com.algorand.android.repository.AssetRepository
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.preference.getFirstTransactionWarningPreference
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class SendInfoViewModel @ViewModelInject constructor(
    private val sharedPref: SharedPreferences,
    private val accountRepository: AccountRepository,
    private val assetRepository: AssetRepository
) : BaseViewModel() {

    val fromAccountInformationLiveData = MutableLiveData<Event<Resource<AccountInformation>>>()
    val toAccountInformationLiveData = MutableLiveData<Event<Resource<AccountInformation>>>()

    fun fetchFromAccountInformation(fromAddress: String) {
        viewModelScope.launch(Dispatchers.IO) {
            when (val result = accountRepository.getOtherAccountInformation(fromAddress)) {
                is Result.Success -> {
                    fromAccountInformationLiveData.postValue(Event(Resource.Success(result.data)))
                }
                is Result.Error -> {
                    fromAccountInformationLiveData.postValue(Event(result.getAsResourceError()))
                }
            }
        }
    }

    fun fetchToAccountInformation(toAddress: String) {
        viewModelScope.launch(Dispatchers.IO) {
            when (val result = accountRepository.getOtherAccountInformation(toAddress)) {
                is Result.Success -> {
                    toAccountInformationLiveData.postValue(Event(Resource.Success(result.data)))
                }
                is Result.Error -> {
                    toAccountInformationLiveData.postValue(Event(result.getAsResourceError()))
                }
            }
        }
    }

    fun sendAssetSupportRequest(requestedAddress: String?, fromAddress: String?, assetId: Long) {
        if (requestedAddress == null || fromAddress == null) return
        viewModelScope.launch(Dispatchers.IO) {
            assetRepository.postAssetSupportRequest(
                AssetSupportRequest(fromAddress, requestedAddress, assetId)
            )
        }
    }

    fun getFirstTransactionPreference(): Boolean {
        return sharedPref.getFirstTransactionWarningPreference()
    }
}
