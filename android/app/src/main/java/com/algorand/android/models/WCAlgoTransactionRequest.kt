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
import com.google.gson.annotations.SerializedName
import kotlinx.parcelize.Parcelize

@Parcelize
data class WCAlgoTransactionRequest(
    @SerializedName("txn") val transactionMsgPack: String,
    @SerializedName("signers") val signers: List<String>?,
    @SerializedName("authAddr") val authAddressBase64: String?,
    @SerializedName("msig") val multisigMetadata: MultisigMetadata?,
    @SerializedName("message") val message: String?
) : Parcelable {

    val hasMultipleSigner: Boolean
        get() = signers?.size ?: 0 > 1

    val firstSignerAddressBase64: String?
        get() = signers?.firstOrNull()

    val hasMultisig: Boolean
        get() = multisigMetadata != null

    val isDisplayOnly: Boolean
        get() = signers?.isEmpty() == true
}
