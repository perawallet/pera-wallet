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

import com.algorand.android.modules.transaction.common.domain.model.TransactionDTO
import com.algorand.android.modules.transactionhistory.domain.model.BaseTransaction
import com.algorand.android.utils.getAllNestedTransactions
import com.algorand.android.utils.getZonedDateTimeFromTimeStamp
import java.math.BigInteger
import javax.inject.Inject

class BaseTransactionMapper @Inject constructor() {
    fun mapToPayTransactionSend(
        transaction: TransactionDTO
    ): BaseTransaction.Transaction.Pay.Send {
        return with(transaction) {
            BaseTransaction.Transaction.Pay.Send(
                id = id,
                signature = signature?.signatureKey,
                senderAddress = senderAddress.orEmpty(),
                receiverAddress = payment?.receiverAddress,
                zonedDateTime = roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp(),
                isPending = false,
                amount = payment?.amount ?: BigInteger.ZERO
            )
        }
    }

    fun mapToPayTransactionReceive(
        transaction: TransactionDTO
    ): BaseTransaction.Transaction.Pay.Receive {
        return with(transaction) {
            BaseTransaction.Transaction.Pay.Receive(
                id = id,
                signature = signature?.signatureKey,
                senderAddress = senderAddress.orEmpty(),
                receiverAddress = payment?.receiverAddress,
                zonedDateTime = roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp(),
                isPending = false,
                amount = payment?.amount ?: BigInteger.ZERO
            )
        }
    }

    fun mapToPayTransactionSelf(
        transaction: TransactionDTO
    ): BaseTransaction.Transaction.Pay.Self {
        return with(transaction) {
            BaseTransaction.Transaction.Pay.Self(
                id = id,
                signature = signature?.signatureKey,
                senderAddress = senderAddress.orEmpty(),
                receiverAddress = payment?.receiverAddress,
                zonedDateTime = roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp(),
                isPending = false,
                amount = payment?.amount ?: BigInteger.ZERO
            )
        }
    }

    fun mapToAssetTransactionSend(
        transaction: TransactionDTO
    ): BaseTransaction.Transaction.AssetTransfer.Send? {
        return with(transaction) {
            val assetId = assetTransfer?.assetId ?: return null
            BaseTransaction.Transaction.AssetTransfer.Send(
                id = id,
                signature = signature?.signatureKey,
                senderAddress = senderAddress.orEmpty(),
                receiverAddress = assetTransfer.receiverAddress,
                zonedDateTime = roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp(),
                isPending = false,
                amount = assetTransfer.amount ?: BigInteger.ZERO,
                assetId = assetId
            )
        }
    }

    fun mapToAssetTransactionReceive(
        transaction: TransactionDTO
    ): BaseTransaction.Transaction.AssetTransfer.BaseReceive.Receive? {
        return with(transaction) {
            val assetId = assetTransfer?.assetId ?: return null
            BaseTransaction.Transaction.AssetTransfer.BaseReceive.Receive(
                id = id,
                signature = signature?.signatureKey,
                senderAddress = senderAddress.orEmpty(),
                receiverAddress = assetTransfer.receiverAddress,
                zonedDateTime = roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp(),
                isPending = false,
                amount = assetTransfer.amount ?: BigInteger.ZERO,
                assetId = assetId
            )
        }
    }

    fun mapToAssetTransactionReceiveOptOut(
        transaction: TransactionDTO
    ): BaseTransaction.Transaction.AssetTransfer.BaseReceive.ReceiveOptOut? {
        return with(transaction) {
            val assetId = assetTransfer?.assetId ?: return null
            BaseTransaction.Transaction.AssetTransfer.BaseReceive.ReceiveOptOut(
                id = id,
                signature = signature?.signatureKey,
                senderAddress = senderAddress.orEmpty(),
                receiverAddress = assetTransfer.receiverAddress,
                zonedDateTime = roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp(),
                isPending = false,
                amount = assetTransfer.amount ?: BigInteger.ZERO,
                assetId = assetId
            )
        }
    }

