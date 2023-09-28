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

import kotlinx.parcelize.Parcelize

sealed class BaseKeyRegTransaction : BaseWalletConnectTransaction() {

    sealed class BaseOnlineKeyRegTransaction : BaseKeyRegTransaction() {

        abstract val votePublicKey: String
        abstract val selectionPublicKey: String
        abstract val stateProofKey: String
        abstract val voteFirstValidRound: Long
        abstract val voteLastValidRound: Long
        abstract val voteKeyDilution: Long

        @Parcelize
        data class OnlineKeyRegTransaction(
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val note: String?,
            override val fromAccount: WalletConnectAccount?,
            override val senderAddress: WalletConnectAddress,
            override val peerMeta: WalletConnectPeerMeta,
            override val signer: WalletConnectSigner,
            override val authAddress: String?,
            override val groupId: String?,
            override val votePublicKey: String,
            override val selectionPublicKey: String,
            override val stateProofKey: String,
            override val voteFirstValidRound: Long,
            override val voteLastValidRound: Long,
            override val voteKeyDilution: Long
        ) : BaseOnlineKeyRegTransaction() {

            override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
                return listOf(senderAddress) + signerAddressList.orEmpty()
            }

            override val fee: Long
                get() = walletConnectTransactionParams.fee
        }

        @Parcelize
        data class OnlineKeyRegTransactionWithRekey(
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val note: String?,
            override val fromAccount: WalletConnectAccount?,
            override val senderAddress: WalletConnectAddress,
            override val peerMeta: WalletConnectPeerMeta,
            override val signer: WalletConnectSigner,
            override val authAddress: String?,
            override val groupId: String?,
            override val votePublicKey: String,
            override val selectionPublicKey: String,
            override val stateProofKey: String,
            override val voteFirstValidRound: Long,
            override val voteLastValidRound: Long,
            override val voteKeyDilution: Long,
            val rekeyToAddress: WalletConnectAddress
        ) : BaseOnlineKeyRegTransaction() {

            override val fee: Long
                get() = walletConnectTransactionParams.fee

            override val warningCount: Int
                get() = 1

            override fun getRekeyToAccountAddress(): WalletConnectAddress = rekeyToAddress

            override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
                return listOf(senderAddress, rekeyToAddress) + signerAddressList.orEmpty()
            }
        }
    }

    sealed class BaseOfflineKeyRegTransaction : BaseKeyRegTransaction() {

        abstract val nonParticipation: Boolean

        @Parcelize
        data class OfflineKeyRegTransaction(
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val note: String?,
            override val fromAccount: WalletConnectAccount?,
            override val senderAddress: WalletConnectAddress,
            override val peerMeta: WalletConnectPeerMeta,
            override val signer: WalletConnectSigner,
            override val authAddress: String?,
            override val groupId: String?,
            override val nonParticipation: Boolean
        ) : BaseOfflineKeyRegTransaction() {

            override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
                return listOf(senderAddress) + signerAddressList.orEmpty()
            }

            override val fee: Long
                get() = walletConnectTransactionParams.fee
        }

        @Parcelize
        data class OfflineKeyRegTransactionWithRekey(
            override val rawTransactionPayload: WCAlgoTransactionRequest,
            override val walletConnectTransactionParams: WalletConnectTransactionParams,
            override val note: String?,
            override val fromAccount: WalletConnectAccount?,
            override val senderAddress: WalletConnectAddress,
            override val peerMeta: WalletConnectPeerMeta,
            override val signer: WalletConnectSigner,
            override val authAddress: String?,
            override val groupId: String?,
            override val nonParticipation: Boolean,
            val rekeyToAddress: WalletConnectAddress
        ) : BaseOfflineKeyRegTransaction() {

            override val fee: Long
                get() = walletConnectTransactionParams.fee

            override val warningCount: Int
                get() = 1

            override fun getRekeyToAccountAddress(): WalletConnectAddress = rekeyToAddress

            override fun getAllAddressPublicKeysTxnIncludes(): List<WalletConnectAddress> {
                return listOf(senderAddress, rekeyToAddress) + signerAddressList.orEmpty()
            }
        }
    }
}
