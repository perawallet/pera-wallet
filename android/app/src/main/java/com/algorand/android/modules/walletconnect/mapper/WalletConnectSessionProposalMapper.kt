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
import javax.inject.Inject

class WalletConnectSessionProposalMapper @Inject constructor() {

    fun mapToProposal(
        proposalIdentifier: WalletConnect.Session.ProposalIdentifier,
        relayProtocol: String?,
        relayData: String?,
        peerMeta: WalletConnect.PeerMeta,
        namespaces: WalletConnect.Namespace.Proposal,
        requiredNamespaces: Map<String, WalletConnect.Namespace.Proposal>,
        chainIdentifier: WalletConnect.ChainIdentifier,
        fallbackBrowserGroupResponse: String?
    ): WalletConnect.Session.Proposal {
        return WalletConnect.Session.Proposal(
            proposalIdentifier = proposalIdentifier,
            relayProtocol = relayProtocol,
            relayData = relayData,
            peerMeta = peerMeta,
            namespaces = namespaces,
            requiredNamespaces = requiredNamespaces,
            chainIdentifier = chainIdentifier,
            versionIdentifier = proposalIdentifier.versionIdentifier,
            fallbackBrowserGroupResponse = fallbackBrowserGroupResponse
        )
    }
}
