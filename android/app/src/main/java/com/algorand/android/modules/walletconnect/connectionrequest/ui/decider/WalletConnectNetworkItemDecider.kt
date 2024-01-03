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

package com.algorand.android.modules.walletconnect.connectionrequest.ui.decider

import com.algorand.android.R
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import javax.inject.Inject

class WalletConnectNetworkItemDecider @Inject constructor() {

    // TODO: We have the same thing in somewhere else
    // https://github.com/Hipo/algorand-android/pull/2032#discussion_r1146072510
    fun decideTintResId(chainIdentifier: WalletConnect.ChainIdentifier): Int {
        return when (chainIdentifier) {
            WalletConnect.ChainIdentifier.MAINNET -> R.color.positive
            WalletConnect.ChainIdentifier.TESTNET -> R.color.yellow_600
            WalletConnect.ChainIdentifier.UNKNOWN -> R.color.yellow_600
        }
    }

    fun decideNetworkName(chainIdentifier: WalletConnect.ChainIdentifier): String {
        return chainIdentifier.name
    }
}
