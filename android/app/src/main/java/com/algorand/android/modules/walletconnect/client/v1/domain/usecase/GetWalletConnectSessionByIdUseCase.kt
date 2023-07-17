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

package com.algorand.android.modules.walletconnect.client.v1.domain.usecase

import com.algorand.android.modules.walletconnect.client.v1.domain.repository.WalletConnectRepository
import com.algorand.android.modules.walletconnect.client.v1.mapper.WalletConnectSessionMetaMapper
import com.algorand.android.modules.walletconnect.client.v1.mapper.WalletConnectV1SessionIdentifierMapper
import com.algorand.android.modules.walletconnect.client.v1.session.WalletConnectV1SessionCachedDataHandler
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.mapper.WalletConnectPeerMetaMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectSessionDetailMapper
import javax.inject.Inject
import javax.inject.Named

class GetWalletConnectSessionByIdUseCase @Inject constructor(
    private val sessionDetailMapper: WalletConnectSessionDetailMapper,
    private val peerMetaMapper: WalletConnectPeerMetaMapper,
    @Named(WalletConnectRepository.INJECTION_NAME)
    private val walletConnectRepository: WalletConnectRepository,
    private val sessionIdentifierMapper: WalletConnectV1SessionIdentifierMapper,
    private val createWalletConnectSessionNamespaceUseCase: CreateWalletConnectSessionNamespaceUseCase,
    private val sessionMetaMapper: WalletConnectSessionMetaMapper,
    private val sessionCachedDataHandler: WalletConnectV1SessionCachedDataHandler
) {

    suspend operator fun invoke(sessionId: Long): WalletConnect.SessionDetail? {
        return walletConnectRepository.getSessionById(sessionId)?.let { wcSessionDto ->
            val connectedAccounts = walletConnectRepository.getConnectedAccountsOfSession(wcSessionDto.id)?.map {
                it.connectedAccountsAddress
            }.orEmpty()
            val wcSession = sessionCachedDataHandler.getSessionById(wcSessionDto.id)
            sessionDetailMapper.mapToSessionDetail(
                sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(sessionId),
                topic = wcSessionDto.wcSession.topic,
                peerMeta = peerMetaMapper.mapToPeerMeta(wcSessionDto.peerMeta),
                namespaces = createWalletConnectSessionNamespaceUseCase.invoke(
                    accountAddresses = connectedAccounts,
                    chainId = wcSession?.chainId
                ),
                creationDateTimestamp = wcSessionDto.dateTimeStamp,
                isSubscribed = wcSessionDto.isSubscribed,
                isConnected = wcSessionDto.isConnected,
                fallbackBrowserGroupResponse = wcSessionDto.fallbackBrowserGroupResponse,
                expiry = null,
                sessionMeta = sessionMetaMapper.mapToSessionMeta(wcSessionDto.wcSession)
            )
        }
    }
}
