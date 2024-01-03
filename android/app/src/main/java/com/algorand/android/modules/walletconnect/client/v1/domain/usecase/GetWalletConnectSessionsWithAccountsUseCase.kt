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
import com.algorand.android.modules.walletconnect.mapper.WalletConnectSessionDetailMapper
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.mapNotNull

class GetWalletConnectSessionsWithAccountsUseCase @Inject constructor(
    @Named(WalletConnectRepository.INJECTION_NAME)
    private val walletConnectRepository: WalletConnectRepository,
    private val sessionDetailMapper: WalletConnectSessionDetailMapper,
    private val getConnectedAccountsOfWalletConnectSessionUseCase: GetConnectedAccountsOfWalletConnectSessionUseCase,
    private val sessionIdentifierMapper: WalletConnectV1SessionIdentifierMapper,
    private val createWalletConnectSessionNamespaceUseCase: CreateWalletConnectSessionNamespaceUseCase,
    private val sessionMetaMapper: WalletConnectSessionMetaMapper,
    private val sessionCachedDataHandler: WalletConnectV1SessionCachedDataHandler
) {

    operator fun invoke(): Flow<List<WalletConnect.SessionDetail>> {
        val flow = walletConnectRepository.getAllWalletConnectSessionWithAccountAddresses()
        return flow.mapNotNull { wcSessionsWithAccounts ->
            wcSessionsWithAccounts?.map { wcSessionsWithAccount ->
                val wcSessionAccounts = getConnectedAccountsOfWalletConnectSessionUseCase(
                    wcSessionsWithAccount.walletConnectSessions.id
                )
                val accountAddresses = wcSessionAccounts.map { it.connectedAccountsAddress }
                val wcSessionDto = wcSessionsWithAccount.walletConnectSessions
                val wcSession = sessionCachedDataHandler.getSessionById(wcSessionDto.id)
                sessionDetailMapper.mapToSessionDetail(
                    dto = wcSessionDto,
                    namespaces = createWalletConnectSessionNamespaceUseCase.invoke(
                        accountAddresses = accountAddresses,
                        chainId = wcSession?.chainId
                    ),
                    sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(wcSessionDto.id),
                    expiry = null,
                    isConnected = wcSessionDto.isConnected,
                    sessionMeta = sessionMetaMapper.mapToSessionMeta(wcSessionDto.wcSession)
                )
            }
        }
    }
}
