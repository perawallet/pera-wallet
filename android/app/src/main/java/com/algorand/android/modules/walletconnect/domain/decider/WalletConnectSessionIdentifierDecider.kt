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

import com.algorand.android.modules.walletconnect.client.v1.mapper.WalletConnectV1SessionIdentifierMapper
import com.algorand.android.modules.walletconnect.client.v2.mapper.WalletConnectV2SessionIdentifierMapper
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectVersionIdentifier
import javax.inject.Inject

class WalletConnectSessionIdentifierDecider @Inject constructor(
    private val walletConnectV1SessionIdentifierMapper: WalletConnectV1SessionIdentifierMapper,
    private val walletConnectV2SessionIdentifierMapper: WalletConnectV2SessionIdentifierMapper
) {

    fun decideSessionIdentifier(
        sessionId: String,
        versionIdentifier: WalletConnectVersionIdentifier
    ): WalletConnect.SessionIdentifier {
        return when (versionIdentifier) {
            WalletConnectVersionIdentifier.VERSION_1 -> {
                walletConnectV1SessionIdentifierMapper.mapToSessionIdentifier(sessionId.toLong())
            }
            WalletConnectVersionIdentifier.VERSION_2 -> {
                walletConnectV2SessionIdentifierMapper.mapToSessionIdentifier(sessionId)
            }
        }
    }
}
