/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.send.receiveraccount

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.models.Result
import com.algorand.android.models.TargetUser
import com.algorand.android.usecase.ReceiverAccountSelectionUseCase
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.isValidAddress
import kotlin.properties.Delegates
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.launch

class ReceiverAccountSelectionViewModel @ViewModelInject constructor(
    private val receiverAccountSelectionUseCase: ReceiverAccountSelectionUseCase,
    private val accountCacheManager: AccountCacheManager,
    @Assisted savedStateHandle: SavedStateHandle
) : ViewModel() {

    val assetTransaction = savedStateHandle.get<AssetTransaction>(ASSET_TRANSACTION_KEY)!!

    private val _selectableAccountFlow = MutableStateFlow<List<BaseAccountSelectionListItem>?>(null)
    val selectableAccountFlow: StateFlow<List<BaseAccountSelectionListItem>?> = _selectableAccountFlow

    private val _toAccountAddressValidationFlow = MutableStateFlow<Event<Resource<String>>?>(null)
    val toAccountAddressValidationFlow: StateFlow<Event<Resource<String>>?> = _toAccountAddressValidationFlow

    private val _toAccountInformationFlow = MutableStateFlow<Event<Resource<AccountInformation>>?>(null)
    val toAccountInformationFlow: StateFlow<Event<Resource<AccountInformation>>?> = _toAccountInformationFlow

    private val _toAccountTransactionRequirementsFlow = MutableStateFlow<Event<Resource<TargetUser>>?>(null)
    val toAccountTransactionRequirementsFlow: StateFlow<Event<Resource<TargetUser>>?> =
        _toAccountTransactionRequirementsFlow

    private val queryFlow = MutableStateFlow("")

    private var copiedMessage: String? by Delegates.observable(null) { _, oldValue, newValue ->
        if (newValue != null && oldValue != newValue) {
            insertPastedAccountAddress(newValue)
        }
    }

    init {
        viewModelScope.launch {
            queryFlow.debounce(QUERY_DEBOUNCE)
                .distinctUntilChanged()
                .flatMapLatest {
                    with(assetTransaction) {
                        receiverAccountSelectionUseCase.getToAccountList(it, assetId)
                    }
                }
                .flowOn(Dispatchers.Default)
                .collect { toAccounts ->
                    toAccounts.toMutableList().apply {
                        copiedMessage?.let { add(0, BaseAccountSelectionListItem.PasteItem(it)) }
                        _selectableAccountFlow.emit(this)
                    }
                }
        }
    }

    fun onSearchQueryUpdate(query: String) {
        viewModelScope.launch {
            queryFlow.emit(query)
        }
    }

    fun checkIsGivenAddressValid(toAccountPublicKey: String) {
        viewModelScope.launch {
            _toAccountAddressValidationFlow.emit(Event(Resource.Loading))
            when (val result = receiverAccountSelectionUseCase.isAccountAddressValid(toAccountPublicKey)) {
                is Result.Error -> _toAccountAddressValidationFlow.emit(Event(result.getAsResourceError()))
                is Result.Success -> _toAccountAddressValidationFlow.emit(Event(Resource.Success(result.data)))
            }
        }
    }

    fun fetchToAccountInformation(toAccountPublicKey: String) {
        viewModelScope.launch {
            _toAccountInformationFlow.emit(Event(Resource.Loading))
            val result = receiverAccountSelectionUseCase.fetchAccountInformation(toAccountPublicKey, viewModelScope)
            when (result) {
                is Result.Success -> _toAccountInformationFlow.emit(Event(Resource.Success(result.data)))
                is Result.Error -> _toAccountInformationFlow.emit(Event(result.getAsResourceError()))
            }
        }
    }

    fun checkToAccountTransactionRequirements(accountInformation: AccountInformation) {
        viewModelScope.launch {
            _toAccountTransactionRequirementsFlow.emit(Event(Resource.Loading))
            val result = receiverAccountSelectionUseCase.checkToAccountTransactionRequirements(
                accountInformation,
                assetTransaction.assetId,
                assetTransaction.senderAddress,
                assetTransaction.amount
            )
            when (result) {
                is Result.Error -> _toAccountTransactionRequirementsFlow.emit(Event(result.getAsResourceError()))
                is Result.Success -> {
                    _toAccountTransactionRequirementsFlow.emit(Event(Resource.Success(result.data)))
                }
            }
        }
    }

    fun getFromAccountCachedData(): AccountCacheData? {
        return accountCacheManager.getCacheData(assetTransaction.senderAddress)
    }

    fun getSelectedAssetInformation(): AssetInformation? {
        return with(assetTransaction) {
            receiverAccountSelectionUseCase.getAssetInformation(assetId, senderAddress)
        }
    }

    private fun insertPastedAccountAddress(address: String) {
        viewModelScope.launch {
            _selectableAccountFlow.value
                ?.filter { it !is BaseAccountSelectionListItem.PasteItem }
                ?.toMutableList()
                ?.apply {
                    add(0, BaseAccountSelectionListItem.PasteItem(address))
                    _selectableAccountFlow.emit(this)
                }
        }
    }

    fun updateCopiedMessage(copiedMessage: String?) {
        this.copiedMessage = copiedMessage.takeIf { it.isValidAddress() }
    }

    companion object {
        private const val ASSET_TRANSACTION_KEY = "assetTransaction"
        private const val QUERY_DEBOUNCE = 300L
    }
}
