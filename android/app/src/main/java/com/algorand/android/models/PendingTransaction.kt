/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.models

import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.formatAsTxString
import com.algorand.android.utils.getUserIfSavedLocally
import com.google.gson.annotations.SerializedName
import java.math.BigInteger
import java.time.ZonedDateTime

data class PendingTransaction(
    @SerializedName("sig")
    val signatureKey: String?,
    @SerializedName("txn")
    val detail: PendingTransactionDetail?
) : TransactionImpl {

    fun isAlgorand() = detail?.assetId == null

    fun isAssetCreationTransaction() =
        detail?.senderAddress == detail?.assetReceiverAddress && detail?.assetAmount == BigInteger.ZERO

    private fun includeInAlgorandHistory() = isAlgorand() || isAssetCreationTransaction()

    fun getAssetId(): Long? = if (isAlgorand()) {
        AssetInformation.ALGORAND_ID
    } else {
        detail?.assetId
    }

    fun getAmount(): BigInteger {
        return detail?.amount ?: detail?.assetAmount ?: BigInteger.ZERO
    }

    fun getReceiverAddress(): String {
        return if (isAlgorand()) {
            detail?.receiverAddress.orEmpty()
        } else {
            detail?.assetReceiverAddress.orEmpty()
        }
    }

    override fun includeInHistory(assetId: Long): Boolean {
        return if (assetId == AssetInformation.ALGORAND_ID) {
            includeInAlgorandHistory()
        } else {
            val assetIdOfTransaction = getAssetId()
            assetIdOfTransaction != null && !isAssetCreationTransaction() && assetIdOfTransaction == assetId
        }
    }

    override fun toTransactionListItem(
        assetId: Long,
        accountPublicKey: String,
        contactList: List<User>,
        accountList: List<Account>,
        decimals: Int
    ): BaseTransactionListItem {
        val receiverAddress = getReceiverAddress()

        val transactionSymbol = when {
            detail?.senderAddress == accountPublicKey && receiverAddress == accountPublicKey -> {
                null
            }
            receiverAddress == accountPublicKey -> {
                TransactionSymbol.POSITIVE
            }
            else -> {
                TransactionSymbol.NEGATIVE
            }
        }

        val otherPublicKey = if (receiverAddress == accountPublicKey) {
            detail?.senderAddress.orEmpty()
        } else {
            receiverAddress
        }

        val amount = getAmount()

        val nowZonedDateTime = ZonedDateTime.now()

        return TransactionListItem(
            assetId = assetId,
            id = null,
            signature = signatureKey,
            accountPublicKey = accountPublicKey,
            otherPublicKey = otherPublicKey,
            transactionSymbol = transactionSymbol,
            isAlgorand = isAlgorand(),
            transactionType = TransactionType.PENDING,
            amount = amount,
            contact = getUserIfSavedLocally(contactList, accountList, otherPublicKey),
            date = nowZonedDateTime.formatAsTxString(),
            zonedDateTime = nowZonedDateTime,
            fee = detail?.fee,
            noteInB64 = detail?.noteInBase64,
            round = null,
            decimals = decimals,
            formattedFullAmount = amount.formatAmount(decimals),
            closeToAddress = null, // TODO Add CloseTo Address after model is updated.
            closeToAmount = null, // TODO Add CloseAmount after model is updated
            rewardAmount = 0L
        )
    }

    override fun getRewardOfTransaction(accountPublicKey: String): ClaimedRewardListItem? = null
}
