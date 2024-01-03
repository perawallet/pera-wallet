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

package com.algorand.android.modules.walletconnect.domain.model

import android.net.Uri
import androidx.core.net.toUri
import com.algorand.android.utils.firstOrNull

interface WalletConnect {

    val versionIdentifier: WalletConnectVersionIdentifier

    interface SessionIdentifier : WalletConnect {
        fun getIdentifier(): String
    }

    interface RequestIdentifier : WalletConnect {
        fun getIdentifier(): Long
    }

    enum class ChainIdentifier {
        MAINNET,
        TESTNET,
        UNKNOWN
    }

    open class PeerMeta(
        val name: String,
        val url: String,
        val description: String?,
        val icons: List<String>?,
        val redirectUrl: String?
    ) {
        override fun equals(other: Any?): Boolean {
            if (other !is PeerMeta) return false
            if (name != other.name) return false
            if (url != other.url) return false
            if (description != other.description) return false
            if (icons != other.icons) return false
            if (redirectUrl != other.redirectUrl) return false
            return true
        }

        @Suppress("MagicNumber")
        override fun hashCode(): Int {
            var result = name.hashCode()
            result = 31 * result + url.hashCode()
            result = 31 * result + (description?.hashCode() ?: 0)
            result = 31 * result + (icons?.hashCode() ?: 0)
            result = 31 * result + (redirectUrl?.hashCode() ?: 0)
            return result
        }
    }

    data class SessionDetail(
        val sessionIdentifier: SessionIdentifier,
        val topic: String,
        val peerMeta: PeerMeta,
        val sessionMeta: Session.Meta,
        val namespaces: Map<WalletConnectBlockchain, Namespace.Session>,
        val creationDateTimestamp: Long,
        val fallbackBrowserGroupResponse: String?,
        val isConnected: Boolean,
        val expiry: Model.Expiry?, // TODO Make this non-nullable after removing WC v1
        override val versionIdentifier: WalletConnectVersionIdentifier
    ) : WalletConnect {
        val connectedAccounts: List<WalletConnectConnectedAccount>
            get() = namespaces.firstOrNull()?.accounts.orEmpty()

        val peerIconUri: Uri?
            get() = peerMeta.icons?.firstOrNull()?.toUri()
    }

    sealed class Session : WalletConnect {

        sealed class Delete : Session() {
            data class Success(
                val sessionIdentifier: SessionIdentifier,
                val reason: String,
                override val versionIdentifier: WalletConnectVersionIdentifier
            ) : Delete()

            data class Error(
                val error: Throwable,
                override val versionIdentifier: WalletConnectVersionIdentifier
            ) : Delete()
        }

        sealed class Update : Session() {

            data class Success(
                val sessionIdentifier: SessionIdentifier,
                override val versionIdentifier: WalletConnectVersionIdentifier
            ) : Update()

            data class Error(
                val message: String?,
                override val versionIdentifier: WalletConnectVersionIdentifier
            ) : Update()
        }

        sealed class Settle : WalletConnect {
            data class Result(
                val session: SessionDetail,
                val clientId: String,
                override val versionIdentifier: WalletConnectVersionIdentifier
            ) : Settle()

            data class Error(
                val errorMessage: String?,
                val throwable: Throwable?,
                val sessionIdentifier: SessionIdentifier?,
                override val versionIdentifier: WalletConnectVersionIdentifier
            ) : Settle()
        }

        data class Proposal(
            val proposalIdentifier: ProposalIdentifier,
            val relayProtocol: String?,
            val relayData: String?,
            val peerMeta: PeerMeta,
            val requiredNamespaces: Map<WalletConnectBlockchain, Namespace.Proposal>,
            val fallbackBrowserGroupResponse: String?,
            override val versionIdentifier: WalletConnectVersionIdentifier
        ) : Session() {

            val chainId: ChainIdentifier?
                get() = requiredNamespaces.firstOrNull()?.chains?.firstOrNull()
        }

        data class Error(
            val sessionIdentifier: SessionIdentifier,
            val throwable: Throwable,
            override val versionIdentifier: WalletConnectVersionIdentifier
        ) : Session()

        sealed class Meta {

            data class Version1(
                val bridge: String,
                val key: String,
                val topic: String,
                val version: String
            ) : Meta()

            data class Version2(
                val topic: String
            ) : Meta()
        }

        interface ProposalIdentifier : WalletConnect {
            fun getIdentifier(): String
        }
    }

    sealed class Namespace : WalletConnect {

        data class Proposal(
            val chains: List<ChainIdentifier>,
            val methods: List<WalletConnectMethod>,
            val events: List<WalletConnectEvent>,
            override val versionIdentifier: WalletConnectVersionIdentifier
        ) : Namespace()

        data class Session(
            val accounts: List<WalletConnectConnectedAccount>,
            val methods: List<WalletConnectMethod>,
            val events: List<WalletConnectEvent>,
            val chains: List<ChainIdentifier>,
            override val versionIdentifier: WalletConnectVersionIdentifier
        ) : Namespace()
    }

    sealed class Model : WalletConnect {

        data class Session(
            val topic: String,
            val expiry: Expiry,
            val namespaces: Map<WalletConnectBlockchain, Namespace.Session>,
            val metaData: PeerMeta?,
            override val versionIdentifier: WalletConnectVersionIdentifier
        ) : WalletConnect

        data class SessionRequest(
            val sessionIdentifier: SessionIdentifier,
            val chainIdentifier: ChainIdentifier?,
            val peerMetaData: PeerMeta?,
            val request: JSONRPCRequest,
            override val versionIdentifier: WalletConnectVersionIdentifier
        ) : Model() {

            data class JSONRPCRequest(
                val requestIdentifier: RequestIdentifier,
                val method: String,
                val params: List<*>?,
                override val versionIdentifier: WalletConnectVersionIdentifier
            ) : Model()
        }

        data class Error(
            val throwable: Throwable,
            val message: String?,
            override val versionIdentifier: WalletConnectVersionIdentifier
        ) : Model()

        data class ConnectionState(
            val session: SessionDetail,
            val isConnected: Boolean,
            val clientId: String?,
            override val versionIdentifier: WalletConnectVersionIdentifier
        ) : Model()

        data class Expiry(val seconds: Long)
    }
}
