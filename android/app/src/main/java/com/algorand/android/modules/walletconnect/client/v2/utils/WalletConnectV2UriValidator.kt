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

package com.algorand.android.modules.walletconnect.client.v2.utils

import com.walletconnect.android.internal.common.model.RelayProtocolOptions
import com.walletconnect.android.internal.common.model.SymmetricKey
import com.walletconnect.android.internal.common.model.WalletConnectUri
import com.walletconnect.foundation.common.model.Topic
import java.net.URI
import java.net.URISyntaxException

/**
 * This class was created based on WC v2 SDK
 * For original content, please check; com.walletconnect.android.internal -> Validator.validateWCUri
 */
@Suppress("ReturnCount")
object WalletConnectV2UriValidator {

    private const val WALLET_CONNECT_URI_PREFIX = "wc:"

    fun isValidWCUri(uri: String): Boolean {
        return createWalletConnectUri(uri) != null
    }

    fun createWalletConnectUri(uri: String): WalletConnectUri? {
        if (!uri.startsWith(WALLET_CONNECT_URI_PREFIX)) return null

        val properUriString = when {
            uri.contains("$WALLET_CONNECT_URI_PREFIX//") -> uri
            uri.contains("$WALLET_CONNECT_URI_PREFIX/") -> {
                uri.replace("$WALLET_CONNECT_URI_PREFIX/", "$WALLET_CONNECT_URI_PREFIX//")
            }

            else -> uri.replace(WALLET_CONNECT_URI_PREFIX, "$WALLET_CONNECT_URI_PREFIX//")
        }

        val pairUri: URI = try {
            URI(properUriString)
        } catch (e: URISyntaxException) {
            return null
        }

        if (pairUri.userInfo.isEmpty()) return null
        val mapOfQueryParameters: Map<String, String> =
            pairUri.query.split("&").associate { query -> query.substringBefore("=") to query.substringAfter("=") }

        var relayProtocol = ""
        mapOfQueryParameters["relay-protocol"]?.let { relayProtocol = it } ?: return null
        if (relayProtocol.isEmpty()) return null

        val relayData: String? = mapOfQueryParameters["relay-data"]

        var symKey = ""
        mapOfQueryParameters["symKey"]?.let { symKey = it } ?: return null
        if (symKey.isEmpty()) return null

        return WalletConnectUri(
            topic = Topic(pairUri.userInfo),
            relay = RelayProtocolOptions(protocol = relayProtocol, data = relayData),
            symKey = SymmetricKey(symKey),
            expiry = null,
            methods = null
        )
    }
}
