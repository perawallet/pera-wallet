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

package com.algorand.android.modules.walletconnect.domain

import com.algorand.android.modules.walletconnect.client.utils.WalletConnectClientProvider
import com.algorand.android.modules.walletconnect.domain.decider.WalletConnectRequestIdentifierDecider
import com.algorand.android.modules.walletconnect.domain.decider.WalletConnectSessionIdentifierDecider
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectTransactionErrorResponse
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectVersionIdentifier
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionProposal
import javax.inject.Inject

class WalletConnectClientManager @Inject constructor(
    private val walletConnectClientProvider: WalletConnectClientProvider,
    private val sessionIdentifierDecider: WalletConnectSessionIdentifierDecider,
    private val requestIdentifierDecider: WalletConnectRequestIdentifierDecider
) {

    private var listener: WalletConnectClientManagerListener? = null

    fun setListener(listener: WalletConnectClientManagerListener) {
        this.listener = listener
        walletConnectClientProvider.getClients().forEach { client ->
            client.setListener(listener)
        }
    }

    fun connect(url: String) {
        val client = walletConnectClientProvider.getClientForSessionConnectionUrl(url)
        if (client == null) {
            listener?.onInvalidSessionUrl(url)
        } else {
            client.connect(url)
        }
    }

    suspend fun connect(sessionIdentifier: WalletConnect.SessionIdentifier) {
        getClient(sessionIdentifier).connect(sessionIdentifier)
    }

    suspend fun updateSession(
        sessionIdentifier: WalletConnect.SessionIdentifier,
        accountList: List<String>,
        chainIdentifier: WalletConnect.ChainIdentifier,
        removedAccountAddress: String?
    ) {
        getClient(sessionIdentifier).updateSession(
            sessionIdentifier = sessionIdentifier,
            accountAddresses = accountList,
            chainIdentifier = chainIdentifier,
            removedAccountAddress = removedAccountAddress
        )
    }

    suspend fun getSessionDetail(sessionIdentifier: WalletConnect.SessionIdentifier): WalletConnect.SessionDetail? {
        return getClient(sessionIdentifier).getWalletConnectSession(sessionIdentifier)
    }

    suspend fun getSessionDetail(sessionIdentifier: WalletConnectSessionIdentifier): WalletConnect.SessionDetail? {
        val identifier = with(sessionIdentifier) {
            sessionIdentifierDecider.decideSessionIdentifier(this.sessionIdentifier, versionIdentifier)
        }
        return getClient(identifier.versionIdentifier).getWalletConnectSession(identifier)
    }

    suspend fun rejectRequest(
        sessionIdentifier: WalletConnect.SessionIdentifier,
        requestIdentifier: WalletConnect.RequestIdentifier,
        errorResponse: WalletConnectTransactionErrorResponse
    ) {
        getClient(sessionIdentifier).rejectRequest(sessionIdentifier, requestIdentifier, errorResponse)
    }

    suspend fun rejectRequest(
        sessionId: String,
        requestId: Long,
        versionIdentifier: WalletConnectVersionIdentifier,
        errorResponse: WalletConnectTransactionErrorResponse
    ) {
        val sessionIdentifier = sessionIdentifierDecider.decideSessionIdentifier(sessionId, versionIdentifier)
        val requestIdentifier = requestIdentifierDecider.decideRequestIdentifier(requestId, versionIdentifier)
        getClient(versionIdentifier).rejectRequest(sessionIdentifier, requestIdentifier, errorResponse)
    }

    suspend fun approveRequest(
        sessionIdentifier: WalletConnectSessionIdentifier,
        requestId: Long,
        signedTransaction: List<String?>
    ) {
        val identifier = with(sessionIdentifier) {
            sessionIdentifierDecider.decideSessionIdentifier(this.sessionIdentifier, versionIdentifier)
        }
        val requestIdentifier = requestIdentifierDecider.decideRequestIdentifier(
            requestId = requestId,
            versionIdentifier = sessionIdentifier.versionIdentifier
        )
        getClient(sessionIdentifier.versionIdentifier).approveRequest(identifier, requestIdentifier, signedTransaction)
    }

    suspend fun killSession(sessionIdentifier: WalletConnect.SessionIdentifier) {
        getClient(sessionIdentifier).killSession(sessionIdentifier)
    }

    suspend fun rejectSession(sessionProposal: WalletConnectSessionProposal, reason: String) {
        val sessionIdentifier = with(sessionProposal.proposalIdentifier) {
            sessionIdentifierDecider.decideSessionIdentifier(proposalIdentifier, versionIdentifier)
        }
        getClient(sessionProposal.proposalIdentifier.versionIdentifier).rejectSession(sessionIdentifier, reason)
    }

    suspend fun approveSession(
        sessionProposal: WalletConnectSessionProposal,
        accountAddresses: List<String>,
        chainIdentifier: WalletConnect.ChainIdentifier
    ) {
        val sessionIdentifier = with(sessionProposal.proposalIdentifier) {
            sessionIdentifierDecider.decideSessionIdentifier(proposalIdentifier, versionIdentifier)
        }
        getClient(sessionIdentifier).approveSession(sessionIdentifier, accountAddresses, chainIdentifier)
    }

    suspend fun getAllWalletConnectSessions(): List<WalletConnect.SessionDetail> {
        return walletConnectClientProvider.getClients().map { client ->
            client.getAllWalletConnectSessions()
        }.flatten()
    }

    fun getDefaultChainIdentifier(versionIdentifier: WalletConnectVersionIdentifier): WalletConnect.ChainIdentifier {
        return getClient(versionIdentifier).getDefaultChainIdentifier()
    }

    fun getDefaultChainIdentifier(sessionProposal: WalletConnectSessionProposal): WalletConnect.ChainIdentifier {
        return getClient(sessionProposal.proposalIdentifier.versionIdentifier).getDefaultChainIdentifier()
    }

    suspend fun clearSessionRetryCount(sessionIdentifier: WalletConnect.SessionIdentifier) {
        getClient(sessionIdentifier).clearSessionRetryCount(sessionIdentifier)
    }

    suspend fun getSessionRetryCount(sessionIdentifier: WalletConnect.SessionIdentifier): Int {
        return getClient(sessionIdentifier).getSessionRetryCount(sessionIdentifier)
    }

    suspend fun setSessionRetryCount(sessionIdentifier: WalletConnect.SessionIdentifier, retryCount: Int) {
        getClient(sessionIdentifier).setSessionRetryCount(sessionIdentifier, retryCount)
    }

    suspend fun getSessionsByAccountAddress(accountAddress: String): List<WalletConnect.SessionDetail> {
        return walletConnectClientProvider.getClients().map { client ->
            client.getSessionsByAccountAddress(accountAddress)
        }.flatten()
    }

    suspend fun getDisconnectedWalletConnectSessions(): List<WalletConnect.SessionDetail> {
        return walletConnectClientProvider.getClients().map { client ->
            client.getDisconnectedWalletConnectSessions()
        }.flatten()
    }

    suspend fun setAllSessionsDisconnected() {
        walletConnectClientProvider.getClients().forEach { client ->
            client.setAllSessionsDisconnected()
        }
    }

    suspend fun disconnectFromAllSessions() {
        walletConnectClientProvider.getClients().forEach { client ->
            client.disconnectFromAllSessions()
        }
    }

    suspend fun connectToDisconnectedSessions() {
        walletConnectClientProvider.getClients().forEach { client ->
            client.connectToDisconnectedSessions()
        }
    }

    suspend fun initializeClients() {
        walletConnectClientProvider.getClients().forEach { client ->
            client.initializeClient()
        }
    }

    private fun getClient(sessionIdentifier: WalletConnect.SessionIdentifier): WalletConnectClient {
        return walletConnectClientProvider.provideClient(sessionIdentifier.versionIdentifier)
    }

    private fun getClient(versionIdentifier: WalletConnectVersionIdentifier): WalletConnectClient {
        return walletConnectClientProvider.provideClient(versionIdentifier)
    }
}
