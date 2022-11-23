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

package com.algorand.android.modules.swap.confirmswap.domain.factory

import com.algorand.android.modules.swap.confirmswap.domain.mapper.SwapOptInTransactionMapper
import com.algorand.android.modules.swap.confirmswap.domain.mapper.SwapPeraFeeTransactionMapper
import com.algorand.android.modules.swap.confirmswap.domain.mapper.SwapSwapTransactionMapper
import com.algorand.android.modules.swap.confirmswap.domain.model.SignedSwapSingleTransactionData
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapQuoteTransaction
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapTransactionPurpose
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapTransactionPurpose.OPT_IN
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapTransactionPurpose.PERA_FEE
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapTransactionPurpose.SWAP
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapTransactionPurpose.UNKNOWN
import com.algorand.android.modules.swap.confirmswap.domain.model.UnsignedSwapSingleTransactionData
import javax.inject.Inject

class SwapTransactionItemFactory @Inject constructor(
    private val swapOptInTransactionMapper: SwapOptInTransactionMapper,
    private val swapSwapTransactionMapper: SwapSwapTransactionMapper,
    private val swapPeraFeeTransactionMapper: SwapPeraFeeTransactionMapper
) {

    fun createTransaction(
        purpose: SwapTransactionPurpose,
        transactionGroupId: String?,
        unsignedTransactions: List<UnsignedSwapSingleTransactionData>,
        signedTransactions: MutableList<SignedSwapSingleTransactionData>,
        transactionNetworkSlug: String
    ): SwapQuoteTransaction {
        return when (purpose) {
            OPT_IN -> {
                swapOptInTransactionMapper.mapToOptInTxn(
                    transactionGroupId = transactionGroupId,
                    unsignedTransactions = unsignedTransactions,
                    signedTransactions = signedTransactions,
                    transactionNodeNetworkSlug = transactionNetworkSlug
                )
            }
            SWAP -> {
                swapSwapTransactionMapper.mapToSwapTxn(
                    transactionGroupId = transactionGroupId,
                    unsignedTransactions = unsignedTransactions,
                    signedTransactions = signedTransactions,
                    transactionNodeNetworkSlug = transactionNetworkSlug
                )
            }
            PERA_FEE -> {
                swapPeraFeeTransactionMapper.mapToFeeTxn(
                    transactionGroupId = transactionGroupId,
                    unsignedTransactions = unsignedTransactions,
                    signedTransactions = signedTransactions,
                    transactionNodeNetworkSlug = transactionNetworkSlug
                )
            }
            UNKNOWN -> SwapQuoteTransaction.InvalidTransaction
        }
    }
}
