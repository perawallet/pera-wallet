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

package com.algorand.android.modules.transactionhistory.ui.mapper

import com.algorand.android.modules.transactionhistory.domain.model.BaseTransaction
import com.algorand.android.modules.transactionhistory.ui.model.BaseTransactionItem
import com.algorand.android.utils.extensions.addHashtagToStart
import javax.inject.Inject

class TransactionItemMapper @Inject constructor() {
    fun mapToPayTransactionSendItem(
        transaction: BaseTransaction.Transaction.Pay.Send,
        description: String?,
        formattedAmount: String?,
        amountColorRes: Int?
    ): BaseTransactionItem.TransactionItem.PayItem.PaySendItem {
        return with(transaction) {
            BaseTransactionItem.TransactionItem.PayItem.PaySendItem(
                id = id,
                signature = signature,
                description = description,
                isPending = isPending,
                formattedAmount = formattedAmount,
                amountColorRes = amountColorRes
            )
        }
    }

    fun mapToPayTransactionReceiveItem(
        transaction: BaseTransaction.Transaction.Pay.Receive,
        description: String?,
        formattedAmount: String?,
        amountColorRes: Int?
    ): BaseTransactionItem.TransactionItem.PayItem.PayReceiveItem {
        return with(transaction) {
            BaseTransactionItem.TransactionItem.PayItem.PayReceiveItem(
                id = id,
                signature = signature,
                description = description,
                isPending = isPending,
                formattedAmount = formattedAmount,
                amountColorRes = amountColorRes
            )
        }
    }

    fun mapToPayTransactionSelfItem(
        transaction: BaseTransaction.Transaction.Pay.Self,
        description: String?,
        formattedAmount: String?,
        amountColorRes: Int?
    ): BaseTransactionItem.TransactionItem.PayItem.PaySelfItem {
        return with(transaction) {
            BaseTransactionItem.TransactionItem.PayItem.PaySelfItem(
                id = id,
                signature = signature,
                description = description,
                isPending = isPending,
                formattedAmount = formattedAmount,
                amountColorRes = amountColorRes
            )
        }
    }

    fun mapToAssetTransactionSendItem(
        transaction: BaseTransaction.Transaction.AssetTransfer.BaseSend.Send,
        description: String?,
        formattedAmount: String?,
        amountColorRes: Int?
    ): BaseTransactionItem.TransactionItem.AssetTransferItem.BaseAssetSendItem.AssetSendItem {
        return with(transaction) {
            BaseTransactionItem.TransactionItem.AssetTransferItem.BaseAssetSendItem.AssetSendItem(
                id = id,
                signature = signature,
                description = description,
                isPending = isPending,
                formattedAmount = formattedAmount,
                amountColorRes = amountColorRes
            )
        }
    }

    fun mapToAssetTransactionSendOptOutItem(
        transaction: BaseTransaction.Transaction.AssetTransfer.BaseSend.SendOptOut,
        description: String?,
        formattedAmount: String?,
        amountColorRes: Int?
    ): BaseTransactionItem.TransactionItem.AssetTransferItem.BaseAssetSendItem.AssetSendOptOutItem {
        return with(transaction) {
            BaseTransactionItem.TransactionItem.AssetTransferItem.BaseAssetSendItem.AssetSendOptOutItem(
                id = id,
                signature = signature,
                description = description,
                isPending = isPending,
                formattedAmount = formattedAmount,
                amountColorRes = amountColorRes
            )
        }
    }

    fun mapToAssetTransactionReceiveItem(
        transaction: BaseTransaction.Transaction.AssetTransfer.BaseReceive.Receive,
        description: String?,
        formattedAmount: String?,
        amountColorRes: Int?
    ): BaseTransactionItem.TransactionItem.AssetTransferItem.BaseReceiveItem.AssetReceiveItem {
        return with(transaction) {
            BaseTransactionItem.TransactionItem.AssetTransferItem.BaseReceiveItem.AssetReceiveItem(
                id = id,
                signature = signature,
                description = description,
                isPending = isPending,
                formattedAmount = formattedAmount,
                amountColorRes = amountColorRes
            )
        }
    }

    fun mapToAssetTransactionReceiveOptOutItem(
        transaction: BaseTransaction.Transaction.AssetTransfer.BaseReceive.ReceiveOptOut,
        description: String?,
        formattedAmount: String?,
        amountColorRes: Int?
    ): BaseTransactionItem.TransactionItem.AssetTransferItem.BaseReceiveItem.AssetReceiveOptOutItem {
        return with(transaction) {
            BaseTransactionItem.TransactionItem.AssetTransferItem.BaseReceiveItem.AssetReceiveOptOutItem(
                id = id,
                signature = signature,
                description = description,
                isPending = isPending,
                formattedAmount = formattedAmount,
                amountColorRes = amountColorRes
            )
        }
    }

