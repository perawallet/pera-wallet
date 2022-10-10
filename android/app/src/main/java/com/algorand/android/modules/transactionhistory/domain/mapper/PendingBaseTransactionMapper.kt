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

package com.algorand.android.modules.transactionhistory.domain.mapper

import com.algorand.android.modules.transactionhistory.domain.model.BaseTransaction
import com.algorand.android.modules.transactionhistory.domain.model.PendingTransactionDTO
import java.math.BigInteger
import java.time.ZonedDateTime
import javax.inject.Inject

class PendingBaseTransactionMapper @Inject constructor() {
    fun mapToPayTransactionSend(
        transaction: PendingTransactionDTO,
        senderAddress: String?,
        receiverAddress: String?,
        amount: BigInteger
    ): BaseTransaction.Transaction.Pay.Send {
        return with(transaction) {
            BaseTransaction.Transaction.Pay.Send(
                id = null,
                signature = signatureKey,
                senderAddress = senderAddress,
                receiverAddress = receiverAddress,
                zonedDateTime = ZonedDateTime.now(),
                isPending = true,
                amount = amount
            )
        }
    }

    fun mapToPayTransactionReceive(
        transaction: PendingTransactionDTO,
        senderAddress: String?,
        receiverAddress: String?,
        amount: BigInteger
    ): BaseTransaction.Transaction.Pay.Receive {
        return with(transaction) {
            BaseTransaction.Transaction.Pay.Receive(
                id = null,
                signature = signatureKey,
                senderAddress = senderAddress,
                receiverAddress = receiverAddress,
                zonedDateTime = ZonedDateTime.now(),
                isPending = true,
                amount = amount
            )
        }
    }

    fun mapToAssetTransactionSend(
        transaction: PendingTransactionDTO,
        senderAddress: String?,
        receiverAddress: String?,
        amount: BigInteger,
        assetId: Long
    ): BaseTransaction.Transaction.AssetTransfer.Send {
        return with(transaction) {
            BaseTransaction.Transaction.AssetTransfer.Send(
                id = null,
                signature = signatureKey,
                senderAddress = senderAddress,
                receiverAddress = receiverAddress,
                zonedDateTime = ZonedDateTime.now(),
                isPending = true,
                amount = amount,
                assetId = assetId
            )
        }
    }

    fun mapToAssetTransactionReceive(
        transaction: PendingTransactionDTO,
        senderAddress: String?,
        receiverAddress: String?,
        amount: BigInteger,
        assetId: Long
    ): BaseTransaction.Transaction.AssetTransfer.BaseReceive.Receive {
        return with(transaction) {
            BaseTransaction.Transaction.AssetTransfer.BaseReceive.Receive(
                id = null,
                signature = signatureKey,
                senderAddress = senderAddress,
                receiverAddress = receiverAddress,
                zonedDateTime = ZonedDateTime.now(),
                isPending = true,
                amount = amount,
                assetId = assetId
            )
        }
    }

    fun mapToAssetConfiguration(
        transaction: PendingTransactionDTO,
        senderAddress: String?,
        receiverAddress: String?
    ): BaseTransaction.Transaction.AssetConfiguration {
        return with(transaction) {
            BaseTransaction.Transaction.AssetConfiguration(
                id = null,
                signature = signatureKey,
                senderAddress = senderAddress,
                receiverAddress = receiverAddress,
                zonedDateTime = ZonedDateTime.now(),
                isPending = true,
                assetId = detail?.assetId
            )
        }
    }

    // We're not receiving app call from pending transaction endpoint
    fun mapToApplicationCall(
        transaction: PendingTransactionDTO,
        senderAddress: String?,
        receiverAddress: String?
    ): BaseTransaction.Transaction.ApplicationCall {
        return with(transaction) {
            BaseTransaction.Transaction.ApplicationCall(
                id = null,
                signature = signatureKey,
                senderAddress = senderAddress,
                receiverAddress = receiverAddress,
                zonedDateTime = ZonedDateTime.now(),
                isPending = true,
                applicationId = null,
                innerTransactionCount = 0,
                foreignAssetIds = null
            )
        }
    }

    fun mapToUndefined(
        transaction: PendingTransactionDTO,
        senderAddress: String?,
        receiverAddress: String?
    ): BaseTransaction.Transaction.Undefined {
        return with(transaction) {
            BaseTransaction.Transaction.Undefined(
                id = null,
                signature = signatureKey,
                senderAddress = senderAddress,
                receiverAddress = receiverAddress,
                zonedDateTime = ZonedDateTime.now(),
                isPending = true
            )
        }
    }

    fun mapToTransactionDateTitle(date: String): BaseTransaction.TransactionDateTitle {
        return BaseTransaction.TransactionDateTitle(date)
    }
}
