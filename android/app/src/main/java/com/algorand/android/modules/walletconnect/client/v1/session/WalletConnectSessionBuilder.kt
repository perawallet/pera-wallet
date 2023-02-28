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

package com.algorand.android.modules.walletconnect.client.v1.session

import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionMetaDTO
import com.algorand.android.modules.walletconnect.client.v1.session.mapper.WalletConnectSessionConfigMapper
import com.algorand.android.utils.browser.HTTPS_PROTOCOL
import com.algorand.android.utils.browser.HTTP_PROTOCOL
import com.algorand.android.utils.walletconnect.createFullyQualifiedSessionConfig
import com.algorand.android.utils.walletconnect.createSessionConfigFromUrl
import com.algorand.android.utils.walletconnect.getFallBackBrowserFromWCUrlOrNull
import com.algorand.android.utils.walletconnect.peermeta.WalletConnectPeraPeerMeta
import com.algorand.android.utils.walletconnect.peermeta.WalletConnectSessionPeerMetaBuilder
import com.google.gson.Gson
import com.squareup.moshi.Moshi
import javax.inject.Inject
import okhttp3.OkHttpClient
import org.walletconnect.Session.Config
import org.walletconnect.impls.FileWCSessionStore
import org.walletconnect.impls.GsonPayloadAdapter
import org.walletconnect.impls.OkHttpTransport
import org.walletconnect.impls.WCSession

class WalletConnectSessionBuilder @Inject constructor(
    private val gson: Gson,
    private val moshi: Moshi,
    private val okHttpClient: OkHttpClient,
    private val storage: FileWCSessionStore,
    private val walletConnectMapper: WalletConnectSessionConfigMapper
) {

    fun createSession(url: String): WalletConnectSessionCachedData? {
        val sessionConfig = createSessionConfigFromUrl(url) ?: return null
        val fallbackBrowserGroupResponse = url.getFallBackBrowserFromWCUrlOrNull()
        return createWCSession(
            sessionConfig = sessionConfig,
            fallbackBrowserGroupResponse = fallbackBrowserGroupResponse
        )
    }

    fun createSession(
        sessionId: Long,
        sessionMeta: WalletConnectSessionMetaDTO,
        fallbackBrowserGroupResponse: String?
    ): WalletConnectSessionCachedData? {
        val sessionConfig = walletConnectMapper.createSessionConfig(sessionMeta)
        return createWCSession(
            sessionConfig = sessionConfig,
            sessionId = sessionId,
            fallbackBrowserGroupResponse = fallbackBrowserGroupResponse
        )
    }

    private fun createWCSession(
        sessionConfig: Config,
        sessionId: Long? = null,
        fallbackBrowserGroupResponse: String? = null
    ): WalletConnectSessionCachedData? {
        val fullyQualifiedConfig = createFullyQualifiedSessionConfig(sessionConfig) ?: return null

        if (checkIfWalletConnectConfigHasInvalidBridgeProtocol(fullyQualifiedConfig.bridge)) return null

        val session = WCSession(
            config = fullyQualifiedConfig,
            payloadAdapter = GsonPayloadAdapter(gson),
            sessionStore = storage,
            transportBuilder = OkHttpTransport.Builder(okHttpClient, moshi),
            clientMeta = WalletConnectSessionPeerMetaBuilder.build(WalletConnectPeraPeerMeta)
        ).apply {
            init()
        }

        return WalletConnectSessionCachedData.create(
            session = session,
            sessionConfig = sessionConfig,
            sessionId = sessionId,
            fallbackBrowserGroupResponse = fallbackBrowserGroupResponse
        )
    }

    private fun checkIfWalletConnectConfigHasInvalidBridgeProtocol(bridge: String): Boolean {
        return !bridge.contains(HTTPS_PROTOCOL, true) && !bridge.contains(HTTP_PROTOCOL, true)
    }
}
