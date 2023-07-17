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

package com.algorand.android.modules.walletconnect.client.v2.mapper

import com.algorand.android.modules.walletconnect.client.v2.domain.model.WalletConnectSessionDto
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectBlockchain
import com.algorand.android.modules.walletconnect.mapper.WalletConnectConnectionStateMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectExpiryMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectPeerMetaMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectSessionDeleteMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectSessionDetailMapper
import com.walletconnect.android.Core
import com.walletconnect.sign.client.Sign
import javax.inject.Inject

@Suppress("LongParameterList")
class WalletConnectClientV2Mapper @Inject constructor(
    private val sessionDetailMapper: WalletConnectSessionDetailMapper,
    private val sessionIdentifierMapper: WalletConnectV2SessionIdentifierMapper,
    private val sessionMetaMapper: WalletConnectV2SessionMetaMapper,
    private val expiryMapper: WalletConnectExpiryMapper,
    private val peerMetaMapper: WalletConnectPeerMetaMapper,
    private val sessionDeleteMapper: WalletConnectSessionDeleteMapper,
    private val connectionStateMapper: WalletConnectConnectionStateMapper
) {

    fun mapToPair(url: String) = Core.Params.Pair(url)

    fun mapToSessionApprove(
        proposerPublicKey: String,
        accountListAsCaip: List<String>,
        namespaces: Map<WalletConnectBlockchain, WalletConnect.Namespace.Proposal>,
        chainListAsCaip: MutableMap<String, List<String>>,
    ): Sign.Params.Approve {
        return Sign.Params.Approve(
            proposerPublicKey = proposerPublicKey,
            namespaces = mapToSignApproveNamespaces(namespaces, accountListAsCaip, chainListAsCaip)
        )
    }

    private fun mapToSignApproveNamespaces(
        namespaces: Map<WalletConnectBlockchain, WalletConnect.Namespace.Proposal>,
        accountListAsCaip: List<String>,
        chainListAsCaip: MutableMap<String, List<String>>,
    ): Map<String, Sign.Model.Namespace.Session> {
        val sessionNamespaces = mutableMapOf<String, Sign.Model.Namespace.Session>()
        namespaces.forEach { (blockchain, namespace) ->
            val sessionNamespace = Sign.Model.Namespace.Session(
                accounts = accountListAsCaip,
                methods = namespace.methods.map { it.value },
                events = namespace.events.map { it.value },
                chains = chainListAsCaip[blockchain.value]
            )
            sessionNamespaces[blockchain.value] = sessionNamespace
        }
        return sessionNamespaces
    }

    fun mapToSessionReject(
        proposalIdentifier: WalletConnect.Session.ProposalIdentifier,
        reason: String
    ): Sign.Params.Reject {
        return Sign.Params.Reject(
            proposerPublicKey = proposalIdentifier.getIdentifier(),
            reason = reason
        )
    }

    fun mapToRequestReject(
        sessionTopic: String,
        requestId: Long,
        errorCode: Int,
        errorMessage: String
    ): Sign.Params.Response {
        val approveResponse = Sign.Model.JsonRpcResponse.JsonRpcError(
            id = requestId,
            code = errorCode,
            message = errorMessage
        )
        return Sign.Params.Response(
            sessionTopic = sessionTopic,
            jsonRpcResponse = approveResponse
        )
    }

    fun mapToRequestApprove(
        sessionIdentifier: WalletConnect.SessionIdentifier,
        requestIdentifier: WalletConnect.RequestIdentifier,
        payload: String
    ): Sign.Params.Response {
        val approveResponse = Sign.Model.JsonRpcResponse.JsonRpcResult(
            id = requestIdentifier.getIdentifier(),
            result = payload
        )
        return Sign.Params.Response(
            sessionTopic = sessionIdentifier.getIdentifier(),
            jsonRpcResponse = approveResponse
        )
    }

    fun mapToSessionDisconnect(sessionIdentifier: WalletConnect.SessionIdentifier): Sign.Params.Disconnect {
        return Sign.Params.Disconnect(
            sessionTopic = sessionIdentifier.getIdentifier()
        )
    }

    fun mapToSessionDetail(
        session: Sign.Model.Session,
        sessionDto: WalletConnectSessionDto,
        namespaces: Map<WalletConnectBlockchain, WalletConnect.Namespace.Session>,
        isConnected: Boolean
    ): WalletConnect.SessionDetail? {
        val peerMeta = mapToPeerMeta(session.metaData ?: return null)
        return sessionDetailMapper.mapToSessionDetail(
            sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(session.topic),
            topic = session.topic,
            peerMeta = peerMeta,
            namespaces = namespaces,
            creationDateTimestamp = sessionDto.creationDateTimestamp,
            isSubscribed = sessionDto.isSubscribed,
            isConnected = isConnected,
            fallbackBrowserGroupResponse = sessionDto.fallbackBrowserGroupResponse,
            expiry = expiryMapper.mapToExpiry(session.expiry),
            sessionMeta = sessionMetaMapper.mapToSessionMeta(session.topic)
        )
    }

    fun mapToSessionDeleteSuccess(
        deletedSessionIdentifier: WalletConnect.SessionIdentifier,
        reason: String
    ): WalletConnect.Session.Delete {
        return sessionDeleteMapper.mapToSessionDeleteSuccess(
            sessionIdentifier = deletedSessionIdentifier,
            reason = reason
        )
    }

    fun mapToPeerMeta(metaData: Core.Model.AppMetaData): WalletConnect.PeerMeta {
        return with(metaData) {
            peerMetaMapper.mapToPeerMeta(
                name = name,
                url = url,
                description = description,
                icons = icons,
                redirectUrl = redirect
            )
        }
    }

    fun mapToSessionUpdateRequest(
        sessionTopic: String,
        namespaces: Map<String, Sign.Model.Namespace.Session>
    ): Sign.Params.Update {
        return Sign.Params.Update(
            sessionTopic = sessionTopic,
            namespaces = namespaces
        )
    }

    fun mapToSessionNamespace(
        accountListAsCaip: List<String>,
        namespace: WalletConnect.Namespace.Session,
        chainListAsCaip: List<String>
    ): Sign.Model.Namespace.Session {
        return Sign.Model.Namespace.Session(
            accounts = accountListAsCaip,
            methods = namespace.methods.map { it.value },
            events = namespace.events.map { it.value },
            chains = chainListAsCaip
        )
    }

    fun mapToConnectionState(
        sessionDetail: WalletConnect.SessionDetail,
        socketConnectionOpen: Boolean,
        clientId: String?
    ): WalletConnect.Model.ConnectionState {
        return connectionStateMapper.mapToConnectionState(
            sessionDetail = sessionDetail,
            isConnected = socketConnectionOpen,
            clientId = clientId
        )
    }

    fun mapToExtend(sessionTopic: String): Sign.Params.Extend {
        return Sign.Params.Extend(sessionTopic)
    }

    fun mapToPing(sessionTopic: String): Sign.Params.Ping {
        return Sign.Params.Ping(sessionTopic)
    }

    fun mapToSessionIdentifier(sessionTopic: String): WalletConnect.SessionIdentifier {
        return sessionIdentifierMapper.mapToSessionIdentifier(sessionTopic)
    }
}
