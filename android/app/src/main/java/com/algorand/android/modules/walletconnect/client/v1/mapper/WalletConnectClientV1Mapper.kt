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

package com.algorand.android.modules.walletconnect.client.v1.mapper

import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionDTO
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionMetaDTO
import com.algorand.android.modules.walletconnect.client.v1.session.WalletConnectSessionCachedData
import com.algorand.android.modules.walletconnect.client.v1.utils.WalletConnectClientV1Utils.getWalletConnectV1VersionIdentifier
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.mapper.WalletConnectConnectionStateMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectErrorMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectPeerMetaMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectSessionDeleteMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectSessionDetailMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectSessionErrorMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectSessionProposalMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectSessionRequestMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectSessionSettleMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectSessionUpdateMapper
import javax.inject.Inject
import org.walletconnect.Session

@SuppressWarnings("LongParameterList")
class WalletConnectClientV1Mapper @Inject constructor(
    private val sessionProposalMapper: WalletConnectSessionProposalMapper,
    private val sessionUpdateMapper: WalletConnectSessionUpdateMapper,
    private val sessionRequestMapper: WalletConnectSessionRequestMapper,
    private val errorMapper: WalletConnectErrorMapper,
    private val sessionErrorMapper: WalletConnectSessionErrorMapper,
    private val sessionSettleMapper: WalletConnectSessionSettleMapper,
    private val sessionDetailMapper: WalletConnectSessionDetailMapper,
    private val peerMetaMapper: WalletConnectPeerMetaMapper,
    private val connectionStateMapper: WalletConnectConnectionStateMapper,
    private val proposalIdentifierMapper: WalletConnectV1ProposalIdentifierMapper,
    private val requestIdentifierMapper: WalletConnectV1RequestIdentifierMapper,
    private val sessionIdentifierMapper: WalletConnectV1SessionIdentifierMapper,
    private val sessionMetaMapper: WalletConnectSessionMetaMapper,
    private val sessionDeleteMapper: WalletConnectSessionDeleteMapper
) {

    fun mapToSessionProposal(
        sessionId: Long,
        call: Session.MethodCall.SessionRequest,
        fallbackBrowserGroupResponse: String?,
        namespaces: WalletConnect.Namespace.Proposal
    ): WalletConnect.Session.Proposal {
        return sessionProposalMapper.mapToProposal(
            proposalIdentifier = proposalIdentifierMapper.mapToProposalIdentifier(sessionId),
            relayProtocol = null,
            relayData = null,
            peerMeta = peerMetaMapper.mapToPeerMeta(call.peer.meta),
            namespaces = namespaces,
            requiredNamespaces = emptyMap(), // TODO
            chainIdentifier = WalletConnect.ChainIdentifier.MAINNET,
            fallbackBrowserGroupResponse = fallbackBrowserGroupResponse
        )
    }

    fun mapToSessionUpdateSuccess(
        sessionId: Long,
        chainId: WalletConnect.ChainIdentifier,
        accountList: List<String>
    ): WalletConnect.Session.Update {
        return sessionUpdateMapper.mapToSessionUpdateSuccess(
            sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(sessionId),
            chainIdentifier = chainId,
            accountList = accountList
        )
    }

    fun mapToSessionRequest(
        sessionDetail: WalletConnect.SessionDetail,
        call: Session.MethodCall.Custom,
        peerMeta: WalletConnect.PeerMeta,
        chainId: WalletConnect.ChainIdentifier?
    ): WalletConnect.Model.SessionRequest {
        return sessionRequestMapper.mapToSessionRequest(
            sessionIdentifier = sessionDetail.sessionIdentifier,
            peerMeta = peerMeta,
            method = call.method,
            payload = call.params,
            chainIdentifier = chainId,
            requestIdentifier = requestIdentifierMapper.mapToRequestIdentifier(call.id)
        )
    }

    fun mapToError(
        throwable: Throwable,
        message: String?
    ): WalletConnect.Model.Error {
        return errorMapper.mapToError(
            versionIdentifier = getWalletConnectV1VersionIdentifier(),
            throwable = throwable,
            message = message
        )
    }

    fun mapToSessionError(
        sessionId: Long,
        throwable: Throwable
    ): WalletConnect.Session.Error {
        return sessionErrorMapper.mapToSessionError(
            sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(sessionId),
            throwable = throwable
        )
    }

    fun mapToSettleSuccess(
        cachedData: WalletConnectSessionCachedData,
        namespaces: Map<String, WalletConnect.Namespace.Session>,
        creationDateTimestamp: Long,
        isSubscribed: Boolean,
        isConnected: Boolean,
        expiry: WalletConnect.Model.Expiry?,
        clientId: String
    ): WalletConnect.Session.Settle.Result {
        val sessionDetail = sessionDetailMapper.mapToSessionDetail(
            sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(cachedData.sessionId),
            topic = cachedData.sessionConfig.handshakeTopic,
            peerMeta = peerMetaMapper.mapToPeerMeta(cachedData.session.peerMeta()),
            namespaces = namespaces,
            creationDateTimestamp = creationDateTimestamp,
            isSubscribed = isSubscribed,
            isConnected = isConnected,
            fallbackBrowserGroupResponse = cachedData.fallbackBrowserGroupResponse,
            expiry = expiry,
            sessionMeta = sessionMetaMapper.mapToSessionMeta(cachedData.sessionConfig)
        )
        return sessionSettleMapper.mapToSessionSettleSuccess(sessionDetail, clientId)
    }

    fun mapToConnectionState(
        sessionDetail: WalletConnect.SessionDetail,
        isConnected: Boolean,
        clientId: String?
    ): WalletConnect.Model.ConnectionState {
        return connectionStateMapper.mapToConnectionState(
            sessionDetail = sessionDetail,
            isConnected = isConnected,
            clientId = clientId
        )
    }

    fun mapToSessionDetail(
        walletConnectSessionDTO: WalletConnectSessionDTO,
        namespaces: Map<String, WalletConnect.Namespace.Session>
    ): WalletConnect.SessionDetail {
        val sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(walletConnectSessionDTO.id)
        return sessionDetailMapper.mapToSessionDetail(
            sessionIdentifier = sessionIdentifier,
            topic = walletConnectSessionDTO.wcSession.topic,
            peerMeta = with(walletConnectSessionDTO.peerMeta) {
                peerMetaMapper.mapToPeerMeta(name, url, description, icons, null)
            },
            isConnected = walletConnectSessionDTO.isConnected,
            namespaces = namespaces,
            creationDateTimestamp = walletConnectSessionDTO.dateTimeStamp,
            isSubscribed = walletConnectSessionDTO.isSubscribed,
            fallbackBrowserGroupResponse = walletConnectSessionDTO.fallbackBrowserGroupResponse,
            expiry = null,
            sessionMeta = sessionMetaMapper.mapToSessionMeta(walletConnectSessionDTO.wcSession)
        )
    }

    fun mapToSessionDetail(
        entity: WalletConnectSessionDTO,
        creationDateTimestamp: Long,
        isSubscribed: Boolean,
        fallbackBrowserGroupResponse: String?,
        namespaces: Map<String, WalletConnect.Namespace.Session>,
        sessionMeta: WalletConnectSessionMetaDTO
    ): WalletConnect.SessionDetail {
        val sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(entity.id)
        val peerMeta = peerMetaMapper.mapToPeerMeta(entity.peerMeta)
        val topic = entity.wcSession.topic
        return sessionDetailMapper.mapToSessionDetail(
            sessionIdentifier = sessionIdentifier,
            topic = topic,
            peerMeta = peerMeta,
            namespaces = namespaces,
            isConnected = entity.isConnected,
            creationDateTimestamp = creationDateTimestamp,
            isSubscribed = isSubscribed,
            fallbackBrowserGroupResponse = fallbackBrowserGroupResponse,
            expiry = null,
            sessionMeta = sessionMetaMapper.mapToSessionMeta(sessionMeta)
        )
    }

    fun mapToSessionDeleteSuccess(
        sessionIdentifier: WalletConnect.SessionIdentifier,
        reason: String
    ): WalletConnect.Session.Delete.Success {
        return sessionDeleteMapper.mapToSessionDeleteSuccess(sessionIdentifier, reason)
    }

    fun mapToSessionDeleteSuccess(
        sessionId: Long,
        reason: String
    ): WalletConnect.Session.Delete.Success {
        val sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(sessionId)
        return sessionDeleteMapper.mapToSessionDeleteSuccess(sessionIdentifier, reason)
    }

    fun mapToSessionIdentifier(sessionId: Long): WalletConnect.SessionIdentifier {
        return sessionIdentifierMapper.mapToSessionIdentifier(sessionId)
    }
}
