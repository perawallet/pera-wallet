@file:Suppress("ReturnCount")
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

package com.algorand.android.mapper

import com.algorand.android.models.BaseKeyRegTransaction
import com.algorand.android.models.BaseKeyRegTransaction.BaseOfflineKeyRegTransaction.OfflineKeyRegTransaction
import com.algorand.android.models.BaseKeyRegTransaction.BaseOfflineKeyRegTransaction.OfflineKeyRegTransactionWithRekey
import com.algorand.android.models.BaseKeyRegTransaction.BaseOnlineKeyRegTransaction.OnlineKeyRegTransaction
import com.algorand.android.models.BaseKeyRegTransaction.BaseOnlineKeyRegTransaction.OnlineKeyRegTransactionWithRekey
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectAccount
import com.algorand.android.models.WalletConnectAddress
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.models.WalletConnectTransactionRequest
import com.algorand.android.models.WalletConnectTransactionSigner
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.walletconnect.domain.WalletConnectErrorProvider
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.extensions.mapNotBlank
import javax.inject.Inject

class KeyRegTransactionMapper @Inject constructor(
    private val errorProvider: WalletConnectErrorProvider,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase
) : BaseWalletConnectTransactionMapper() {

    override fun createTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): BaseKeyRegTransaction? {
        val isOnline = isOnlineKeyRegistrationTransaction(transactionRequest)
        return when {
            isOnline && transactionRequest.rekeyAddress != null -> {
                createOnlineKeyRegistrationWithRekeyTransaction(peerMeta, transactionRequest, rawTxn)
            }

            isOnline -> {
                createOnlineKeyRegistrationTransaction(peerMeta, transactionRequest, rawTxn)
            }

            transactionRequest.rekeyAddress != null -> {
                createOfflineKeyRegistrationWithRekeyTransaction(peerMeta, transactionRequest, rawTxn)
            }

            else -> {
                createOfflineKeyRegistrationTransaction(peerMeta, transactionRequest, rawTxn)
            }
        }
    }

    private fun isOnlineKeyRegistrationTransaction(request: WalletConnectTransactionRequest): Boolean {
        return with(request) {
            !votePublicKey.isNullOrBlank() && !selectionPublicKey.isNullOrBlank() && voteKeyDilution != null &&
                    voteFirstValidRound != null && voteLastValidRound != null
        }
    }

    private fun createOnlineKeyRegistrationTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): OnlineKeyRegTransaction? {
        val senderWCAddress = createWalletConnectAddress(transactionRequest.senderAddress) ?: return null
        val accountData = senderWCAddress.decodedAddress?.mapNotBlank { safeAddress ->
            accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
        }
        val signer = WalletConnectTransactionSigner.create(rawTxn, senderWCAddress, errorProvider)
        return with(transactionRequest) {
            OnlineKeyRegTransaction(
                rawTransactionPayload = rawTxn,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                senderAddress = senderWCAddress,
                peerMeta = peerMeta,
                signer = signer,
                authAddress = getAuthAddress(accountData, signer),
                groupId = groupId,
                votePublicKey = votePublicKey ?: return null,
                selectionPublicKey = selectionPublicKey ?: return null,
                stateProofKey = stateProofPublicKey ?: return null,
                voteFirstValidRound = voteFirstValidRound ?: return null,
                voteLastValidRound = voteLastValidRound ?: return null,
                voteKeyDilution = voteKeyDilution ?: return null,
                fromAccount = createSenderAccountInformation(senderWCAddress)
            )
        }
    }

    private fun createOnlineKeyRegistrationWithRekeyTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): OnlineKeyRegTransactionWithRekey? {
        return with(transactionRequest) {
            val senderWCAddress = createWalletConnectAddress(transactionRequest.senderAddress) ?: return null
            val accountData = senderWCAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
            }
            val signer = WalletConnectTransactionSigner.create(rawTxn, senderWCAddress, errorProvider)
            OnlineKeyRegTransactionWithRekey(
                rawTransactionPayload = rawTxn,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                senderAddress = senderWCAddress,
                peerMeta = peerMeta,
                signer = signer,
                authAddress = getAuthAddress(accountData, signer),
                groupId = groupId,
                votePublicKey = votePublicKey ?: return null,
                selectionPublicKey = selectionPublicKey ?: return null,
                stateProofKey = stateProofPublicKey ?: return null,
                voteFirstValidRound = voteFirstValidRound ?: return null,
                voteLastValidRound = voteLastValidRound ?: return null,
                voteKeyDilution = voteKeyDilution ?: return null,
                rekeyToAddress = createWalletConnectAddress(transactionRequest.rekeyAddress) ?: return null,
                fromAccount = createSenderAccountInformation(senderWCAddress)
            )
        }
    }

    private fun createOfflineKeyRegistrationTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): OfflineKeyRegTransaction? {
        return with(transactionRequest) {
            val senderWCAddress = createWalletConnectAddress(transactionRequest.senderAddress) ?: return null
            val accountData = senderWCAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
            }
            val signer = WalletConnectTransactionSigner.create(rawTxn, senderWCAddress, errorProvider)
            OfflineKeyRegTransaction(
                rawTransactionPayload = rawTxn,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                senderAddress = senderWCAddress,
                peerMeta = peerMeta,
                signer = signer,
                authAddress = getAuthAddress(accountData, signer),
                groupId = groupId,
                nonParticipation = nonParticipation ?: DEFAULT_NON_PARTICIPATION,
                fromAccount = createSenderAccountInformation(senderWCAddress)
            )
        }
    }

    private fun createOfflineKeyRegistrationWithRekeyTransaction(
        peerMeta: WalletConnectPeerMeta,
        transactionRequest: WalletConnectTransactionRequest,
        rawTxn: WCAlgoTransactionRequest
    ): OfflineKeyRegTransactionWithRekey? {
        return with(transactionRequest) {
            val senderWCAddress = createWalletConnectAddress(transactionRequest.senderAddress) ?: return null
            val accountData = senderWCAddress.decodedAddress?.mapNotBlank { safeAddress ->
                accountDetailUseCase.getCachedAccountDetail(safeAddress)?.data
            }
            val signer = WalletConnectTransactionSigner.create(rawTxn, senderWCAddress, errorProvider)
            OfflineKeyRegTransactionWithRekey(
                rawTransactionPayload = rawTxn,
                walletConnectTransactionParams = createTransactionParams(transactionRequest),
                note = decodedNote,
                senderAddress = senderWCAddress,
                peerMeta = peerMeta,
                signer = signer,
                authAddress = getAuthAddress(accountData, signer),
                groupId = groupId,
                nonParticipation = nonParticipation ?: DEFAULT_NON_PARTICIPATION,
                rekeyToAddress = createWalletConnectAddress(rekeyAddress) ?: return null,
                fromAccount = createSenderAccountInformation(senderWCAddress)
            )
        }
    }

    private fun createSenderAccountInformation(senderWCAddress: WalletConnectAddress): WalletConnectAccount? {
        val senderAccountData = senderWCAddress.decodedAddress?.mapNotBlank { safeAddress ->
            accountDetailUseCase.getCachedAccountDetail(publicKey = safeAddress)?.data
        }
        return WalletConnectAccount.create(
            account = senderAccountData?.account,
            accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(
                accountAddress = senderAccountData?.account?.address.orEmpty()
            )
        )
    }

    companion object {
        /**
         * All new Algorand accounts are participating by default. This means that they earn rewards.
         * Mark an account nonparticipating by setting this value to true and this account will no longer earn rewards.
         * It is unlikely that you will ever need to do this and
         * exists mainly for economic-related functions on the network.
         * https://developer.algorand.org/docs/get-details/transactions/transactions/?from_query=key%20registration#key-registration-transaction
         */
        private const val DEFAULT_NON_PARTICIPATION = false
    }
}
