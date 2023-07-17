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

import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectBlockchain
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectProposalNamespace
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectVersionIdentifier
import javax.inject.Inject

class WalletConnectProposalNamespaceMapper @Inject constructor(
    private val sessionProposalMapper: WalletConnectNamespaceMapper
) {

    fun mapToProposalNamespace(
        namespaceMap: Map<WalletConnectBlockchain, WalletConnectProposalNamespace>,
        versionIdentifier: WalletConnectVersionIdentifier
    ): Map<WalletConnectBlockchain, WalletConnect.Namespace.Proposal> {
        return mutableMapOf<WalletConnectBlockchain, WalletConnect.Namespace.Proposal>().apply {
            namespaceMap.forEach { (blockchain, namespace) ->
                put(blockchain, mapToSessionNamespaceProposal(namespace, versionIdentifier))
            }
        }
    }

    fun mapToProposalNamespace(
        namespaceMap: Map<WalletConnectBlockchain, WalletConnect.Namespace.Proposal>
    ): Map<WalletConnectBlockchain, WalletConnectProposalNamespace> {
        return mutableMapOf<WalletConnectBlockchain, WalletConnectProposalNamespace>().apply {
            namespaceMap.forEach { (blockchain, namespace) ->
                put(blockchain, mapToProposalNamespace(namespace))
            }
        }
    }

    private fun mapToProposalNamespace(namespace: WalletConnect.Namespace.Proposal): WalletConnectProposalNamespace {
        return WalletConnectProposalNamespace(
            chains = namespace.chains,
            methods = namespace.methods,
            events = namespace.events
        )
    }

    private fun mapToSessionNamespaceProposal(
        proposalNamespace: WalletConnectProposalNamespace,
        versionIdentifier: WalletConnectVersionIdentifier
    ): WalletConnect.Namespace.Proposal {
        return sessionProposalMapper.mapToProposalNamespace(
            chainIdList = proposalNamespace.chains,
            methodList = proposalNamespace.methods,
            eventList = proposalNamespace.events,
            versionIdentifier = versionIdentifier
        )
    }
}
