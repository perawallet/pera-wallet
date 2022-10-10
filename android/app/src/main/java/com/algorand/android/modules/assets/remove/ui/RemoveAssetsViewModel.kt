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

package com.algorand.android.modules.assets.remove.ui

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.Result
import com.algorand.android.modules.assets.remove.ui.model.RemoveAssetsPreview
import com.algorand.android.modules.assets.remove.ui.usecase.RemoveAssetsPreviewUseCase
import com.algorand.android.repository.TransactionsRepository
import com.algorand.android.usecase.AccountAssetRemovalUseCase
import com.algorand.android.utils.AssetName
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.launch

@HiltViewModel
class RemoveAssetsViewModel @Inject constructor(
    private val transactionsRepository: TransactionsRepository,
    private val accountAssetRemovalUseCase: AccountAssetRemovalUseCase,
    private val removeAssetsPreviewUseCase: RemoveAssetsPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    val accountAddress = savedStateHandle.getOrThrow<String>(ACCOUNT_PUBLIC_KEY)

    val removeAssetLiveData = MutableLiveData<Event<Resource<AssetName>>>()

    private val _removeAssetsPreviewFlow = MutableStateFlow<RemoveAssetsPreview?>(null)
    val removeAssetsPreviewFlow: StateFlow<RemoveAssetsPreview?> = _removeAssetsPreviewFlow

    private val assetQueryFlow = MutableStateFlow("")

    init {
        initAssetQueryFlow()
    }

    fun updateSearchingQuery(query: String) {
        viewModelScope.launch { assetQueryFlow.emit(query) }
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
                    val assetName = AssetName.create(assetInformation.fullName)
                    removeAssetLiveData.postValue(Event(Resource.Success((assetName))))
                }
                is Result.Error -> {
                    removeAssetLiveData.postValue(Event((result.getAsResourceError())))
                }
            }
        }
    }

    private fun initAssetQueryFlow() {
        viewModelScope.launch {
            assetQueryFlow.debounce(QUERY_DEBOUNCE)
                .distinctUntilChanged()
                .flatMapLatest { query -> removeAssetsPreviewUseCase.initRemoveAssetsPreview(accountAddress, query) }
                .collectLatest { _removeAssetsPreviewFlow.emit(it) }
        }
    }

    companion object {
        private const val ACCOUNT_PUBLIC_KEY = "accountPublicKey"
        private const val QUERY_DEBOUNCE = 300L
    }
}
