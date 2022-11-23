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

package com.algorand.android.modules.algosdk.data.model

data class PendingTransactionResponseDTO(
    /**
     * The application index if the transaction was found and it created an
     * application.
     */
    var applicationIndex: Long?,

    /**
     * The number of the asset's unit that were transferred to the close-to address.
     */
    var assetClosingAmount: Long?,

    /**
     * The asset index if the transaction was found and it created an asset.
     */
    var assetIndex: Long?,

    /**
     * Rewards in microalgos applied to the close remainder to account.
     */
    var closeRewards: Long?,

    /**
     * Closing amount for the transaction.
     */
    var closingAmount: Long?,

    /**
     * The round where this transaction was confirmed, if present.
     */
    var confirmedRound: Long?,

    /**
     * (gd) Global state key/value changes for the application being executed by this
     * transaction.
     */
    var globalStateDelta: List<EvalDeltaKeyValueDTO>?,

    /**
     * Inner transactions produced by application execution.
     */
    var innerTxns: List<PendingTransactionResponseDTO>?,

    /**
     * (ld) Local state key/value changes for the application being executed by this
     * transaction.
     */
    var localStateDelta: List<AccountStateDeltaDTO>?,

    /**
     * (lg) Logs for the application being executed by this transaction.
     */
    var logs: List<ByteArray>?,

    /**
     * Indicates that the transaction was kicked out of this node's transaction pool
     * (and specifies why that happened). An empty string indicates the transaction
     * wasn't kicked out of this node's txpool due to an error.
     *
     */
    var poolError: String?,

    /**
     * Rewards in microalgos applied to the receiver account.
     */
    var receiverRewards: Long?,

    /**
     * Rewards in microalgos applied to the sender account.
     */
    var senderRewards: Long?,

    /**
     * The raw signed transaction.
     */
    // TODO Implement if we need
    // var txn: SignedTransaction?,
)
