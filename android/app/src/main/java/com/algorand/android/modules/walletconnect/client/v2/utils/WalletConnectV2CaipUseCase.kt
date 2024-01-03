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

package com.algorand.android.modules.walletconnect.client.v2.utils

import com.algorand.android.modules.walletconnect.client.v2.domain.decider.WalletConnectV2ChainIdentifierDecider
import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectV2CaipMapper
import com.algorand.android.modules.walletconnect.client.v2.model.WalletConnectV2Caip
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect.ChainIdentifier
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectBlockchain
import javax.inject.Inject

class WalletConnectV2CaipUseCase @Inject constructor(
    private val caipMapper: WalletConnectV2CaipMapper,
    private val chainIdentifierDecider: WalletConnectV2ChainIdentifierDecider
) {

    fun parse(namespace: String): WalletConnectV2Caip {
        val splittedNamespace = namespace.split(CAIP_SPLIT_KEY)
        return caipMapper.mapToCaip(
            blockchain = splittedNamespace.getOrNull(BLOCKCHAIN_INDEX),
            chainId = splittedNamespace.getOrNull(CHAIN_ID_INDEX),
            address = splittedNamespace.getOrNull(ADDRESS_INDEX)
        )
    }

    fun create(
        accountAddresses: List<String>,
        requiredNamespaces: Map<WalletConnectBlockchain, WalletConnect.Namespace.Proposal>
    ): List<String> {
        val caipChainsAndAddressesList = mutableListOf<String>()

        requiredNamespaces.forEach { (blockchain, namespace) ->
            namespace.chains.forEach { chainIdentifier ->
                val chainId = chainIdentifierDecider.decideChainId(chainIdentifier)
                accountAddresses.forEach { address ->
                    val caip = mergeBlockchainNodeAndAddress(blockchain.value, chainId, address)
                    caipChainsAndAddressesList.add(caip)
                }
            }
        }

        return caipChainsAndAddressesList
    }

    fun mergeBlockchainAndChains(blockchain: WalletConnectBlockchain, chainIdentifier: ChainIdentifier): String {
        val walletConnectV2ChainId = chainIdentifierDecider.decideChainId(chainIdentifier)
        return "${blockchain.value}$CAIP_SPLIT_KEY$walletConnectV2ChainId"
    }

    fun mergeBlockchainNodeAndAddress(blockchain: String, node: String, address: String): String {
        return "$blockchain$CAIP_SPLIT_KEY$node$CAIP_SPLIT_KEY$address"
    }

    companion object {
        private const val BLOCKCHAIN_INDEX = 0
        private const val CHAIN_ID_INDEX = 1
        private const val ADDRESS_INDEX = 2
        private const val CAIP_SPLIT_KEY = ":"
    }
}
