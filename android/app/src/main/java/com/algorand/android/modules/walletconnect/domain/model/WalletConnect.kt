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
        BETANET,
        UNKNOWN
    }

    open class PeerMeta(
        val name: String,
        val url: String,
        val description: String?,
        val icons: List<String>?,
        val redirectUrl: String?
    )

    data class SessionDetail(
        val sessionIdentifier: SessionIdentifier,
        val topic: String,
        val peerMeta: PeerMeta,
        val sessionMeta: Session.Meta,
        val namespaces: Map<String, Namespace.Session>,
        val creationDateTimestamp: Long,
        val isSubscribed: Boolean,
        val fallbackBrowserGroupResponse: String?,
        val isConnected: Boolean,
        val expiry: Model.Expiry?, // TODO Make this non-nullable after removing WC v1
        override val versionIdentifier: WalletConnectVersionIdentifier
    ) : WalletConnect {
        val chainId: String?
            get() = namespaces.keys.firstOrNull()

        val connectedAddresses: List<String>
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
                val chainIdentifier: ChainIdentifier,
                val accountList: List<String>,
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
                val errorMessage: String,
                override val versionIdentifier: WalletConnectVersionIdentifier
            ) : Settle()
        }

        /**
        Required Namespaces example;
        eip155 to Proposal(
        chains=[
        eip155: 1
        ],
        methods=[
        eth_sendTransaction,
        personal_sign,
        eth_sign,
        eth_signTypedData
        ],
        events=[
        chainChanged,
        accountChanged
        ],
        extensions=null
        )
        }
         */
        data class Proposal(
            val proposalIdentifier: ProposalIdentifier,
            val relayProtocol: String?,
            val relayData: String?,
            val peerMeta: PeerMeta,
            val namespaces: Namespace.Proposal,
            val requiredNamespaces: Map<String, Namespace.Proposal>,
            val chainIdentifier: ChainIdentifier,
            val fallbackBrowserGroupResponse: String?,
            override val versionIdentifier: WalletConnectVersionIdentifier
        ) : Session()

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
        }

        interface ProposalIdentifier : WalletConnect {
            fun getIdentifier(): String
        }
    }

    sealed class Namespace : WalletConnect {

        data class Proposal(
            val chains: List<ChainIdentifier>,
            val methods: List<String>,
            val events: List<String>,
            override val versionIdentifier: WalletConnectVersionIdentifier
        ) : Namespace()

        data class Session(
            val accounts: List<String>,
            val methods: List<String>,
            val events: List<String>,
            override val versionIdentifier: WalletConnectVersionIdentifier
        ) : Namespace()
    }

    sealed class Model : WalletConnect {

        data class Session(
            val topic: String,
            val expiry: Expiry,
            val namespaces: Map<String, Namespace.Session>,
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
