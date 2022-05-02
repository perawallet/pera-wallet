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
import com.algorand.android.models.BaseRemoveAssetItem
import com.algorand.android.models.Result
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.usecase.AccountAssetRemovalUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.getOrThrow
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.launch

class RemoveAssetsViewModel @ViewModelInject constructor(
    private val transactionsRepository: TransactionsRepository,
    private val accountAssetRemovalUseCase: AccountAssetRemovalUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private var assetQueryJob: Job? = null

    private val accountPublicKey = savedStateHandle.getOrThrow<String>(ACCOUNT_PUBLIC_KEY)

    val removeAssetLiveData = MutableLiveData<Event<Resource<Unit>>>()

    private val _accountAssetListFlow = MutableStateFlow<List<BaseRemoveAssetItem>?>(null)
    val accountAssetListFlow: StateFlow<List<BaseRemoveAssetItem>?> = _accountAssetListFlow

    private val _accountDetailSummaryFlow = MutableStateFlow<AccountDetailSummary?>(null)
    val accountDetailSummaryFlow: StateFlow<AccountDetailSummary?> = _accountDetailSummaryFlow

    private val assetQueryFlow = MutableStateFlow("")

    init {
        getAccountDetailSummary()
        initAssetQueryFlow()
    }

    fun updateSearchingQuery(query: String) {
        assetQueryFlow.value = query
    }

    fun sendSignedTransaction(
        signedTransactionData: ByteArray,
        assetInformation: AssetInformation,
        account: Account
    ) {
        removeAssetLiveData.postValue(Event(Resource.Loading))
        viewModelScope.launch(Dispatchers.IO) {
            when (val result = transactionsRepository.sendSignedTransaction(signedTransactionData)) {
                is Result.Success -> {
                    accountAssetRemovalUseCase.addAssetDeletionToAccountCache(account.address, assetInformation.assetId)
                    removeAssetLiveData.postValue(Event(Resource.Success((Unit))))
                }
                is Result.Error -> {
                    removeAssetLiveData.postValue(Event((result.getAsResourceError())))
                }
            }
        }
    }

    fun refreshAssetQueryFlow() {
        assetQueryJob?.cancel()
        assetQueryJob = getAssetQueryJob()
    }

    private fun initAssetQueryFlow() {
        assetQueryJob = getAssetQueryJob()
    }

    private fun getAssetQueryJob(): Job {
        return viewModelScope.launch {
            accountAssetRemovalUseCase.getRemovalAccountAssetsByQuery(
                accountPublicKey,
                assetQueryFlow.debounce(QUERY_DEBOUNCE).distinctUntilChanged()
            ).collect {
                _accountAssetListFlow.emit(it)
            }
        }
    }

    private fun getAccountDetailSummary() {
        viewModelScope.launch {
            _accountDetailSummaryFlow.emit(accountAssetRemovalUseCase.getAccountSummary(accountPublicKey))
        }
    }

    companion object {
        private const val ACCOUNT_PUBLIC_KEY = "accountPublicKey"
        private const val QUERY_DEBOUNCE = 300L
    }
}
