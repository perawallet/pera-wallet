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

package com.algorand.android.modules.walletconnect.domain.decider

import com.algorand.android.models.Node
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.utils.MAINNET_NETWORK_SLUG
import com.algorand.android.utils.TESTNET_NETWORK_SLUG
import javax.inject.Inject

class WalletConnectNodeChainIdentifierDecider @Inject constructor() {

    fun decideNodeChainIdentifier(node: Node): WalletConnect.ChainIdentifier {
        return when (node.networkSlug) {
            MAINNET_NETWORK_SLUG -> WalletConnect.ChainIdentifier.MAINNET
            TESTNET_NETWORK_SLUG -> WalletConnect.ChainIdentifier.TESTNET
            else -> WalletConnect.ChainIdentifier.UNKNOWN
        }
    }
}
