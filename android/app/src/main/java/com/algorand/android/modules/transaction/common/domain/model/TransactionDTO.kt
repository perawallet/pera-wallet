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

package com.algorand.android.modules.transaction.common.domain.model

import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.models.AssetInformation
import com.algorand.android.utils.formatAsTxString
import com.algorand.android.utils.getZonedDateTimeFromTimeStamp
import com.algorand.android.utils.isNotEqualTo
import java.math.BigInteger

// TODO: DTO classes should not contain any logic. Create domain class and move them there
data class TransactionDTO(
    val assetTransfer: AssetTransferDTO?,
    val assetConfiguration: AssetConfigurationDTO?,
    val applicationCall: ApplicationCallDTO?,
    val closeAmount: BigInteger?,
    val confirmedRound: Long?,
    val signature: SignatureDTO?,
    val fee: Long?,
    val id: String?,
    val senderAddress: String?,
    val payment: PaymentDTO?,
    val assetFreezeTransaction: AssetFreezeDTO?,
    val noteInBase64: String?,
    val roundTimeAsTimestamp: Long?,
    val rekeyTo: String?,
    val transactionType: TransactionTypeDTO?,
    val innerTransactions: List<TransactionDTO>?,
    val createdAssetIndex: Long?
) {

    fun isAlgorand() = payment != null

    fun getReceiverAddressOrEmpty(): String {
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
        AssetInformation.ALGO_ID
    } else {
        assetTransfer?.assetId
            ?: assetFreezeTransaction?.assetId
            ?: assetConfiguration?.assetId.takeIf { it != null && it > 0 }
            ?: createdAssetIndex
            ?: applicationCall?.foreignAssets?.firstNotNullOfOrNull { it }
    }

    fun getAllAssetIds(): Set<Long> {
        return mutableSetOf<Long>().apply {
            getAssetId()?.let { add(it) }
            if (applicationCall?.foreignAssets?.isNotEmpty() == true) {
                addAll(applicationCall.foreignAssets)
            }
        }
    }

    private fun getDateAsString(): String {
        return roundTimeAsTimestamp?.getZonedDateTimeFromTimeStamp()?.formatAsTxString().orEmpty()
    }

    fun getCloseToAddress(): String? {
        return payment?.closeToAddress ?: assetTransfer?.closeTo
    }

    fun getSenderAddressOrEmpty(): String {
        return senderAddress.orEmpty()
    }

    fun isPending(): Boolean {
        return confirmedRound == null || confirmedRound == 0L
    }

    enum class TransactionName(@StringRes val stringRes: Int) {
        SEND(R.string.send),
        RECEIVE(R.string.receive),
        ASSET_CONFIGURATION(R.string.asset_configuration),
        APPLICATION_CALL(R.string.application_call),
        UNDEFINED(R.string.undefined),
    }
}
