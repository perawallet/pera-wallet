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

package com.algorand.android.modules.walletconnect.mapper

import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionDto
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectBlockchain
import javax.inject.Inject

class WalletConnectSessionDetailMapper @Inject constructor(
    private val peerMetaMapper: WalletConnectPeerMetaMapper,
) {

    @Suppress("LongParameterList")
    fun mapToSessionDetail(
        sessionIdentifier: WalletConnect.SessionIdentifier,
        topic: String,
        peerMeta: WalletConnect.PeerMeta,
        namespaces: Map<WalletConnectBlockchain, WalletConnect.Namespace.Session>,
        creationDateTimestamp: Long,
        isConnected: Boolean,
        fallbackBrowserGroupResponse: String?,
        expiry: WalletConnect.Model.Expiry?,
        sessionMeta: WalletConnect.Session.Meta
    ): WalletConnect.SessionDetail {
        return WalletConnect.SessionDetail(
            sessionIdentifier = sessionIdentifier,
            topic = topic,
            peerMeta = peerMeta,
            namespaces = namespaces,
            creationDateTimestamp = creationDateTimestamp,
            fallbackBrowserGroupResponse = fallbackBrowserGroupResponse,
            expiry = expiry,
            isConnected = isConnected,
            versionIdentifier = sessionIdentifier.versionIdentifier,
            sessionMeta = sessionMeta
        )
    }

    fun mapToSessionDetail(
        sessionIdentifier: WalletConnect.SessionIdentifier,
        dto: WalletConnectSessionDto,
        namespaces: Map<WalletConnectBlockchain, WalletConnect.Namespace.Session>,
        expiry: WalletConnect.Model.Expiry?,
        isConnected: Boolean,
        sessionMeta: WalletConnect.Session.Meta
    ): WalletConnect.SessionDetail {
        return WalletConnect.SessionDetail(
            sessionIdentifier = sessionIdentifier,
            topic = dto.wcSession.topic,
            peerMeta = peerMetaMapper.mapToPeerMeta(dto.peerMeta),
            namespaces = namespaces,
            creationDateTimestamp = dto.dateTimeStamp,
            fallbackBrowserGroupResponse = dto.fallbackBrowserGroupResponse,
            expiry = expiry,
            isConnected = isConnected,
            versionIdentifier = sessionIdentifier.versionIdentifier,
            sessionMeta = sessionMeta
        )
    }
}