    fun mapToAssetTransactionOptOut(
        transaction: TransactionDTO,
        closeToAddress: String,
    ): BaseTransaction.Transaction.AssetTransfer.OptOut? {
        return with(transaction) {
            val assetId = assetTransfer?.assetId ?: return null
            BaseTransaction.Transaction.AssetTransfer.OptOut(
                id = id,
                signature = signature?.signatureKey,
                senderAddress = senderAddress.orEmpty(),
                receiverAddress = assetTransfer.receiverAddress,
                zonedDateTime = roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp(),
                isPending = false,
                amount = assetTransfer.amount ?: BigInteger.ZERO,
                assetId = assetId,
                closeToAddress = closeToAddress
            )
        }
    }

    fun mapToAssetTransactionSelf(
        transaction: TransactionDTO,
    ): BaseTransaction.Transaction.AssetTransfer.BaseSelf.Self? {
        return with(transaction) {
            val assetId = assetTransfer?.assetId ?: return null
            BaseTransaction.Transaction.AssetTransfer.BaseSelf.Self(
                id = id,
                signature = signature?.signatureKey,
                senderAddress = senderAddress.orEmpty(),
                receiverAddress = assetTransfer.receiverAddress,
                zonedDateTime = roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp(),
                isPending = false,
                amount = assetTransfer.amount ?: BigInteger.ZERO,
                assetId = assetId
            )
        }
    }

    fun mapToAssetTransactionSelfOptIn(
        transaction: TransactionDTO,
    ): BaseTransaction.Transaction.AssetTransfer.BaseSelf.SelfOptIn? {
        return with(transaction) {
            val assetId = assetTransfer?.assetId ?: return null
            BaseTransaction.Transaction.AssetTransfer.BaseSelf.SelfOptIn(
                id = id,
                signature = signature?.signatureKey,
                senderAddress = senderAddress.orEmpty(),
                receiverAddress = assetTransfer.receiverAddress,
                zonedDateTime = roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp(),
                isPending = false,
                amount = assetTransfer.amount ?: BigInteger.ZERO,
                assetId = assetId
            )
        }
    }

    fun mapToAssetConfiguration(
        transaction: TransactionDTO
    ): BaseTransaction.Transaction.AssetConfiguration {
        return with(transaction) {
            BaseTransaction.Transaction.AssetConfiguration(
                id = id,
                signature = signature?.signatureKey,
                senderAddress = senderAddress.orEmpty(),
                receiverAddress = null, // Asset Configuration Transaction does not contain receiver address
                zonedDateTime = roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp(),
                isPending = false,
                assetId = createdAssetIndex ?: assetConfiguration?.assetId
            )
        }
    }

    fun mapToApplicationCall(
        transaction: TransactionDTO
    ): BaseTransaction.Transaction.ApplicationCall {
        return with(transaction) {
            BaseTransaction.Transaction.ApplicationCall(
                id = id,
                signature = signature?.signatureKey,
                senderAddress = senderAddress.orEmpty(),
                receiverAddress = null, // Application Call Transaction does not contain receiver address
                zonedDateTime = roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp(),
                isPending = false,
                applicationId = applicationCall?.applicationId,
                innerTransactionCount = getAllNestedTransactions(this).count(),
                foreignAssetIds = applicationCall?.foreignAssets
            )
        }
    }

    fun mapToUndefined(
        transaction: TransactionDTO
    ): BaseTransaction.Transaction.Undefined {
        return with(transaction) {
            BaseTransaction.Transaction.Undefined(
                id = id,
                signature = signature?.signatureKey,
                senderAddress = senderAddress.orEmpty(),
                receiverAddress = null, // Undefined Transaction does not contain receiver address
                zonedDateTime = roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp(),
                isPending = false
            )
        }
    }

    fun mapToTransactionDateTitle(date: String): BaseTransaction.TransactionDateTitle {
        return BaseTransaction.TransactionDateTitle(date)
    }
}
