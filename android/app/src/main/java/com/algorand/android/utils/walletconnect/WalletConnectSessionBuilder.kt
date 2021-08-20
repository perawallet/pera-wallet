/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.utils.walletconnect

import com.algorand.android.models.WalletConnectSessionMeta
import com.algorand.android.utils.walletconnect.peermeta.WalletConnectAlgorandPeerMeta
import com.algorand.android.utils.walletconnect.peermeta.WalletConnectPeerMetaBuilder
import com.squareup.moshi.Moshi
import javax.inject.Inject
import okhttp3.OkHttpClient
import org.walletconnect.Session.Config
import org.walletconnect.impls.FileWCSessionStore
import org.walletconnect.impls.MoshiPayloadAdapter
import org.walletconnect.impls.OkHttpTransport
import org.walletconnect.impls.WCSession

class WalletConnectSessionBuilder @Inject constructor(
    private val moshi: Moshi,
    private val okHttpClient: OkHttpClient,
    private val storage: FileWCSessionStore,
    private val walletConnectMapper: WCWalletConnectMapper
) {

    fun createSession(url: String): WalletConnectSessionCachedData? {
        val sessionConfig = Config.fromWCUri(url)
        return createWCSession(sessionConfig)
    }

    fun createSession(sessionId: Long, sessionMeta: WalletConnectSessionMeta): WalletConnectSessionCachedData? {
        val sessionConfig = walletConnectMapper.createSessionConfig(sessionMeta)
        return createWCSession(sessionConfig, sessionId)
    }

    private fun createWCSession(sessionConfig: Config, sessionId: Long? = null): WalletConnectSessionCachedData? {
        val session = WCSession(
            sessionConfig.toFullyQualifiedConfig(),
            MoshiPayloadAdapter(moshi),
            storage,
            OkHttpTransport.Builder(okHttpClient, moshi),
            WalletConnectPeerMetaBuilder.createPeerMeta(WalletConnectAlgorandPeerMeta)
        ).apply {
            init()
        }

        return WalletConnectSessionCachedData.create(session, sessionConfig, sessionId)
    }
}
