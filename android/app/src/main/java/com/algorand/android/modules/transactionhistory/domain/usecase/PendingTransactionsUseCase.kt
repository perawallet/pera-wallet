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

package com.algorand.android.modules.transactionhistory.domain.usecase

import com.algorand.android.core.BaseUseCase
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.Result
import com.algorand.android.modules.transactionhistory.domain.mapper.PendingBaseTransactionMapper
import com.algorand.android.modules.transactionhistory.domain.model.BaseTransaction
import com.algorand.android.modules.transactionhistory.domain.model.PendingTransactionDTO
import com.algorand.android.modules.transaction.common.domain.model.TransactionTypeDTO
import com.algorand.android.modules.transactionhistory.domain.repository.PendingTransactionsRepository
import javax.inject.Inject
import javax.inject.Named

class PendingTransactionsUseCase @Inject constructor(
    @Named(PendingTransactionsRepository.INJECTION_NAME)
    private val pendingTransactionsRepository: PendingTransactionsRepository,
    private val pendingBaseTransactionMapper: PendingBaseTransactionMapper
) : BaseUseCase() {

    @SuppressWarnings("LongMethod")
    suspend fun fetchPendingTransactions(
        publicKey: String,
        assetId: Long? = null
    ): Result<List<BaseTransaction.Transaction>> {
        return pendingTransactionsRepository.getPendingTransactions(publicKey, assetId).map { transactionList ->
            transactionList.map { pendingTransaction ->
                val receiverAddress = pendingTransaction.getReceiverAddress()
                val senderAddress = pendingTransaction.detail?.senderAddress.orEmpty()
                when (pendingTransaction.detail?.transactionType) {
                    TransactionTypeDTO.PAY_TRANSACTION -> {
                        createBasePayTransaction(
                            pendingTransaction = pendingTransaction,
                            publicKey = publicKey,
                            senderAddress = senderAddress,
                            receiverAddress = receiverAddress
                        )
                    }
                    TransactionTypeDTO.ASSET_TRANSACTION -> {
                        createBaseAssetTransferTransaction(
                            pendingTransaction = pendingTransaction,
                            publicKey = publicKey,
                            senderAddress = senderAddress,
                            receiverAddress = receiverAddress
                        )
                    }
                    TransactionTypeDTO.ASSET_CONFIGURATION -> {
                        pendingBaseTransactionMapper.mapToAssetConfiguration(
                            transaction = pendingTransaction,
                            senderAddress = senderAddress,
                            receiverAddress = receiverAddress
                        )
                    }
                    TransactionTypeDTO.APP_TRANSACTION -> {
                        pendingBaseTransactionMapper.mapToApplicationCall(
                            transaction = pendingTransaction,
                            senderAddress = senderAddress,
                            receiverAddress = receiverAddress
                        )
                    }
                    else -> {
                        pendingBaseTransactionMapper.mapToUndefined(
                            transaction = pendingTransaction,
                            senderAddress = senderAddress,
                            receiverAddress = receiverAddress
                        )
                    }
                }
            }
        }
    }

    private fun isSendTransaction(transaction: PendingTransactionDTO, accountPublicKey: String): Boolean? {
        with(transaction) {
            val receiverAddress = getReceiverAddress()
            return when {
                detail?.senderAddress == accountPublicKey && receiverAddress == accountPublicKey -> {
                    null
                }
                receiverAddress == accountPublicKey -> {
                    false
                }
                else -> {
                    true
                }
            }
        }
    }

    private fun createBasePayTransaction(
        pendingTransaction: PendingTransactionDTO,
        publicKey: String,
        senderAddress: String,
        receiverAddress: String
    ): BaseTransaction.Transaction.Pay {
        return if (isSendTransaction(pendingTransaction, publicKey) == true) {
            pendingBaseTransactionMapper.mapToPayTransactionSend(
                transaction = pendingTransaction,
                senderAddress = senderAddress,
                receiverAddress = receiverAddress,
                amount = pendingTransaction.getAmount()
            )
        } else {
            pendingBaseTransactionMapper.mapToPayTransactionReceive(
                transaction = pendingTransaction,
                senderAddress = senderAddress,
                receiverAddress = receiverAddress,
                amount = pendingTransaction.getAmount()
            )
        }
    }

    private fun createBaseAssetTransferTransaction(
        pendingTransaction: PendingTransactionDTO,
        publicKey: String,
        senderAddress: String,
        receiverAddress: String
    ): BaseTransaction.Transaction.AssetTransfer {
        val assetId = pendingTransaction.getAssetId() ?: AssetInformation.ALGO_ID
        return if (isSendTransaction(pendingTransaction, publicKey) == true) {
            pendingBaseTransactionMapper.mapToAssetTransactionSend(
                transaction = pendingTransaction,
                senderAddress = senderAddress,
                receiverAddress = receiverAddress,
                amount = pendingTransaction.getAmount(),
                assetId = assetId
            )
        } else {
            pendingBaseTransactionMapper.mapToAssetTransactionReceive(
                transaction = pendingTransaction,
                senderAddress = senderAddress,
                receiverAddress = receiverAddress,
                amount = pendingTransaction.getAmount(),
                assetId = assetId
            )
        }
    }
}
