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

import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect.ChainIdentifier
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect.RequestIdentifier
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect.SessionIdentifier
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectClientListener
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectTransactionErrorResponse

interface WalletConnectClient {

    fun setListener(listener: WalletConnectClientListener)

    fun connect(uri: String)
    suspend fun connect(sessionIdentifier: SessionIdentifier)

    // Session callbacks
    suspend fun approveSession(
        sessionIdentifier: SessionIdentifier,
        accountAddresses: List<String>,
        chainIdentifier: ChainIdentifier
    )

    suspend fun updateSession(
        sessionIdentifier: SessionIdentifier,
        accountAddresses: List<String>,
        chainIdentifier: ChainIdentifier,
        removedAccountAddress: String?
    )

    suspend fun rejectSession(sessionIdentifier: SessionIdentifier, reason: String)

    // Request callbacks
    suspend fun rejectRequest(
        sessionIdentifier: SessionIdentifier,
        requestIdentifier: RequestIdentifier,
        errorResponse: WalletConnectTransactionErrorResponse
    )

    suspend fun approveRequest(
        sessionIdentifier: SessionIdentifier,
        requestIdentifier: RequestIdentifier,
        payload: Any,
    )

    fun getDefaultChainIdentifier(): ChainIdentifier

    fun isValidSessionUrl(url: String): Boolean

    suspend fun killSession(sessionIdentifier: SessionIdentifier)

    suspend fun getWalletConnectSession(sessionIdentifier: SessionIdentifier): WalletConnect.SessionDetail?
    suspend fun getAllWalletConnectSessions(): List<WalletConnect.SessionDetail>
    suspend fun getSessionsByAccountAddress(accountAddress: String): List<WalletConnect.SessionDetail>
    suspend fun getDisconnectedWalletConnectSessions(): List<WalletConnect.SessionDetail>
    suspend fun setAllSessionsDisconnected()

    suspend fun getSessionRetryCount(sessionIdentifier: SessionIdentifier): Int
    suspend fun setSessionRetryCount(sessionIdentifier: SessionIdentifier, retryCount: Int)
    suspend fun clearSessionRetryCount(sessionIdentifier: SessionIdentifier)

    suspend fun disconnectFromAllSessions() {}
    suspend fun connectToDisconnectedSessions() {}

    // TODO: Implement this whenever merge wc-v1 into wc-v2
    suspend fun initializeClient() {}
}
