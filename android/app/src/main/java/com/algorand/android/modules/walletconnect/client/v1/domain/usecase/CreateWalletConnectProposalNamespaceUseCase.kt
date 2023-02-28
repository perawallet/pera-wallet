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

import com.algorand.android.modules.walletconnect.client.v1.decider.WalletConnectV1ChainIdentifierDecider
import com.algorand.android.modules.walletconnect.client.v1.mapper.WalletConnectV1SessionIdentifierMapper
import com.algorand.android.modules.walletconnect.client.v1.utils.WalletConnectClientV1Utils
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.mapper.WalletConnectNamespaceMapper
import javax.inject.Inject

class CreateWalletConnectProposalNamespaceUseCase @Inject constructor(
    private val namespaceMapper: WalletConnectNamespaceMapper,
    private val chainIdentifierDecider: WalletConnectV1ChainIdentifierDecider,
    private val sessionIdentifierMapper: WalletConnectV1SessionIdentifierMapper
) {

    operator fun invoke(
        sessionId: Long,
        chainId: Long?,
    ): WalletConnect.Namespace.Proposal {
        val sessionIdentifier = sessionIdentifierMapper.mapToSessionIdentifier(sessionId)
        return namespaceMapper.mapToProposalNamespace(
            chainIdList = listOf(chainIdentifierDecider.decideChainIdentifier(chainId)),
            methodList = WalletConnectClientV1Utils.getDefaultSessionMethods(),
            eventList = WalletConnectClientV1Utils.getDefaultSessionEvents(),
            versionIdentifier = sessionIdentifier.versionIdentifier
        )
    }
}
