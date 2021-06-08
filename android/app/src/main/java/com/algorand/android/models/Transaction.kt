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

import android.os.Parcelable
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.formatAsTxString
import com.algorand.android.utils.getUserIfSavedLocally
import com.algorand.android.utils.getZonedDateTimeFromTimeStamp
import com.google.gson.annotations.SerializedName
import java.math.BigInteger
import kotlinx.parcelize.Parcelize

@Parcelize
data class Transaction(
    @SerializedName("asset-transfer-transaction") val assetTransfer: AssetTransfer?,
    @SerializedName("closing-amount") val closeAmount: BigInteger?,
    @SerializedName("confirmed-round") val confirmedRound: Long?,
    @SerializedName("signature") val signature: Signature?,
    @SerializedName("fee") val fee: Long?,
    @SerializedName("id") val id: String?,
    @SerializedName("sender") val senderAddress: String?,
    @SerializedName("payment-transaction") val payment: Payment?,
    @SerializedName("sender-rewards") val senderRewards: Long?,
    @SerializedName("receiver-rewards") val receiverRewards: Long?,
    @SerializedName("note") val noteInBase64: String?,
    @SerializedName("round-time") val roundTimeAsTimestamp: Long?
) : Parcelable, TransactionImpl {

    private fun isInPending() = confirmedRound == null || confirmedRound == 0L

    fun isAlgorand() = payment != null

    private fun isAssetCreationTransaction(): Boolean {
        return assetTransfer != null && senderAddress == assetTransfer.receiverAddress &&
            assetTransfer.amount == BigInteger.ZERO
    }

    private fun includeInAlgorandHistory() = payment != null || isAssetCreationTransaction()

    fun getReceiverAddress(): String {
        return if (isAlgorand()) {
            payment?.receiverAddress.orEmpty()
        } else {
            assetTransfer?.receiverAddress.orEmpty()
        }
    }

    fun getAmount(includeCloseAmount: Boolean): BigInteger? {
        return payment?.amount?.run {
            return if (includeCloseAmount && closeAmount != null && closeAmount != BigInteger.ZERO) {
                this.plus(closeAmount)
            } else {
                this
            }
        } ?: assetTransfer?.amount
    }

    private fun getAssetId(): Long? = if (isAlgorand()) {
        AssetInformation.ALGORAND_ID
    } else {
        assetTransfer?.assetId
    }

    fun getReward(userPublicKey: String?): Long? {
        if (userPublicKey == null) {
            return null
        }
        return when {
            senderAddress == userPublicKey -> senderRewards
            payment?.receiverAddress == userPublicKey -> receiverRewards
            else -> null
        }
    }

    private fun getDateAsString(): String {
        return roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp()?.formatAsTxString().orEmpty()
    }

    private fun getCloseToAddress(): String? {
        return payment?.closeToAddress
    }

    private fun getTransactionType(): TransactionType {
        return when {
            isAssetCreationTransaction() -> {
                TransactionType.ASSET_CREATION
            }
            isInPending() -> {
                TransactionType.PENDING
            }
            else -> {
                TransactionType.TRANSFER
            }
        }
    }

    override fun toTransactionListItem(
        assetId: Long,
        accountPublicKey: String,
        contactList: List<User>,
        accountList: List<Account>,
        decimals: Int
    ): TransactionListItem {
        val receiverAddress = getReceiverAddress()

        val transactionSymbol = when {
            senderAddress == accountPublicKey && receiverAddress == accountPublicKey -> {
                null
            }
            receiverAddress == accountPublicKey || getCloseToAddress() == accountPublicKey -> {
                TransactionSymbol.POSITIVE
            }
            else -> {
                TransactionSymbol.NEGATIVE
            }
        }

        val otherPublicKey = if (receiverAddress == accountPublicKey) {
            senderAddress.orEmpty()
        } else {
            receiverAddress
        }

        val zonedDateTime = roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp()

        return TransactionListItem(
            assetId = assetId,
            id = id,
            signature = signature?.signatureKey,
            accountPublicKey = accountPublicKey,
            otherPublicKey = otherPublicKey,
            transactionSymbol = transactionSymbol,
            transactionType = getTransactionType(),
            isAlgorand = isAlgorand(),
            contact = getUserIfSavedLocally(contactList, accountList, otherPublicKey),
            zonedDateTime = zonedDateTime,
            date = zonedDateTime?.formatAsTxString().orEmpty(),
            amount = getAmount(includeCloseAmount = false),
            fee = fee,
            noteInB64 = noteInBase64,
            round = confirmedRound,
            decimals = decimals,
            formattedFullAmount = getAmount(includeCloseAmount = true).formatAmount(decimals),
            closeToAddress = getCloseToAddress(),
            closeToAmount = closeAmount,
            rewardAmount = getReward(accountPublicKey)
        )
    }

    override fun getRewardOfTransaction(accountPublicKey: String): ClaimedRewardListItem? {
        val reward = getReward(accountPublicKey)
        return if (reward != null && reward != 0L) {
            ClaimedRewardListItem(reward, id, getDateAsString())
        } else {
            null
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
}
