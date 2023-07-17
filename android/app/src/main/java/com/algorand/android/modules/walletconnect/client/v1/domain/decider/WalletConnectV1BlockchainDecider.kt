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
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectBlockchain
import javax.inject.Inject

class WalletConnectV1BlockchainDecider @Inject constructor() {

    fun decideBlockchain(chainId: Long?): WalletConnectBlockchain {
        if (chainId == null) return WalletConnectBlockchain.UNKNOWN
        return when (chainId) {
            WalletConnectV1ChainIdentifier.MAINNET.id,
            WalletConnectV1ChainIdentifier.TESTNET.id,
            WalletConnectV1ChainIdentifier.BETANET.id,
            WalletConnectV1ChainIdentifier.MAINNET_BACKWARD_SUPPORTABILITY.id -> WalletConnectBlockchain.ALGORAND
            else -> WalletConnectBlockchain.UNKNOWN
        }
    }
}
