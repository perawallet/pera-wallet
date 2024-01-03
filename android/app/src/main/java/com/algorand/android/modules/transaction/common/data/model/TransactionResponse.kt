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

package com.algorand.android.modules.transaction.common.data.model

import com.google.gson.annotations.SerializedName
import java.math.BigInteger

data class TransactionResponse(
    @SerializedName("asset-transfer-transaction") val assetTransfer: AssetTransferResponse?,
    @SerializedName("asset-config-transaction") val assetConfiguration: AssetConfigurationResponse?,
    @SerializedName("application-transaction") val applicationCall: ApplicationCallResponse?,
    @SerializedName("closing-amount") val closeAmount: BigInteger?,
    @SerializedName("confirmed-round") val confirmedRound: Long?,
    @SerializedName("signature") val signature: SignatureResponse?,
    @SerializedName("fee") val fee: Long?,
    @SerializedName("id") val id: String?,
    @SerializedName("sender") val senderAddress: String?,
    @SerializedName("payment-transaction") val payment: PaymentResponse?,
    @SerializedName("asset-freeze-transaction") val assetFreezeTransaction: AssetFreezeResponse?,
    @SerializedName("note") val noteInBase64: String?,
    @SerializedName("round-time") val roundTimeAsTimestamp: Long?,
    @SerializedName("rekey-to") val rekeyTo: String?,
    @SerializedName("tx-type") val transactionType: TransactionTypeResponse?,
    @SerializedName("inner-txns") val innerTransactions: List<TransactionResponse>?,
    @SerializedName("created-asset-index") val createdAssetIndex: Long?,
    @SerializedName("keyreg-transaction") val keyRegTransaction: KeyRegTransactionResponse?
)
