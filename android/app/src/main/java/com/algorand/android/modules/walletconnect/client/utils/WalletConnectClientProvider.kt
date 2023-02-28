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

package com.algorand.android.modules.walletconnect.client.utils

import com.algorand.android.modules.walletconnect.client.v1.WalletConnectClientV1Impl
import com.algorand.android.modules.walletconnect.client.v2.WalletConnectClientV2Impl
import com.algorand.android.modules.walletconnect.domain.WalletConnectClient
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectVersionIdentifier
import javax.inject.Inject
import javax.inject.Named

class WalletConnectClientProvider @Inject constructor(
    @Named(WalletConnectClientV1Impl.INJECTION_NAME)
    private val walletConnectV1Client: WalletConnectClient,
    @Named(WalletConnectClientV2Impl.INJECTION_NAME)
    private val walletConnectV2Client: WalletConnectClient,
) {

    fun provideClient(versionIdentifier: WalletConnectVersionIdentifier): WalletConnectClient {
        return when (versionIdentifier) {
            WalletConnectVersionIdentifier.VERSION_1 -> walletConnectV1Client
            WalletConnectVersionIdentifier.VERSION_2 -> walletConnectV2Client
        }
    }

    fun getClients(): List<WalletConnectClient> {
        return listOf(walletConnectV1Client, walletConnectV2Client)
    }

    fun getClientForSessionConnectionUrl(url: String): WalletConnectClient? {
        return when {
            walletConnectV1Client.isValidSessionUrl(url) -> walletConnectV1Client
            walletConnectV2Client.isValidSessionUrl(url) -> walletConnectV2Client
            else -> null
        }
    }
}
