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

data class PendingTransaction(
    @SerializedName("sig")
    val signatureKey: String?,
    @SerializedName("txn")
    val detail: PendingTransactionDetail?
) {

    fun isAlgorand() = detail?.assetId == null

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
}
