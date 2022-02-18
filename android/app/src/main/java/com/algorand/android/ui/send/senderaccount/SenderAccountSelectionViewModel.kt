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

package com.algorand.android.ui.send.senderaccount

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.Result
import com.algorand.android.ui.common.listhelper.BaseAccountListItem
import com.algorand.android.usecase.AccountSelectionPreviewUseCase
import com.algorand.android.usecase.SenderAccountSelectionUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.getOrElse
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class SenderAccountSelectionViewModel @ViewModelInject constructor(
    private val senderAccountSelectionUseCase: SenderAccountSelectionUseCase,
    private val accountSelectionUseCase: AccountSelectionPreviewUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : ViewModel() {

    val assetTransaction: AssetTransaction = savedStateHandle.getOrElse(ASSET_TRANSACTION_KEY, AssetTransaction())

    private val _fromAccountListFlow = MutableStateFlow<List<BaseAccountListItem.BaseAccountItem>>(emptyList())
    val fromAccountListFlow: StateFlow<List<BaseAccountListItem.BaseAccountItem>> = _fromAccountListFlow

    private val _fromAccountInformationFlow = MutableStateFlow<Event<Resource<AccountInformation>>?>(null)
    val fromAccountInformationFlow: StateFlow<Event<Resource<AccountInformation>>?> = _fromAccountInformationFlow

    init {
        // If user came with deeplink or qr code then we have to filter accounts that have incoming asset id
        if (assetTransaction.assetId != -1L && assetTransaction.assetId != ALGORAND_ID) {
            getAccountCacheWithSpecificAsset(assetTransaction.assetId)
        } else {
            getAccounts()
        }
    }

    private fun getAccounts() {
        viewModelScope.launch {
            _fromAccountListFlow.emit(accountSelectionUseCase.getBaseNormalAccountListItems())
        }
    }

    private fun getAccountCacheWithSpecificAsset(assetId: Long) {
        viewModelScope.launch {
            _fromAccountListFlow.emit(accountSelectionUseCase.getBaseNormalAccountListItemsFilteredByAssetId(assetId))
        }
    }

    fun fetchFromAccountInformation(fromAccountPublicKey: String) {
        viewModelScope.launch {
            _fromAccountInformationFlow.emit(Event(Resource.Loading))
            when (val result = senderAccountSelectionUseCase.fetchAccountInformation(fromAccountPublicKey)) {
                is Result.Error -> _fromAccountInformationFlow.emit(Event(result.getAsResourceError()))
                is Result.Success -> _fromAccountInformationFlow.emit(Event(Resource.Success(result.data)))
            }
        }
    }

    fun shouldShowTransactionTips(): Boolean {
        return senderAccountSelectionUseCase.shouldShowTransactionTips()
    }

    fun getAssetInformation(senderAddress: String): AssetInformation? {
        return senderAccountSelectionUseCase.getAssetInformation(senderAddress, assetTransaction.assetId)
    }

    fun getAccountCachedData(senderAddress: String): AccountCacheData? {
        return senderAccountSelectionUseCase.getAccountInformation(senderAddress)
    }

    companion object {
        private const val ASSET_TRANSACTION_KEY = "assetTransaction"
    }
}
