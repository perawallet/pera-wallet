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

package com.algorand.android.transactiondetail.domain.model

import com.algorand.android.models.AssetFreeze
import com.algorand.android.models.AssetTransfer
import com.algorand.android.models.Payment
import com.algorand.android.models.Signature
import java.math.BigInteger

data class TransactionDetailDTO(
    val assetTransfer: AssetTransfer?,
    val closeAmount: BigInteger?,
    val confirmedRound: Long?,
    val signature: Signature?,
    val fee: Long?,
    val id: String?,
    val senderAddress: String?,
    val payment: Payment?,
    val assetFreezeTransaction: AssetFreeze?,
    val senderRewards: Long?,
    val receiverRewards: Long?,
    val noteInBase64: String?,
    val roundTimeAsTimestamp: Long?,
    val rekeyTo: String?
)
