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

package com.algorand.android.modules.walletconnect.client.v2.domain.decider

import com.algorand.android.modules.walletconnect.client.v2.domain.model.WalletConnectV2ChainIdentifier
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import javax.inject.Inject

class WalletConnectV2ChainIdentifierDecider @Inject constructor() {

    fun decideChainIdentifier(chainId: String?): WalletConnect.ChainIdentifier {
        if (chainId == null) return WalletConnect.ChainIdentifier.UNKNOWN
        return when (chainId) {
            WalletConnectV2ChainIdentifier.MAINNET.id -> WalletConnect.ChainIdentifier.MAINNET
            WalletConnectV2ChainIdentifier.TESTNET.id -> WalletConnect.ChainIdentifier.TESTNET
            else -> WalletConnect.ChainIdentifier.UNKNOWN
        }
    }

    fun decideChainId(chainIdentifier: WalletConnect.ChainIdentifier): String {
        return when (chainIdentifier) {
            WalletConnect.ChainIdentifier.MAINNET -> WalletConnectV2ChainIdentifier.MAINNET.id
            WalletConnect.ChainIdentifier.TESTNET -> WalletConnectV2ChainIdentifier.TESTNET.id
            WalletConnect.ChainIdentifier.UNKNOWN -> WalletConnectV2ChainIdentifier.MAINNET.id
        }
    }
}
