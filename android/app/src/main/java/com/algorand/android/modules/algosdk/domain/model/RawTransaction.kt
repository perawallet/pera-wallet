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

package com.algorand.android.modules.algosdk.domain.model

import android.os.Parcelable
import java.math.BigInteger
import kotlinx.parcelize.Parcelize

@Parcelize
data class RawTransaction(
    val amount: String?,
    val fee: Long?,
    val firstValidRound: Long?,
    val genesisId: String?,
    val genesisHash: String?,
    val lastValidRound: Long?,
    val note: String?,
    val receiverAddress: AlgorandAddress?,
    val senderAddress: AlgorandAddress?,
    val transactionType: RawTransactionType,
    val closeToAddress: AlgorandAddress?,
    val rekeyAddress: AlgorandAddress?,
    val assetCloseToAddress: AlgorandAddress?,
    val assetReceiverAddress: AlgorandAddress?,
    val assetAmount: BigInteger?,
    val assetId: Long?,
    val appArgs: List<String>?,
    val appOnComplete: Int?,
    val appId: Long?,
    val appGlobalSchema: ApplicationCallStateSchema?,
    val appLocalSchema: ApplicationCallStateSchema?,
    val appExtraPages: Int?,
    val approvalHash: String?,
    val stateHash: String?,
    val assetIdBeingConfigured: Long?,
    val assetConfigParameters: AssetConfigParameters?,
    val groupId: String?
) : Parcelable
