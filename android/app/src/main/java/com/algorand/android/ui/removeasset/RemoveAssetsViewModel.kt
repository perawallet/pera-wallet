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
import com.algorand.android.models.RemoveAssetItem
import com.algorand.android.models.Result
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.usecase.AccountAssetRemovalUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.getOrThrow
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.launch

class RemoveAssetsViewModel @ViewModelInject constructor(
    private val transactionsRepository: TransactionsRepository,
    private val accountAssetRemovalUseCase: AccountAssetRemovalUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val accountPublicKey = savedStateHandle.getOrThrow<String>(ACCOUNT_PUBLIC_KEY)

    val removeAssetLiveData = MutableLiveData<Event<Resource<Unit>>>()

    private val _accountAssetListFlow = MutableStateFlow<List<RemoveAssetItem>?>(null)
    val accountAssetListFlow: StateFlow<List<RemoveAssetItem>?> = _accountAssetListFlow

    private val _accountDetailSummaryFlow = MutableStateFlow<AccountDetailSummary?>(null)
    val accountDetailSummaryFlow: StateFlow<AccountDetailSummary?> = _accountDetailSummaryFlow

    private val assetQueryFlow = MutableStateFlow("")

    init {
        getAccountDetailSummary()
        initAssetQueryFlow()
    }

    fun updateSearchingQuery(query: String) {
        viewModelScope.launch {
            assetQueryFlow.emit(query)
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

    private fun initAssetQueryFlow() {
        viewModelScope.launch {
            assetQueryFlow.debounce(QUERY_DEBOUNCE)
                .distinctUntilChanged()
                .flatMapLatest { accountAssetRemovalUseCase.getRemovalAccountAssetsByQuery(accountPublicKey, it) }
                .collectLatest { _accountAssetListFlow.emit(it) }
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
