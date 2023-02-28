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
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.mapper.WalletConnectSessionDetailMapper
import javax.inject.Inject
import javax.inject.Named

class GetDisconnectedWalletConnectSessionsUseCase @Inject constructor(
    @Named(WalletConnectRepository.INJECTION_NAME)
    private val walletConnectRepository: WalletConnectRepository,
    private val sessionDetailMapper: WalletConnectSessionDetailMapper,
    private val sessionIdentifierMapper: WalletConnectV1SessionIdentifierMapper,
    private val createWalletConnectSessionNamespaceUseCase: CreateWalletConnectSessionNamespaceUseCase,
    private val getConnectedAccountsOfWalletConnectSessionUseCase: GetConnectedAccountsOfWalletConnectSessionUseCase,
    private val sessionMetaMapper: WalletConnectSessionMetaMapper
) {

    suspend operator fun invoke(): List<WalletConnect.SessionDetail> {
        return walletConnectRepository.getAllDisconnectedSessions().map { dto ->
            val connectedAccounts = getConnectedAccountsOfWalletConnectSessionUseCase(dto.id).map {
                it.connectedAccountsAddress
            }
            val sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(dto.id)
            sessionDetailMapper.mapToSessionDetail(
                sessionIdentifier = sessionIdentifier,
                dto = dto,
                namespaces = createWalletConnectSessionNamespaceUseCase(connectedAccounts),
                expiry = null,
                isConnected = false,
                sessionMeta = sessionMetaMapper.mapToSessionMeta(dto.wcSession)
            )
        }
    }
}
