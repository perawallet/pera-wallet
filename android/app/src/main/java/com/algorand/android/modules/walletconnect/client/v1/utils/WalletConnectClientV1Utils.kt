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

package com.algorand.android.modules.walletconnect.client.v1.utils

import com.algorand.android.modules.walletconnect.domain.model.WalletConnectEvent
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectMethod
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectVersionIdentifier
import com.algorand.android.utils.walletconnect.WALLET_CONNECT_URL_PREFIX
import org.walletconnect.Session

object WalletConnectClientV1Utils {

    fun getDefaultSessionEvents(): List<WalletConnectEvent> = listOf()

    fun getDefaultSessionMethods(): List<WalletConnectMethod> = listOf()

    fun getWalletConnectV1VersionIdentifier() = WalletConnectVersionIdentifier.VERSION_1

    fun isValidWalletConnectUrl(url: String): Boolean {
        return url.startsWith(WALLET_CONNECT_URL_PREFIX) && createSessionConfigFromUrl(url) != null
    }

    private fun createSessionConfigFromUrl(url: String): Session.Config? {
        return try {
            Session.Config.fromWCUri(url)
        } catch (exception: Exception) {
            null
        }
    }
}
