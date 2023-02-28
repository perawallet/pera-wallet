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

package com.algorand.android.modules.walletconnect.client.v2

import com.algorand.android.modules.walletconnect.domain.WalletConnectClient
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectClientListener
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectTransactionErrorResponse

class WalletConnectClientV2Impl : WalletConnectClient {

    override fun setListener(listener: WalletConnectClientListener) {
        // TODO "Not yet implemented"
    }

    override fun connect(uri: String) {
        // TODO "Not yet implemented"
    }

    override suspend fun connect(sessionIdentifier: WalletConnect.SessionIdentifier) {
        // TODO "Not yet implemented"
    }

    override suspend fun approveSession(
        sessionIdentifier: WalletConnect.SessionIdentifier,
        accountAddresses: List<String>,
        chainIdentifier: WalletConnect.ChainIdentifier
    ) {
        // TODO "Not yet implemented"
    }

    override suspend fun updateSession(
        sessionIdentifier: WalletConnect.SessionIdentifier,
        accountAddresses: List<String>,
        chainIdentifier: WalletConnect.ChainIdentifier,
        removedAccountAddress: String?
    ) {
        // TODO "Not yet implemented"
    }

    override suspend fun rejectSession(sessionIdentifier: WalletConnect.SessionIdentifier, reason: String) {
        // TODO "Not yet implemented"
    }

    override suspend fun rejectRequest(
        sessionIdentifier: WalletConnect.SessionIdentifier,
        requestIdentifier: WalletConnect.RequestIdentifier,
        errorResponse: WalletConnectTransactionErrorResponse
    ) {
        // TODO "Not yet implemented"
    }

    override suspend fun approveRequest(
        sessionIdentifier: WalletConnect.SessionIdentifier,
        requestIdentifier: WalletConnect.RequestIdentifier,
        payload: Any
    ) {
        // TODO "Not yet implemented"
    }

    override fun getDefaultChainIdentifier(): WalletConnect.ChainIdentifier {
        // TODO "Not yet implemented"
        return WalletConnect.ChainIdentifier.UNKNOWN
    }

    override fun isValidSessionUrl(url: String): Boolean {
        return false // TODO "Not yet implemented"
    }

    override suspend fun killSession(sessionIdentifier: WalletConnect.SessionIdentifier) {
        // TODO "Not yet implemented"
    }

    override suspend fun getWalletConnectSession(
        sessionIdentifier: WalletConnect.SessionIdentifier
    ): WalletConnect.SessionDetail? {
        return null // TODO "Not yet implemented"
    }

    override suspend fun getAllWalletConnectSessions(): List<WalletConnect.SessionDetail> {
        return emptyList() // TODO "Not yet implemented"
    }

    override suspend fun getSessionsByAccountAddress(accountAddress: String): List<WalletConnect.SessionDetail> {
        return emptyList() // TODO "Not yet implemented"
    }

    override suspend fun getDisconnectedWalletConnectSessions(): List<WalletConnect.SessionDetail> {
        return emptyList() // TODO "Not yet implemented"
    }

    override suspend fun setAllSessionsDisconnected() {
        // TODO
    }

    override suspend fun getSessionRetryCount(sessionIdentifier: WalletConnect.SessionIdentifier): Int {
        return 1 // TODO "Not yet implemented"
    }

    override suspend fun setSessionRetryCount(sessionIdentifier: WalletConnect.SessionIdentifier, retryCount: Int) {
        // TODO "Not yet implemented"
    }

    override suspend fun clearSessionRetryCount(sessionIdentifier: WalletConnect.SessionIdentifier) {
        // TODO "Not yet implemented"
    }

    companion object {
        const val INJECTION_NAME = "walletConnectClientV2InjectionName"
    }
}
