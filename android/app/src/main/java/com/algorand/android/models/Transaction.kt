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

package com.algorand.android.models

import android.os.Parcelable
import com.algorand.android.utils.formatAsTxString
import com.algorand.android.utils.getZonedDateTimeFromTimeStamp
import com.algorand.android.utils.isNotEqualTo
import com.google.gson.annotations.SerializedName
import kotlinx.parcelize.Parcelize
import java.math.BigInteger

// TODO Create another model to separate data/ui models
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
    @SerializedName("asset-freeze-transaction") val assetFreezeTransaction: AssetFreeze?,
    @SerializedName("sender-rewards") val senderRewards: Long?,
    @SerializedName("receiver-rewards") val receiverRewards: Long?,
    @SerializedName("note") val noteInBase64: String?,
    @SerializedName("round-time") val roundTimeAsTimestamp: Long?,
    @SerializedName("rekey-to") val rekeyTo: String?
) : Parcelable {

    fun isAlgorand() = payment != null

    fun getReceiverAddress(): String {
        return if (isAlgorand()) {
            payment?.receiverAddress.orEmpty()
        } else {
            // TODO: 24.02.2022 We have to determine which transaction types should we support,
            //  then we should find a better solution for here
            assetTransfer?.receiverAddress ?: assetFreezeTransaction?.receiverAddress.orEmpty()
        }
    }

    fun getAmount(includeCloseAmount: Boolean): BigInteger? {
        return payment?.amount?.run {
            return if (includeCloseAmount && closeAmount != null && closeAmount isNotEqualTo BigInteger.ZERO) {
                this.plus(closeAmount)
            } else {
                this
            }
        } ?: assetTransfer?.amount
    }

    fun getAssetId(): Long? = if (isAlgorand()) {
        AssetInformation.ALGORAND_ID
    } else {
        assetTransfer?.assetId ?: assetFreezeTransaction?.assetId
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

    fun getCloseToAddress(): String? {
        return payment?.closeToAddress
    }
}
