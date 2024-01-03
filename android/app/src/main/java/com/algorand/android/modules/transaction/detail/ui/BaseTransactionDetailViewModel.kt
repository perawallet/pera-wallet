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

package com.algorand.android.modules.transaction.detail.ui

import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.transaction.detail.domain.model.TransactionDetailPreview
import com.algorand.android.modules.transaction.detail.domain.usecase.BaseTransactionDetailPreviewUseCase
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

abstract class BaseTransactionDetailViewModel : BaseViewModel() {

    abstract val baseTransactionDetailPreviewUseCase: BaseTransactionDetailPreviewUseCase

    abstract fun initTransactionDetailPreview()

    private val _transactionDetailPreviewFlow = MutableStateFlow<TransactionDetailPreview?>(null)
    val transactionDetailPreviewFlow: StateFlow<TransactionDetailPreview?>
        get() = _transactionDetailPreviewFlow

    suspend fun updateTransactionDetailFlow(value: TransactionDetailPreview) {
        _transactionDetailPreviewFlow.emit(value)
    }

    fun setCopyAddressTipShown() {
        baseTransactionDetailPreviewUseCase.setCopyAddressTipShown()
    }

    fun clearInnerTransactionStackCache() {
        viewModelScope.launch {
            baseTransactionDetailPreviewUseCase.clearInnerTransactionStackCache()
        }
    }

    protected companion object {
        const val TRANSACTION_ID_KEY = "transactionId"
        const val ACCOUNT_ADDRESS_KEY = "accountAddress"
        const val SHOW_CLOSE_BUTTON_KEY = "showCloseButton"
        const val TRANSACTION_KEY = "transaction"
    }
}
