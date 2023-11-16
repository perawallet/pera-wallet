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

package com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.impl

import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectV2SessionIdentifierMapper
import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectV2SessionMetaMapper
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.WalletConnectSessionSettleSuccessMapper
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectBlockchain
import com.algorand.android.modules.walletconnect.mapper.WalletConnectExpiryMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectSessionDetailMapper
import com.walletconnect.sign.client.Sign

class WalletConnectSessionSettleSuccessMapperImpl(
    private val sessionIdentifierMapper: WalletConnectV2SessionIdentifierMapper,
    private val sessionDetailMapper: WalletConnectSessionDetailMapper,
    private val expiryMapper: WalletConnectExpiryMapper,
    private val sessionMetaMapper: WalletConnectV2SessionMetaMapper
) : WalletConnectSessionSettleSuccessMapper {

    override fun mapToSessionSettleSuccess(
        settleSessionResponse: Sign.Model.SettledSessionResponse.Result,
        peerMeta: WalletConnect.PeerMeta,
        namespaces: Map<WalletConnectBlockchain, WalletConnect.Namespace.Session>,
        creationDateTimestamp: Long,
        isConnected: Boolean,
        fallbackBrowserGroupResponse: String?
    ): WalletConnect.Session.Settle.Result {
        val sessionDetail = with(settleSessionResponse.session) {
            val sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(topic)
            sessionDetailMapper.mapToSessionDetail(
                sessionIdentifier = sessionIdentifier,
                topic = topic,
                peerMeta = peerMeta,
                namespaces = namespaces,
                creationDateTimestamp = creationDateTimestamp,
                isConnected = isConnected,
                fallbackBrowserGroupResponse = fallbackBrowserGroupResponse,
                expiry = expiryMapper.mapToExpiry(expiry),
                sessionMeta = sessionMetaMapper.mapToSessionMeta(topic)
            )
        }
        // TODO Check client id after implementing push notifications
        return WalletConnect.Session.Settle.Result(
            session = sessionDetail,
            clientId = settleSessionResponse.session.topic,
            versionIdentifier = sessionDetail.versionIdentifier
        )
    }
}
