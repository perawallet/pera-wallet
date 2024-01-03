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

import com.algorand.android.modules.walletconnect.client.v2.domain.decider.WalletConnectV2ChainIdentifierDecider
import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectV2RequestIdentifierMapper
import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectV2SessionIdentifierMapper
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.WalletConnectSessionRequestMapper
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.utils.fromJson
import com.google.gson.Gson
import com.walletconnect.sign.client.Sign

class WalletConnectSessionRequestMapperImpl(
    private val sessionIdentifierMapper: WalletConnectV2SessionIdentifierMapper,
    private val chainIdentifierDecider: WalletConnectV2ChainIdentifierDecider,
    private val requestIdentifierMapper: WalletConnectV2RequestIdentifierMapper,
    private val gson: Gson // TODO change here with PeraSerializer when ASB is merged
) : WalletConnectSessionRequestMapper {

    override fun mapToSessionRequest(
        sessionRequest: Sign.Model.SessionRequest,
        peerMeta: WalletConnect.PeerMeta
    ): WalletConnect.Model.SessionRequest {
        val requestIdentifier = requestIdentifierMapper.mapToRequestIdentifier(sessionRequest.request.id)
        return WalletConnect.Model.SessionRequest(
            sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(sessionRequest.topic),
            chainIdentifier = chainIdentifierDecider.decideChainIdentifier(sessionRequest.chainId),
            peerMetaData = peerMeta,
            request = mapToJsonRpcRequest(
                requestIdentifier,
                sessionRequest.request.method,
                gson.fromJson<List<*>>(sessionRequest.request.params)
            ),
            versionIdentifier = requestIdentifier.versionIdentifier
        )
    }

    private fun mapToJsonRpcRequest(
        requestIdentifier: WalletConnect.RequestIdentifier,
        method: String,
        params: List<*>?
    ): WalletConnect.Model.SessionRequest.JSONRPCRequest {
        return WalletConnect.Model.SessionRequest.JSONRPCRequest(
            requestIdentifier = requestIdentifier,
            method = method,
            params = params,
            versionIdentifier = requestIdentifier.versionIdentifier
        )
    }
}
