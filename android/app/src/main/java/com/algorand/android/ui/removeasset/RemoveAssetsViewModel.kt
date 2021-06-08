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

package com.algorand.android.ui.removeasset

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.AccountManager
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.Result
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.ui.common.listhelper.BaseAccountListItem
import com.algorand.android.ui.common.listhelper.viewholders.HeaderAccountListItem
import com.algorand.android.ui.common.listhelper.viewholders.RemoveAssetListItem
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class RemoveAssetsViewModel @ViewModelInject constructor(
    private val accountManager: AccountManager,
    private val accountCacheManager: AccountCacheManager,
    private val transactionsRepository: TransactionsRepository
) : BaseViewModel() {

    val removeAssetLiveData = MutableLiveData<Event<Resource<Unit>>>()
    val removeAssetListLiveData = MutableLiveData<List<BaseAccountListItem>>()
    private lateinit var networkErrorMessage: String

    fun start(networkErrorMessage: String) {
        this.networkErrorMessage = networkErrorMessage
    }

    fun constructList(
        accountCacheDataMap: Map<String, AccountCacheData>,
        publicKey: String
    ) {
        viewModelScope.launch(Dispatchers.IO) {
            val result = mutableListOf<BaseAccountListItem>()
            accountCacheDataMap[publicKey]?.let { accountBalanceInformation ->
                with(accountBalanceInformation) {
                    result.add(HeaderAccountListItem(this))
                    assetsInformation.forEach {
                        if (it.isAlgorand().not()) {
                            result.add(RemoveAssetListItem(account.address, it))
                        }
                    }
                }
            }
            removeAssetListLiveData.postValue(result)
        }
    }

    fun sendSignedTransaction(
        signedTransactionData: ByteArray,
        assetInformation: AssetInformation,
        account: Account
    ) {
        viewModelScope.launch(Dispatchers.IO) {
            when (transactionsRepository.sendSignedTransaction(signedTransactionData)) {
                is Result.Success -> {
                    accountCacheManager.changeAssetStatusToPendingRemoval(account.address, assetInformation.assetId)
                    removeAssetLiveData.postValue(Event(Resource.Success((Unit))))
                }
            }
        }
    }
}
