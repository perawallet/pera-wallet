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

package com.algorand.android.modules.walletconnect.client.v2.domain.usecase

import com.algorand.android.modules.walletconnect.client.v2.domain.decider.WalletConnectV2BlockchainDecider
import com.algorand.android.modules.walletconnect.client.v2.domain.decider.WalletConnectV2ChainIdentifierDecider
import com.algorand.android.modules.walletconnect.client.v2.domain.decider.WalletConnectV2EventDecider
import com.algorand.android.modules.walletconnect.client.v2.domain.decider.WalletConnectV2MethodDecider
import com.algorand.android.modules.walletconnect.client.v2.utils.WalletConnectClientV2Utils
import com.algorand.android.modules.walletconnect.client.v2.utils.WalletConnectV2CaipUseCase
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectBlockchain
import com.algorand.android.modules.walletconnect.mapper.WalletConnectNamespaceMapper
import com.walletconnect.sign.client.Sign
import javax.inject.Inject

class CreateWalletConnectProposalNamespaceUseCase @Inject constructor(
    private val namespaceMapper: WalletConnectNamespaceMapper,
    private val chainIdentifierDecider: WalletConnectV2ChainIdentifierDecider,
    private val blockchainDecider: WalletConnectV2BlockchainDecider,
    private val methodDecider: WalletConnectV2MethodDecider,
    private val eventDecider: WalletConnectV2EventDecider,
    private val caipUseCase: WalletConnectV2CaipUseCase
) {

    operator fun invoke(
        sessionProposal: Sign.Model.SessionProposal
    ): Map<WalletConnectBlockchain, WalletConnect.Namespace.Proposal> {
        val proposalNamespaceMap = mutableMapOf<WalletConnectBlockchain, WalletConnect.Namespace.Proposal>()
        sessionProposal.requiredNamespaces.forEach { (blockchainName, proposalNamespace) ->
            val blockchain = blockchainDecider.decideBlockchain(blockchainName)
            val methods = proposalNamespace.methods.map { methodDecider.decideMethod(it) }
            val events = proposalNamespace.events.map { eventDecider.decideEvent(it) }
            val chainIds = proposalNamespace.chains?.map { caipUseCase.parse(it) }?.map { it.chainId }
            val namespaces = namespaceMapper.mapToProposalNamespace(
                chainIdList = chainIds?.map { chainIdentifierDecider.decideChainIdentifier(it) }.orEmpty(),
                methodList = methods,
                eventList = events,
                versionIdentifier = WalletConnectClientV2Utils.getWalletConnectV2VersionIdentifier()
            )
            proposalNamespaceMap[blockchain] = namespaces
        }
        return proposalNamespaceMap
    }
}
