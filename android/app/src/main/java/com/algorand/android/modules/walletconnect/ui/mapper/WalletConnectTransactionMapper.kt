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

package com.algorand.android.modules.walletconnect.ui.mapper

import com.algorand.android.mapper.AppCallTransactionMapper
import com.algorand.android.mapper.AssetConfigurationTransactionMapper
import com.algorand.android.mapper.AssetTransferTransactionMapper
import com.algorand.android.mapper.KeyRegTransactionMapper
import com.algorand.android.mapper.PaymentTransactionMapper
import com.algorand.android.models.BaseWalletConnectTransaction
import com.algorand.android.models.SignTxnOptions
import com.algorand.android.models.WCAlgoTransactionRequest
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.modules.transaction.common.data.model.TransactionTypeResponse.APP_TRANSACTION
import com.algorand.android.modules.transaction.common.data.model.TransactionTypeResponse.ASSET_CONFIGURATION
import com.algorand.android.modules.transaction.common.data.model.TransactionTypeResponse.ASSET_TRANSACTION
import com.algorand.android.modules.transaction.common.data.model.TransactionTypeResponse.KEYREG
import com.algorand.android.modules.transaction.common.data.model.TransactionTypeResponse.PAY_TRANSACTION
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.utils.walletconnect.getTransactionRequest
import com.google.gson.Gson
import javax.inject.Inject

class WalletConnectTransactionMapper @Inject constructor(
    private val paymentTransactionMapper: PaymentTransactionMapper,
    private val appCallTransactionMapper: AppCallTransactionMapper,
    private val assetTransferTransactionMapper: AssetTransferTransactionMapper,
    private val assetConfigurationTransactionMapper: AssetConfigurationTransactionMapper,
    private val keyRegTransactionMapper: KeyRegTransactionMapper,
    private val peerMetaMapper: WalletConnectPeerMetaMapper,
    private val sessionIdentifierMapper: WalletConnectSessionIdentifierMapper,
    private val gson: Gson
) {

    fun parseTransactionPayload(payload: List<*>): List<WCAlgoTransactionRequest>? {
        return try {
            (payload.first() as List<*>).map { rawTransactionRequest ->
                gson.fromJson(gson.toJson(rawTransactionRequest), WCAlgoTransactionRequest::class.java)
            }
        } catch (exception: Exception) {
            null
        }
    }

    fun parseSignTxnOptions(payload: List<*>): SignTxnOptions? {
        return try {
            val rawSignTxnOptions = (payload.getOrNull(TRANSACTION_SIGN_OPTIONS_INDEX) as? String)
            gson.fromJson(gson.toJson(rawSignTxnOptions), SignTxnOptions::class.java)
        } catch (exception: Exception) {
            null
        }
    }

    fun createWalletConnectTransaction(
        peerMeta: WalletConnect.PeerMeta,
        rawTxn: WCAlgoTransactionRequest
    ): BaseWalletConnectTransaction? {
        val transactionRequest = rawTxn.getTransactionRequest(gson)
        val walletConnectPeerMeta = peerMetaMapper.mapToPeerMeta(peerMeta)
        return when (transactionRequest.transactionType) {
            PAY_TRANSACTION -> {
                paymentTransactionMapper.createTransaction(walletConnectPeerMeta, transactionRequest, rawTxn)
            }
            APP_TRANSACTION -> {
                appCallTransactionMapper.createTransaction(walletConnectPeerMeta, transactionRequest, rawTxn)
            }
            ASSET_TRANSACTION -> {
                assetTransferTransactionMapper.createTransaction(walletConnectPeerMeta, transactionRequest, rawTxn)
            }
            ASSET_CONFIGURATION -> {
                assetConfigurationTransactionMapper.createTransaction(walletConnectPeerMeta, transactionRequest, rawTxn)
            }
            KEYREG -> {
                keyRegTransactionMapper.createTransaction(walletConnectPeerMeta, transactionRequest, rawTxn)
            }
            else -> null
        }
    }

    fun mapToWalletConnectSession(session: WalletConnect.SessionDetail): WalletConnectSession {
        return WalletConnectSession(
            sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(
                session.sessionIdentifier.getIdentifier(),
                session.versionIdentifier
            ),
            peerMeta = peerMetaMapper.mapToPeerMeta(session.peerMeta),
            dateTimeStamp = session.creationDateTimestamp,
            isConnected = session.isConnected,
            isSubscribed = session.isSubscribed,
            connectedAccountsAddresses = session.connectedAccounts.map { it.accountAddress },
            fallbackBrowserGroupResponse = session.fallbackBrowserGroupResponse,
        )
    }

    companion object {
        private const val TRANSACTION_SIGN_OPTIONS_INDEX = 2
    }
}
