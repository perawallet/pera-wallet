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

package com.algorand.android.modules.walletconnect.client.v1.retrycount

import com.algorand.android.modules.walletconnect.client.v1.mapper.WalletConnectV1SessionIdentifierMapper
import com.algorand.android.modules.walletconnect.client.v1.session.WalletConnectV1SessionCachedData
import com.algorand.android.modules.walletconnect.client.v1.session.WalletConnectV1SessionCachedDataHandler
import com.algorand.android.modules.walletconnect.client.v1.utils.WalletConnectV1IdentifierParser
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect

class WalletConnectV1SessionRetryCounterImpl(
    private val sessionCachedDataHandler: WalletConnectV1SessionCachedDataHandler,
    private val identifierParser: WalletConnectV1IdentifierParser,
    private val sessionIdentifierMapper: WalletConnectV1SessionIdentifierMapper
) : WalletConnectV1SessionRetryCounter {

    override suspend fun getSessionRetryCount(sessionIdentifier: WalletConnect.SessionIdentifier): Int {
        return identifierParser.withSessionId(sessionIdentifier) { id ->
            val sessionCacheData = sessionCachedDataHandler.getCachedDataById(id)
            sessionCacheData?.retryCount ?: WalletConnectV1SessionCachedData.INITIAL_RETRY_COUNT
        } ?: WalletConnectV1SessionCachedData.INITIAL_RETRY_COUNT
    }

    override suspend fun setSessionRetryCount(sessionIdentifier: WalletConnect.SessionIdentifier, retryCount: Int) {
        identifierParser.withSessionId(sessionIdentifier) { id ->
            val sessionCacheData = sessionCachedDataHandler.getCachedDataById(id)
            sessionCacheData?.retryCount = retryCount
        }
    }

    override suspend fun clearSessionRetryCount(sessionIdentifier: WalletConnect.SessionIdentifier) {
        clearRetryCount(sessionIdentifier)
    }

    override suspend fun clearSessionRetryCount(sessionId: Long) {
        val sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(sessionId)
        clearRetryCount(sessionIdentifier)
    }

    private suspend fun clearRetryCount(sessionIdentifier: WalletConnect.SessionIdentifier) {
        identifierParser.withSessionId(sessionIdentifier) { sessionId ->
            val sessionCacheData = sessionCachedDataHandler.getCachedDataById(sessionId)
            sessionCacheData?.retryCount = WalletConnectV1SessionCachedData.INITIAL_RETRY_COUNT
        }
    }
}
