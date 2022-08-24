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

package com.algorand.android.modules.transaction.detail.ui.innertransaction

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.transaction.detail.domain.usecase.InnerTransactionDetailPreviewUseCase
import com.algorand.android.modules.transaction.detail.ui.BaseTransactionDetailViewModel
import com.algorand.android.utils.getOrThrow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class InnerTransactionDetailViewModel @ViewModelInject constructor(
    override val baseTransactionDetailPreviewUseCase: InnerTransactionDetailPreviewUseCase,
    @Assisted savedStateHandle: SavedStateHandle
) : BaseTransactionDetailViewModel() {

    val publicKey = savedStateHandle.getOrThrow<String>(PUBLIC_KEY)
    val transactionId = savedStateHandle.getOrThrow<String>(TRANSACTION_ID_KEY)

    init {
        initTransactionDetailPreview()
    }

    fun popInnerTransactionFromStackCache() {
        viewModelScope.launch {
            baseTransactionDetailPreviewUseCase.popInnerTransactionFromStackCache()
        }
    }

    override fun initTransactionDetailPreview() {
        viewModelScope.launch {
            baseTransactionDetailPreviewUseCase.getTransactionDetailPreview(
                publicKey = publicKey,
                transactions = baseTransactionDetailPreviewUseCase.peekInnerTransactionFromCache()
            ).collect {
                updateTransactionDetailFlow(it)
            }
        }
    }
}
