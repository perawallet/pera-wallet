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

package com.algorand.android.transactiondetail.ui

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.transactiondetail.domain.model.TransactionDetailPreview
import com.algorand.android.transactiondetail.domain.usecase.TransactionDetailPreviewUseCase
import com.algorand.android.utils.getOrElse
import com.algorand.android.utils.getOrThrow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class TransactionDetailViewModel @ViewModelInject constructor(
    private val transactionDetailPreviewUseCase: TransactionDetailPreviewUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val isRewardTransaction = savedStateHandle.getOrElse<Boolean>(IS_REWARD_TRANSACTION_KEY, false)
    private val transactionId = savedStateHandle.getOrThrow<String>(TRANSACTION_ID_KEY)
    private val publicKey = savedStateHandle.getOrThrow<String>(PUBLIC_KEY)

    private val _transactionDetailPreviewFlow = MutableStateFlow<TransactionDetailPreview?>(null)
    val transactionDetailPreviewFlow: StateFlow<TransactionDetailPreview?>
        get() = _transactionDetailPreviewFlow

    init {
        initTransactionDetailPreview()
    }

    private fun initTransactionDetailPreview() {
        viewModelScope.launch {
            transactionDetailPreviewUseCase.getTransactionDetailPreview(
                transactionId = transactionId,
                publicKey = publicKey,
                isRewardTransaction = isRewardTransaction
            ).collect {
                _transactionDetailPreviewFlow.emit(it)
            }
        }
    }

    fun setCopyAddressTipShown() {
        transactionDetailPreviewUseCase.setCopyAddressTipShown()
    }

    companion object {
        private const val IS_REWARD_TRANSACTION_KEY = "isRewardTransaction"
        private const val TRANSACTION_ID_KEY = "transactionId"
        private const val PUBLIC_KEY = "publicKey"
    }
}
