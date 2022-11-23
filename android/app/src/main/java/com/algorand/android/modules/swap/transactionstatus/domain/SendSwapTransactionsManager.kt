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

package com.algorand.android.modules.swap.transactionstatus.domain

import com.algorand.android.models.SignedTransactionDetail
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapQuoteTransaction
import com.algorand.android.modules.swap.transactionstatus.ui.mapper.SignedExternalTransactionDetailMapper
import com.algorand.android.modules.transaction.confirmation.domain.usecase.TransactionConfirmationUseCase
import com.algorand.android.usecase.SendSignedTransactionUseCase
import com.algorand.android.utils.DataResource
import javax.inject.Inject
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.collectLatest

class SendSwapTransactionsManager @Inject constructor(
    private val sendSignedTransactionUseCase: SendSignedTransactionUseCase,
    private val signedExternalTransactionDetailMapper: SignedExternalTransactionDetailMapper,
    private val transactionConfirmationUseCase: TransactionConfirmationUseCase
) {

    suspend fun sendSwapTransactions(
        signedTransactions: MutableList<SwapQuoteTransaction>,
        onSendTransactionsSuccess: suspend () -> Unit,
        onSendTransactionsFailed: suspend (DataResource.Error<String>?) -> Unit
    ) {
        val signedSwapQuoteTransaction = signedTransactions.removeFirstOrNull()
        if (signedSwapQuoteTransaction == null) {
            onSendTransactionsSuccess()
            return
        }
        val signedTransactionByteArray = signedSwapQuoteTransaction.getSignedTransactionsByteArray() ?: run {
            onSendTransactionsFailed(DataResource.Error.Local(IllegalArgumentException()))
            return
        }
        val signedTransactionDetail = signedExternalTransactionDetailMapper
            .mapToExternalTransaction(signedTransactionByteArray)
        sendTransaction(
            signedTransactionDetail = signedTransactionDetail,
            remainingTransactionsToSend = signedTransactions,
            isConfirmationNeed = signedSwapQuoteTransaction.isTransactionConfirmationNeed,
            delayAfterConfirmation = signedSwapQuoteTransaction.delayAfterConfirmation,
            onSendTransactionsSuccess = onSendTransactionsSuccess,
            onSendTransactionsFailed = onSendTransactionsFailed
        )
    }

    private suspend fun sendTransaction(
        signedTransactionDetail: SignedTransactionDetail,
        remainingTransactionsToSend: MutableList<SwapQuoteTransaction>,
        isConfirmationNeed: Boolean,
        delayAfterConfirmation: Long?,
        onSendTransactionsSuccess: suspend () -> Unit,
        onSendTransactionsFailed: suspend (DataResource.Error<String>?) -> Unit
    ) {
        sendSignedTransactionUseCase.sendSignedTransaction(signedTransactionDetail).collectLatest {
            it.useSuspended(
                onSuccess = { txnId ->
                    if (isConfirmationNeed) {
                        waitForTransactionFormation(
                            txnId = txnId,
                            delayAfterConfirmation = delayAfterConfirmation,
                            remainingTransactionsToSend = remainingTransactionsToSend,
                            onSendTransactionsSuccess = onSendTransactionsSuccess,
                            onSendTransactionsFailed = onSendTransactionsFailed
                        )
                    } else {
                        sendSwapTransactions(
                            signedTransactions = remainingTransactionsToSend,
                            onSendTransactionsSuccess = onSendTransactionsSuccess,
                            onSendTransactionsFailed = onSendTransactionsFailed
                        )
                    }
                },
                onFailed = { errorDataResource ->
                    onSendTransactionsFailed(errorDataResource)
                }
            )
        }
    }

    private suspend fun waitForTransactionFormation(
        txnId: String,
        delayAfterConfirmation: Long?,
        remainingTransactionsToSend: MutableList<SwapQuoteTransaction>,
        onSendTransactionsSuccess: suspend () -> Unit,
        onSendTransactionsFailed: suspend (DataResource.Error<String>?) -> Unit
    ) {
        transactionConfirmationUseCase.waitForConfirmation(txnId).collectLatest {
            it.useSuspended(
                onSuccess = {
                    if (delayAfterConfirmation != null) {
                        delay(delayAfterConfirmation)
                    }
                    sendSwapTransactions(
                        remainingTransactionsToSend,
                        onSendTransactionsSuccess,
                        onSendTransactionsFailed
                    )
                },
                onFailed = {
                    onSendTransactionsFailed(DataResource.Error.Api(it.exception ?: Exception(), it.code))
                }
            )
        }
    }
}
