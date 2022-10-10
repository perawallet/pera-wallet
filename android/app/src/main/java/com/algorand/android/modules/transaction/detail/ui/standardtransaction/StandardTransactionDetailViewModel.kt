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

package com.algorand.android.modules.transaction.detail.ui.standardtransaction

import javax.inject.Inject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.transaction.detail.domain.model.BaseTransactionDetail
import com.algorand.android.modules.transaction.detail.domain.usecase.StandardTransactionDetailPreviewUseCase
import com.algorand.android.modules.transaction.detail.ui.BaseTransactionDetailViewModel
import com.algorand.android.utils.getOrElse
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

@HiltViewModel
class StandardTransactionDetailViewModel @Inject constructor(
    override val baseTransactionDetailPreviewUseCase: StandardTransactionDetailPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseTransactionDetailViewModel() {

    val transactionId = savedStateHandle.getOrThrow<String>(TRANSACTION_ID_KEY)
    val accountAddress = savedStateHandle.getOrThrow<String>(ACCOUNT_ADDRESS_KEY)
    private val transaction = savedStateHandle.getOrElse<BaseTransactionDetail?>(TRANSACTION_KEY, null)
    val shouldShowCloseButton = savedStateHandle.getOrElse(SHOW_CLOSE_BUTTON_KEY, false)

    init {
        if (transaction != null) {
            createTransactionDetailFromExistingModel(transaction)
        } else {
            initTransactionDetailPreview()
        }
    }

    override fun initTransactionDetailPreview() {
        viewModelScope.launch {
            baseTransactionDetailPreviewUseCase.getTransactionDetailPreview(
                transactionId = transactionId,
                publicKey = accountAddress,
                isInnerTransaction = false
            ).collect {
                updateTransactionDetailFlow(it)
            }
        }
    }

    private fun createTransactionDetailFromExistingModel(transaction: BaseTransactionDetail) {
        viewModelScope.launch {
            updateTransactionDetailFlow(
                baseTransactionDetailPreviewUseCase.createTransactionDetailListItems(
                    baseTransactionDetail = transaction,
                    publicKey = accountAddress,
                    transactionId = transactionId,
                    isInnerTransaction = true
                )
            )
        }
    }
}
