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

package com.algorand.android.nft.ui.nftsend

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.models.TargetUser
import com.algorand.android.models.TransactionData
import com.algorand.android.nft.domain.usecase.CollectibleSendPreviewUseCase
import com.algorand.android.nft.ui.model.CollectibleDetail
import com.algorand.android.nft.ui.model.CollectibleSendPreview
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.getOrThrow
import java.math.BigInteger
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class CollectibleSendViewModel @ViewModelInject constructor(
    private val collectibleSendPreviewUseCase: CollectibleSendPreviewUseCase,
    private val accountCacheManager: AccountCacheManager,
    @Assisted savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val collectibleDetail = savedStateHandle.getOrThrow<CollectibleDetail>(COLLECTIBLE_DETAIL_ARG_KEY)

    private val _selectedAccountAddressFlow = MutableStateFlow<String>("")
    val selectedAccountAddressFlow: StateFlow<String>
        get() = _selectedAccountAddressFlow

    private val _collectibleSendPreviewFlow = MutableStateFlow(
        collectibleSendPreviewUseCase.getInitialStateOfCollectibleSendPreview(collectibleDetail)
    )
    val collectibleSendPreview: StateFlow<CollectibleSendPreview>
        get() = _collectibleSendPreviewFlow

    private var cachedPreviouslySignedTransaction: SignedTransactionDetail.Send? = null

    fun updateSelectedAccountAddress(address: String) {
        _selectedAccountAddressFlow.value = address
    }

    fun getSenderPublicKey() = collectibleDetail.ownerAccountAddress

    fun getSelectedAddress(): String = _selectedAccountAddressFlow.value

    fun checkIfSelectedAccountReceiveCollectible() {
        viewModelScope.launch(Dispatchers.IO) {
            collectibleSendPreviewUseCase.checkIfSelectedAccountReceiveCollectible(
                _selectedAccountAddressFlow.value,
                collectibleDetail.collectibleId,
                _collectibleSendPreviewFlow.value
            ).collect { collectibleSendPreview ->
                _collectibleSendPreviewFlow.emit(collectibleSendPreview)
            }
        }
    }

    // TODO Transaction signing & sending flow needs to be refactored
    fun getSendTransactionData(): TransactionData.Send? {
        val senderAccountCacheData = accountCacheManager
            .getCacheData(collectibleDetail.ownerAccountAddress) ?: return null
        val targetUser = TargetUser(publicKey = selectedAccountAddressFlow.value)
        return TransactionData.Send(
            accountCacheData = senderAccountCacheData,
            amount = BigInteger.ONE,
            assetInformation = AssetInformation(assetId = collectibleDetail.collectibleId, false),
            targetUser = targetUser
        )
    }

    fun sendSignedTransaction(signedTransactionDetail: SignedTransactionDetail.Send) {
        cachedPreviouslySignedTransaction = signedTransactionDetail
        viewModelScope.launch(Dispatchers.IO) {
            collectibleSendPreviewUseCase.sendSignedTransaction(
                signedTransactionDetail,
                _collectibleSendPreviewFlow.value
            ).collect { preview ->
                _collectibleSendPreviewFlow.emit(preview)
            }
        }
    }

    fun retrySendingTransaction() {
        cachedPreviouslySignedTransaction?.let { transaction ->
            sendSignedTransaction(transaction)
        }
    }

    companion object {
        private const val COLLECTIBLE_DETAIL_ARG_KEY = "collectibleDetail"
    }
}
