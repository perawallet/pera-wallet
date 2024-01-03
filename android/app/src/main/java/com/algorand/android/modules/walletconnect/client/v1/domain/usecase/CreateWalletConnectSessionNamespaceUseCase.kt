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

import com.algorand.android.modules.walletconnect.client.v1.domain.decider.WalletConnectV1BlockchainDecider
import com.algorand.android.modules.walletconnect.client.v1.domain.decider.WalletConnectV1ChainIdentifierDecider
import com.algorand.android.modules.walletconnect.client.v1.model.WalletConnectV1ChainIdentifier
import com.algorand.android.modules.walletconnect.client.v1.utils.WalletConnectClientV1Utils
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectBlockchain
import com.algorand.android.modules.walletconnect.mapper.WalletConnectConnectedAccountMapper
import com.algorand.android.modules.walletconnect.mapper.WalletConnectNamespaceMapper
import javax.inject.Inject

class CreateWalletConnectSessionNamespaceUseCase @Inject constructor(
    private val namespaceMapper: WalletConnectNamespaceMapper,
    private val blockchainDecider: WalletConnectV1BlockchainDecider,
    private val connectedAccountMapper: WalletConnectConnectedAccountMapper,
    private val chainIdentifierDecider: WalletConnectV1ChainIdentifierDecider
) {

    operator fun invoke(
        accountAddresses: List<String>,
        chainId: Long?
    ): Map<WalletConnectBlockchain, WalletConnect.Namespace.Session> {
        val blockchain = blockchainDecider.decideBlockchain(chainId)
        val chainIdList = getChainIdList(chainId)
        val connectedAccounts = accountAddresses.map { address ->
            val chainIdentifier = chainIdentifierDecider.decideChainIdentifier(chainId)
            connectedAccountMapper.mapToConnectedAccount(address, chainIdentifier, blockchain)
        }
        val sessionNamespace = namespaceMapper.mapToSessionNamespace(
            accountList = connectedAccounts,
            methodList = WalletConnectClientV1Utils.getDefaultSessionMethods(),
            eventList = WalletConnectClientV1Utils.getDefaultSessionEvents(),
            chainList = chainIdList,
            versionIdentifier = WalletConnectClientV1Utils.getWalletConnectV1VersionIdentifier()
        )
        return mapOf(blockchain to sessionNamespace)
    }

    private fun getChainIdList(chainId: Long?): List<WalletConnect.ChainIdentifier> {
        return with(chainIdentifierDecider) {
            if (chainId == WalletConnectV1ChainIdentifier.MAINNET_BACKWARD_SUPPORTABILITY.id) {
                listOf(
                    decideChainIdentifier(WalletConnectV1ChainIdentifier.MAINNET.id),
                    decideChainIdentifier(WalletConnectV1ChainIdentifier.TESTNET.id),
                )
            } else {
                listOf(decideChainIdentifier(chainId))
            }
        }
    }
}
