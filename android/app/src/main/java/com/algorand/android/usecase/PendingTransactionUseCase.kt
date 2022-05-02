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

package com.algorand.android.usecase

import com.algorand.android.R
import com.algorand.android.decider.TransactionUserUseCase
import com.algorand.android.mapper.AccountHistoryPendingItemMapper
import com.algorand.android.models.AssetDetail
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.BaseTransactionItem
import com.algorand.android.models.PendingTransaction
import com.algorand.android.models.Result
import com.algorand.android.models.TransactionType
import com.algorand.android.repository.AccountRepository
import javax.inject.Inject

class PendingTransactionUseCase @Inject constructor(
    private val accountRepository: AccountRepository,
    private val accountHistoryPendingItemMapper: AccountHistoryPendingItemMapper,
    private val transactionUserUseCase: TransactionUserUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase
) {

    val pendingFlowDistinctUntilChangedListener: (
        oldTransactions: List<BaseTransactionItem>?,
        newTransactions: List<BaseTransactionItem>?
    ) -> Boolean = { oldTransactions, newTransactions ->
        newTransactions?.filterIsInstance<BaseTransactionItem.TransactionItem>()?.any { new ->
            oldTransactions?.filterIsInstance<BaseTransactionItem.TransactionItem>()?.any { old ->
                old.isSameTransaction(new)
            } == true
        } == true
    }

    suspend fun fetchPendingTransactions(publicKey: String, assetId: Long? = null): Result<List<BaseTransactionItem>> {
        return accountRepository.getPendingTransactions(publicKey).map { pendingTransactionResponse ->
            val transactionItems = mutableListOf<BaseTransactionItem>()

            pendingTransactionResponse.pendingTransactions
                ?.filter { if (assetId == null) true else it.getAssetId() == assetId }
                ?.ifEmpty { return@map emptyList<BaseTransactionItem>() }
                ?.let {
                    transactionItems.add(createPendingTransactionTitleItem())
                    transactionItems.addAll(createPendingTransactionItems(publicKey, it))
                }
            transactionItems
        }
    }

    private fun createPendingTransactionTitleItem(): BaseTransactionItem.ResourceTitleItem {
        return BaseTransactionItem.ResourceTitleItem(R.string.pending_transactions)
    }

    private suspend fun createPendingTransactionItems(
        publicKey: String,
        pendingTransactions: List<PendingTransaction>
    ): List<BaseTransactionItem.TransactionItem.Pending> {
        return pendingTransactions.map { pendingTransaction ->
            val assetId = when (pendingTransaction.detail?.transactionType) {
                TransactionType.PAY_TRANSACTION -> AssetInformation.ALGORAND_ID
                else -> pendingTransaction.detail?.assetId
            }
            accountHistoryPendingItemMapper.mapTo(
                transaction = pendingTransaction,
                accountPublicKey = publicKey,
                transactionTargetUser = transactionUserUseCase.getTransactionTargetUser(publicKey),
                assetDetail = getAssetDetail(assetId),
                otherPublicKey = getOtherPublicKey(pendingTransaction, publicKey)
            )
        }
    }

    private fun getOtherPublicKey(pendingTransaction: PendingTransaction, publicKey: String): String {
        val receiverAddress = pendingTransaction.getReceiverAddress()
        return if (receiverAddress == publicKey) {
            pendingTransaction.detail?.senderAddress.orEmpty()
        } else {
            receiverAddress
        }
    }

    private fun getAssetDetail(assetId: Long?): AssetDetail? {
        if (assetId == null) return null
        return simpleAssetDetailUseCase.getCachedAssetDetail(assetId)?.data
    }
}
