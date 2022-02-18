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

package com.algorand.android.ui.send.transferamount

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetTransferAmountPreview
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.Result
import com.algorand.android.usecase.AssetTransferAmountUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.getOrThrow
import java.math.BigDecimal
import java.math.BigInteger
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class AssetTransferAmountViewModel @ViewModelInject constructor(
    private val assetTransferAmountUseCase: AssetTransferAmountUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : ViewModel() {

    val assetTransaction = savedStateHandle.getOrThrow<AssetTransaction>(ASSET_TRANSACTION_KEY)

    private val _amountValidationFlow = MutableStateFlow<Event<Resource<BigInteger>>?>(null)
    val amountValidationFlow: StateFlow<Event<Resource<BigInteger>>?> = _amountValidationFlow

    private val _assetTransferAmountPreviewFlow = MutableStateFlow<AssetTransferAmountPreview?>(null)
    val assetTransferAmountPreviewFlow: StateFlow<AssetTransferAmountPreview?> = _assetTransferAmountPreviewFlow

    init {
        getAssetTransferAmountPreview()
    }

    private fun getAssetTransferAmountPreview() {
        viewModelScope.launch {
            val result = assetTransferAmountUseCase.getAssetTransferAmountPreview(
                assetTransaction.senderAddress,
                assetTransaction.assetId
            )
            _assetTransferAmountPreviewFlow.emit(result)
        }
    }

    fun updateAssetTransferAmountPreviewAccordingToAmount(amount: BigDecimal) {
        viewModelScope.launch {
            val result = assetTransferAmountUseCase.getAssetTransferAmountPreview(
                assetTransaction.senderAddress,
                assetTransaction.assetId,
                amount
            )
            _assetTransferAmountPreviewFlow.emit(result)
        }
    }

    fun onAmountSelected(amount: BigDecimal) {
        viewModelScope.launch {
            _amountValidationFlow.emit(Event(Resource.Loading))
            val result = assetTransferAmountUseCase.validateAssetAmount(
                amount,
                assetTransaction.senderAddress,
                assetTransaction.assetId
            )
            when (result) {
                is Result.Error -> _amountValidationFlow.emit(Event(result.getAsResourceError()))
                is Result.Success -> _amountValidationFlow.emit(Event(Resource.Success(result.data)))
            }
        }
    }

    fun calculateAmount(amount: BigDecimal) {
        viewModelScope.launch {
            _amountValidationFlow.emit(Event(Resource.Loading))
            val result = assetTransferAmountUseCase.getCalculatedMinimumBalance(
                amount,
                assetTransaction.assetId,
                assetTransaction.senderAddress
            )
            when (result) {
                is Result.Error -> _amountValidationFlow.emit(Event(result.getAsResourceError()))
                is Result.Success -> _amountValidationFlow.emit(Event(Resource.Success(result.data)))
            }
        }
    }

    fun getAssetInformation(): AssetInformation? {
        return with(assetTransaction) {
            assetTransferAmountUseCase.getAssetInformation(senderAddress, assetId)
        }
    }

    fun getAccountCachedData(): AccountCacheData? {
        return assetTransferAmountUseCase.getAccountInformation(assetTransaction.senderAddress)
    }

    fun shouldShowTransactionTips(): Boolean {
        return assetTransferAmountUseCase.shouldShowTransactionTips()
    }

    companion object {
        private const val ASSET_TRANSACTION_KEY = "assetTransaction"
    }
}
