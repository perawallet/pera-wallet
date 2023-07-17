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

import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectV2ProposalIdentifierMapper
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.WalletConnectPeerMetaMapper
import com.algorand.android.modules.walletconnect.client.v2.walletdelegate.mapper.WalletConnectSessionProposalMapper
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectBlockchain
import com.walletconnect.sign.client.Sign

class WalletConnectSessionProposalMapperImpl(
    private val peerMetaMapper: WalletConnectPeerMetaMapper,
    private val proposalIdentifierMapper: WalletConnectV2ProposalIdentifierMapper
) : WalletConnectSessionProposalMapper {

    override fun mapToSessionProposal(
        sessionProposal: Sign.Model.SessionProposal,
        namespaces: Map<WalletConnectBlockchain, WalletConnect.Namespace.Proposal>,
        fallbackBrowserUrl: String?,
    ): WalletConnect.Session.Proposal {
        val peerMeta = peerMetaMapper.mapToPeerMeta(
            name = sessionProposal.name,
            url = sessionProposal.url,
            description = sessionProposal.description,
            icons = sessionProposal.icons.map { it.toString() },
            redirectUrl = null
        )
        val proposalIdentifier = proposalIdentifierMapper.mapToProposalIdentifier(sessionProposal.proposerPublicKey)
        return WalletConnect.Session.Proposal(
            proposalIdentifier = proposalIdentifier,
            relayProtocol = sessionProposal.relayProtocol,
            relayData = sessionProposal.relayData,
            peerMeta = peerMeta,
            requiredNamespaces = namespaces,
            fallbackBrowserGroupResponse = fallbackBrowserUrl,
            versionIdentifier = proposalIdentifier.versionIdentifier
        )
    }
}
