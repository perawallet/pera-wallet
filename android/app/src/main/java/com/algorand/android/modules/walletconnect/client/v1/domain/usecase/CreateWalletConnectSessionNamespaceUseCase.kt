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

import com.algorand.android.modules.walletconnect.client.v1.utils.WalletConnectClientV1Utils
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.mapper.WalletConnectNamespaceMapper
import com.algorand.android.utils.walletconnect.DEFAULT_CHAIN_ID
import javax.inject.Inject

class CreateWalletConnectSessionNamespaceUseCase @Inject constructor(
    private val namespaceMapper: WalletConnectNamespaceMapper
) {

    operator fun invoke(accountAddresses: List<String>): Map<String, WalletConnect.Namespace.Session> {
        val sessionNamespace = namespaceMapper.mapToSessionNamespace(
            accountList = accountAddresses,
            methodList = WalletConnectClientV1Utils.getDefaultSessionMethods(),
            eventList = WalletConnectClientV1Utils.getDefaultSessionEvents(),
            versionIdentifier = WalletConnectClientV1Utils.getWalletConnectV1VersionIdentifier()
        )
        return mapOf(DEFAULT_CHAIN_ID_FOR_NAMESPACES to sessionNamespace)
    }

    companion object {
        private const val DEFAULT_CHAIN_ID_FOR_NAMESPACES = DEFAULT_CHAIN_ID.toString()
    }
}
