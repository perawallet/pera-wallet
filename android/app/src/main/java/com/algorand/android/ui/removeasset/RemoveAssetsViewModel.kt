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

package com.algorand.android.ui.removeasset

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.models.AccountDetailSummary
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.Result
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.usecase.AccountAssetDataUseCase
import com.algorand.android.usecase.AccountAssetRemovalUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class RemoveAssetsViewModel @ViewModelInject constructor(
    private val transactionsRepository: TransactionsRepository,
    private val accountAssetRemovalUseCase: AccountAssetRemovalUseCase,
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    val removeAssetLiveData = MutableLiveData<Event<Resource<Unit>>>()
    val removeAssetListLiveData = MutableLiveData<List<RemoveAssetItem>>()

    private lateinit var networkErrorMessage: String

    private val accountPublicKey by lazy { savedStateHandle.get<String>(ACCOUNT_PUBLIC_KEY).orEmpty() }

    fun start(networkErrorMessage: String) {
        this.networkErrorMessage = networkErrorMessage
    }

    init {
        initializeAccountAssetList()
    }

    private fun initializeAccountAssetList() {
        viewModelScope.launch(Dispatchers.IO) {
            val removeItemList = accountAssetDataUseCase.getAccountOwnedAssetData(accountPublicKey, includeAlgo = false)
                .map { RemoveAssetItem(it) }
            removeAssetListLiveData.postValue(removeItemList)
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
                    accountAssetRemovalUseCase.addAssetDeletionToAccountCache(account.address, assetInformation.assetId)
                    removeAssetLiveData.postValue(Event(Resource.Success((Unit))))
                }
            }
        }
    }

    fun getAccountDetailSummary(): AccountDetailSummary? {
        return accountAssetRemovalUseCase.getAccountSummary(accountPublicKey)
    }

    companion object {
        private const val ACCOUNT_PUBLIC_KEY = "accountPublicKey"
    }
}
