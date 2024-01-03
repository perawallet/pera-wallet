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

import com.algorand.android.modules.walletconnect.client.v2.domain.WalletConnectV2SignClient
import com.algorand.android.modules.walletconnect.client.v2.domain.decider.WalletConnectV2ChainIdentifierDecider
import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectClientV2Mapper
import com.algorand.android.modules.walletconnect.client.v2.utils.WalletConnectV2CaipUseCase
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.walletconnect.sign.client.Sign
import javax.inject.Inject

class RemoveAccountFromV2SessionUseCase @Inject constructor(
    private val chainIdentifierDecider: WalletConnectV2ChainIdentifierDecider,
    private val caipUseCase: WalletConnectV2CaipUseCase,
    private val clientV2Mapper: WalletConnectClientV2Mapper,
    private val signClient: WalletConnectV2SignClient
) {

    operator fun invoke(sessionDetail: WalletConnect.SessionDetail, removedAccountAddress: String) {
        val sessionNamespaceMap = getUpdatedSessionNamespaceMap(sessionDetail, removedAccountAddress)
        val identifier = sessionDetail.sessionIdentifier.getIdentifier()
        val updateSession = clientV2Mapper.mapToSessionUpdateRequest(identifier, sessionNamespaceMap)
        signClient.update(updateSession)
    }

    private fun getUpdatedSessionNamespaceMap(
        sessionDetail: WalletConnect.SessionDetail,
        removedAccountAddress: String
    ): MutableMap<String, Sign.Model.Namespace.Session> {
        return mutableMapOf<String, Sign.Model.Namespace.Session>().apply {
            sessionDetail.namespaces.forEach { (blockchain, sessionNamespace) ->
                val updatedAccountAddressesAsCaip = sessionNamespace.accounts.filter {
                    it.accountAddress != removedAccountAddress
                }.map { connectedAccount ->
                    val connectedChainId = chainIdentifierDecider.decideChainId(connectedAccount.chainIdentifier)
                    caipUseCase.mergeBlockchainNodeAndAddress(
                        blockchain = connectedAccount.connectedBlockchain.value,
                        node = connectedChainId,
                        address = connectedAccount.accountAddress
                    )
                }
                val chainListAsCaip = sessionNamespace.chains.map {
                    caipUseCase.mergeBlockchainAndChains(blockchain, it)
                }
                val signNamespace = clientV2Mapper.mapToSessionNamespace(
                    updatedAccountAddressesAsCaip,
                    sessionNamespace,
                    chainListAsCaip
                )
                put(blockchain.value, signNamespace)
            }
        }
    }
}
