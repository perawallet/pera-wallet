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

package com.algorand.android.modules.swap.confirmswap.domain

import com.algorand.android.ledger.LedgerBleOperationManager
import com.algorand.android.ledger.LedgerBleSearchManager
import com.algorand.android.ledger.operations.ExternalTransaction
import com.algorand.android.modules.swap.confirmswap.domain.model.SignedSwapSingleTransactionData
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapQuoteTransaction
import com.algorand.android.modules.swap.confirmswap.domain.model.UnsignedSwapSingleTransactionData
import com.algorand.android.modules.transaction.signmanager.ExternalTransactionQueuingHelper
import com.algorand.android.modules.transaction.signmanager.ExternalTransactionSignManager
import com.algorand.android.modules.transaction.signmanager.ExternalTransactionSignResult
import com.algorand.android.usecase.AccountDetailUseCase
import javax.inject.Inject
import kotlinx.coroutines.flow.map

class SwapTransactionSignManager @Inject constructor(
    ledgerBleSearchManager: LedgerBleSearchManager,
    ledgerBleOperationManager: LedgerBleOperationManager,
    externalTransactionQueuingHelper: ExternalTransactionQueuingHelper,
    accountDetailUseCase: AccountDetailUseCase
) : ExternalTransactionSignManager<UnsignedSwapSingleTransactionData>(
    ledgerBleSearchManager,
    ledgerBleOperationManager,
    externalTransactionQueuingHelper,
    accountDetailUseCase
) {

    val swapTransactionSignResultFlow = signResultFlow.map {
        when (it) {
            is ExternalTransactionSignResult.Success<*> -> {
                swapQuoteTransaction?.run {
                    ExternalTransactionSignResult.Success<SwapQuoteTransaction>(this)
                } ?: it
            }
            else -> it
        }
    }

    private var swapQuoteTransaction: List<SwapQuoteTransaction>? = null

    fun signSwapQuoteTransaction(swapQuoteTransaction: List<SwapQuoteTransaction>) {
        this.swapQuoteTransaction = swapQuoteTransaction
        val unsignedTransactionList = swapQuoteTransaction.map { it.getTransactionsThatNeedsToBeSigned() }.flatten()
        signTransaction(unsignedTransactionList)
    }

    override fun onTransactionSigned(transaction: ExternalTransaction, signedTransaction: ByteArray?) {
        (transaction as? UnsignedSwapSingleTransactionData)?.run {
            val signedSingleTransactionData = SignedSwapSingleTransactionData(
                transaction.parentListIndex,
                transaction.transactionListIndex,
                signedTransaction
            )

            swapQuoteTransaction?.get(signedSingleTransactionData.parentListIndex)?.insertSignedTransaction(
                transaction.transactionListIndex,
                signedSingleTransactionData
            )
        }
        super.onTransactionSigned(transaction, signedTransaction)
    }
}
