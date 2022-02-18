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

import com.google.gson.annotations.SerializedName
import java.math.BigInteger
import java.math.BigInteger.ZERO

data class NotificationMetadata(
    @SerializedName("sender_public_key")
    val senderPublicKey: String? = null,
    @SerializedName("receiver_public_key")
    val receiverPublicKey: String? = null,
    @SerializedName("notification_type")
    private val notificationType: NotificationType? = null,
    @SerializedName("asset")
    private val assetDescription: AssetNotificationDescription? = null,
    @SerializedName("amount")
    val amount: BigInteger? = null,
    var alertMessage: String = "",
    @SerializedName("amount_str")
    val amountAsString: String = ""
) {

    /**
     * Firebase doesn't support unsigned 64 bit integers,
     * that's why api sends amount as string if it is exceeds 64 bit signed threshold (9_223_372_036_854_775_807)
     * Keep amount as BigInteger, because it is being used in notification center
     */
    val safeAmount: BigInteger
        get() = if (amount == ZERO) amountAsString.toBigIntegerOrNull() ?: ZERO else amount ?: ZERO

    fun getNotificationType(): NotificationType {
        return notificationType ?: NotificationType.UNKNOWN
    }

    fun getAssetDescription(): AssetNotificationDescription {
        return assetDescription ?: AssetNotificationDescription.getAlgorandNotificationDescription()
    }

    fun getAccountPublicKey(): String? {
        return when (getNotificationType()) {
            NotificationType.TRANSACTION_RECEIVED,
            NotificationType.ASSET_TRANSACTION_RECEIVED,
            NotificationType.ASSET_SUPPORT_REQUEST -> receiverPublicKey
            else -> senderPublicKey
        }
    }
}

enum class NotificationType {
    @SerializedName("asset-support-request")
    ASSET_SUPPORT_REQUEST,
    @SerializedName("asset-support-success")
    ASSET_SUPPORT_SUCCESS,
    @SerializedName("asset-transaction-received")
    ASSET_TRANSACTION_RECEIVED,
    @SerializedName("asset-transaction-sent")
    ASSET_TRANSACTION_SENT,
    @SerializedName("asset-transaction-failed")
    ASSET_TRANSACTION_FAILED,
    @SerializedName("transaction-received")
    TRANSACTION_RECEIVED,
    @SerializedName("transaction-sent")
    TRANSACTION_SENT,
    @SerializedName("transaction-failed")
    TRANSACTION_FAILED,
    @SerializedName("broadcast")
    BROADCAST,
    UNKNOWN
}
