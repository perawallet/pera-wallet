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
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectConnectedAccount
import com.algorand.android.modules.walletconnect.mapper.WalletConnectConnectedAccountMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectNamespaceMapper
import com.walletconnect.sign.client.Sign
import javax.inject.Inject

class CreateWalletConnectSessionNamespaceUseCase @Inject constructor(
    private val blockchainDecider: WalletConnectV2BlockchainDecider,
    private val methodDecider: WalletConnectV2MethodDecider,
    private val eventDecider: WalletConnectV2EventDecider,
    private val namespaceMapper: WalletConnectNamespaceMapper,
    private val connectedAccountMapper: WalletConnectConnectedAccountMapper,
    private val caipUseCase: WalletConnectV2CaipUseCase,
    private val chainIdentifierDecider: WalletConnectV2ChainIdentifierDecider
) {

    operator fun invoke(session: Sign.Model.Session): Map<WalletConnectBlockchain, WalletConnect.Namespace.Session> {
        val sessionNamespaceMap = mutableMapOf<WalletConnectBlockchain, WalletConnect.Namespace.Session>()
        session.namespaces.forEach { (blockchainName, sessionNamespace) ->
            val blockchain = blockchainDecider.decideBlockchain(blockchainName)
            val methods = sessionNamespace.methods.map { methodDecider.decideMethod(it) }
            val events = sessionNamespace.events.map { eventDecider.decideEvent(it) }
            val connectedAccounts = getConnectedAccountsList(sessionNamespace.accounts)
            val namespaces = namespaceMapper.mapToSessionNamespace(
                accountList = connectedAccounts,
                methodList = methods,
                eventList = events,
                chainList = sessionNamespace.chains?.map { chainIdentifierDecider.decideChainIdentifier(it) }.orEmpty(),
                versionIdentifier = WalletConnectClientV2Utils.getWalletConnectV2VersionIdentifier()
            )
            sessionNamespaceMap[blockchain] = namespaces
        }
        return sessionNamespaceMap
    }

    private fun getConnectedAccountsList(accountsAsCaip: List<String>): List<WalletConnectConnectedAccount> {
        return accountsAsCaip.mapNotNull { accountCaip ->
            val walletConnectV2caip = caipUseCase.parse(accountCaip)
            connectedAccountMapper.mapToConnectedAccount(
                accountAddress = walletConnectV2caip.address ?: return@mapNotNull null,
                chainIdentifier = chainIdentifierDecider.decideChainIdentifier(walletConnectV2caip.chainId),
                blockchain = blockchainDecider.decideBlockchain(walletConnectV2caip.blockchain)
            )
        }
    }
}
