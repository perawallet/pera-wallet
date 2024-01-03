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

package com.algorand.android.modules.walletconnect.client.v1.domain.decider

import com.algorand.android.modules.walletconnect.client.v1.model.WalletConnectV1ChainIdentifier
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import javax.inject.Inject

class WalletConnectV1ChainIdentifierDecider @Inject constructor() {

    fun decideChainIdentifier(chainId: Long?): WalletConnect.ChainIdentifier {
        if (chainId == null) return WalletConnect.ChainIdentifier.UNKNOWN
        return when (chainId) {
            WalletConnectV1ChainIdentifier.MAINNET.id -> WalletConnect.ChainIdentifier.MAINNET
            WalletConnectV1ChainIdentifier.TESTNET.id -> WalletConnect.ChainIdentifier.TESTNET
            WalletConnectV1ChainIdentifier.MAINNET_BACKWARD_SUPPORTABILITY.id -> WalletConnect.ChainIdentifier.MAINNET
            else -> WalletConnect.ChainIdentifier.UNKNOWN
        }
    }

    fun decideChainId(chainIdentifier: WalletConnect.ChainIdentifier): Long {
        return when (chainIdentifier) {
            WalletConnect.ChainIdentifier.MAINNET -> WalletConnectV1ChainIdentifier.MAINNET.id
            WalletConnect.ChainIdentifier.TESTNET -> WalletConnectV1ChainIdentifier.TESTNET.id
            WalletConnect.ChainIdentifier.UNKNOWN -> WalletConnectV1ChainIdentifier.MAINNET.id
        }
    }
}