    fun mapToAssetTransactionOptOutItem(
        transaction: BaseTransaction.Transaction.AssetTransfer.OptOut,
        description: String?,
        formattedAmount: String?,
        amountColorRes: Int?
    ): BaseTransactionItem.TransactionItem.AssetTransferItem.AssetOptOutItem {
        return with(transaction) {
            BaseTransactionItem.TransactionItem.AssetTransferItem.AssetOptOutItem(
                id = id,
                signature = signature,
                description = description,
                isPending = isPending,
                formattedAmount = formattedAmount,
                amountColorRes = amountColorRes,
                closeToAddress = transaction.closeToAddress
            )
        }
    }

    fun mapToAssetTransactionSelfItem(
        transaction: BaseTransaction.Transaction.AssetTransfer.BaseSelf.Self,
        description: String?,
        formattedAmount: String?,
        amountColorRes: Int?
    ): BaseTransactionItem.TransactionItem.AssetTransferItem.BaseSelfItem.AssetSelfItem {
        return with(transaction) {
            BaseTransactionItem.TransactionItem.AssetTransferItem.BaseSelfItem.AssetSelfItem(
                id = id,
                signature = signature,
                description = description,
                isPending = isPending,
                formattedAmount = formattedAmount,
                amountColorRes = amountColorRes
            )
        }
    }

    fun mapToAssetTransactionSelfOptInItem(
        transaction: BaseTransaction.Transaction.AssetTransfer.BaseSelf.SelfOptIn,
        description: String?,
        formattedAmount: String?,
        amountColorRes: Int?
    ): BaseTransactionItem.TransactionItem.AssetTransferItem.BaseSelfItem.AssetSelfOptInItem {
        return with(transaction) {
            BaseTransactionItem.TransactionItem.AssetTransferItem.BaseSelfItem.AssetSelfOptInItem(
                id = id,
                signature = signature,
                description = description,
                isPending = isPending,
                formattedAmount = formattedAmount,
                amountColorRes = amountColorRes
            )
        }
    }

    fun mapToAssetConfigurationItem(
        transaction: BaseTransaction.Transaction.AssetConfiguration
    ): BaseTransactionItem.TransactionItem.AssetConfigurationItem {
        return with(transaction) {
            BaseTransactionItem.TransactionItem.AssetConfigurationItem(
                id = id,
                signature = signature,
                isPending = isPending,
                assetId = assetId,
                description = assetId?.toString()?.addHashtagToStart()
            )
        }
    }

    fun mapToApplicationCallItem(
        transaction: BaseTransaction.Transaction.ApplicationCall
    ): BaseTransactionItem.TransactionItem.ApplicationCallItem {
        return with(transaction) {
            BaseTransactionItem.TransactionItem.ApplicationCallItem(
                id = id,
                signature = signature,
                isPending = isPending,
                description = applicationId.toString(),
                innerTransactionCount = innerTransactionCount,
                applicationId = applicationId
            )
        }
    }

    fun mapToUndefinedItem(
        transaction: BaseTransaction.Transaction.Undefined
    ): BaseTransactionItem.TransactionItem.UndefinedItem {
        return with(transaction) {
            BaseTransactionItem.TransactionItem.UndefinedItem(
                id = id,
                signature = signature,
                isPending = isPending
            )
        }
    }

    fun mapToTransactionDateTitle(
        transaction: BaseTransaction.TransactionDateTitle
    ): BaseTransactionItem.StringTitleItem {
        return BaseTransactionItem.StringTitleItem(transaction.title)
    }

    fun mapToPendingTransactionTitle(
        transaction: BaseTransaction.PendingTransactionTitle
    ): BaseTransactionItem.ResourceTitleItem {
        return BaseTransactionItem.ResourceTitleItem(transaction.stringRes)
    }

    fun mapToKeyRegTransactionItem(
        transaction: BaseTransaction.Transaction.KeyReg
    ): BaseTransactionItem.TransactionItem.KeyRegItem {
        return BaseTransactionItem.TransactionItem.KeyRegItem(
            id = transaction.id,
            signature = transaction.signature,
            isPending = transaction.isPending
        )
    }
}
