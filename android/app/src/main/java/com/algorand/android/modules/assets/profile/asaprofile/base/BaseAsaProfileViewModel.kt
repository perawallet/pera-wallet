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

package com.algorand.android.modules.assets.profile.asaprofile.base

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account
import com.algorand.android.models.AssetAction
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.AssetOperationResult
import com.algorand.android.modules.assets.profile.asaprofile.ui.model.AsaProfilePreview
import com.algorand.android.modules.assets.profile.asaprofile.ui.usecase.AsaProfilePreviewUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

abstract class BaseAsaProfileViewModel(
    private val asaProfilePreviewUseCase: AsaProfilePreviewUseCase
) : BaseViewModel() {

    abstract val accountAddress: String?
    abstract val assetId: Long

    private var sendTransactionJob: Job? = null

    private val _sendTransactionResultLiveData = MutableLiveData<Event<Resource<AssetOperationResult>>>()
    val sendTransactionResultLiveData: LiveData<Event<Resource<AssetOperationResult>>>
        get() = _sendTransactionResultLiveData

    private val _asaProfilePreviewFlow = MutableStateFlow<AsaProfilePreview?>(null)
    val asaProfilePreviewFlow: StateFlow<AsaProfilePreview?> get() = _asaProfilePreviewFlow

    fun getAssetAction(): AssetAction {
        return asaProfilePreviewUseCase.createAssetAction(assetId = assetId, accountAddress = accountAddress)
    }

    fun sendSignedTransaction(
        signedTransactionData: ByteArray,
        assetInformation: AssetInformation,
        account: Account
    ) {
        if (sendTransactionJob?.isActive == true) {
            return
        }

        sendTransactionJob = viewModelScope.launch(Dispatchers.IO) {
            asaProfilePreviewUseCase.sendTransaction(
                signedTransactionData = signedTransactionData,
                assetInformation = assetInformation,
                account = account
            ).collect {
                _sendTransactionResultLiveData.postValue(it)
            }
        }
    }

    protected fun initAsaPreviewFlow() {
        viewModelScope.launch {
            asaProfilePreviewUseCase.getAsaProfilePreview(accountAddress, assetId).collect { asaProfilePreview ->
                _asaProfilePreviewFlow.emit(asaProfilePreview)
            }
        }
    }

    protected companion object {
        const val ACCOUNT_ADDRESS_KEY = "accountAddress"
        const val ASSET_ID_KEY = "assetId"
    }
}
