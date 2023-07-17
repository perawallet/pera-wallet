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

package com.algorand.android.utils.walletconnect

import androidx.core.os.bundleOf
import com.algorand.android.models.WalletConnectTransaction
import com.algorand.android.modules.walletconnect.domain.model.WalletConnect
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionProposal
import com.algorand.android.network.AlgodInterceptor
import com.algorand.android.utils.MAINNET_NETWORK_SLUG
import com.google.firebase.analytics.FirebaseAnalytics

/**
 * This class will be provided by hilt - AppModule.kt
 */
class WalletConnectFirebaseEventLogger(
    private val firebaseAnalytics: FirebaseAnalytics,
    private val algodInterceptor: AlgodInterceptor
) : WalletConnectEventLogger {

    private val isCurrentNetworkMainNet: Boolean
        get() = algodInterceptor.currentActiveNode?.networkSlug == MAINNET_NETWORK_SLUG

    override fun logTransactionRequestConfirmation(transaction: WalletConnectTransaction) {
        if (!isCurrentNetworkMainNet) return
        val bundle = with(transaction) {
            bundleOf(
                TRANSACTION_ID_PARAM to getTransactionIds(),
                DAPP_NAME_PARAM to session.peerMeta.name,
                DAPP_URL_PARAM to session.peerMeta.url
            )
        }
        firebaseAnalytics.logEvent(REQUEST_CONFIRMATION_EVENT_KEY, bundle)
    }

    override fun logTransactionRequestRejection(transaction: WalletConnectTransaction) {
        if (!isCurrentNetworkMainNet) return
        val bundle = with(transaction) {
            bundleOf(
                DAPP_NAME_PARAM to session.peerMeta.name,
                DAPP_URL_PARAM to session.peerMeta.url,
                CONNECTED_ACCOUNT_ADDRESS_PARAM to session.connectedAccountsAddresses.toAccountAddressesString(),
                TRANSACTION_COUNT_PARAM to getTransactionCount()
            )
        }
        firebaseAnalytics.logEvent(REQUEST_REJECTION_EVENT_KEY, bundle)
    }

    override fun logSessionConfirmation(
        sessionProposal: WalletConnectSessionProposal,
        connectedAccountAddresses: List<String>
    ) {
        if (!isCurrentNetworkMainNet) return
        val bundle = with(sessionProposal) {
            bundleOf(
                DAPP_NAME_PARAM to peerMeta.name,
                DAPP_URL_PARAM to peerMeta.url,
                SESSION_TOPIC_PARAM to sessionProposal.proposalIdentifier.proposalIdentifier,
                CONNECTED_ACCOUNT_ADDRESS_PARAM to connectedAccountAddresses.toAccountAddressesString(),
                TOTAL_ACCOUNT_ACCOUNT_PARAM to connectedAccountAddresses.count()
            )
        }
        firebaseAnalytics.logEvent(SESSION_CONFIRMATION_EVENT_KEY, bundle)
    }

    override fun logSessionDisconnection(session: WalletConnect.SessionDetail) {
        if (!isCurrentNetworkMainNet) return
        val bundle = with(session) {
            bundleOf(
                DAPP_NAME_PARAM to peerMeta.name,
                DAPP_URL_PARAM to peerMeta.url,
                CONNECTED_ACCOUNT_ADDRESS_PARAM to connectedAccounts.map {
                    it.accountAddress
                }.toAccountAddressesString()
            )
        }
        firebaseAnalytics.logEvent(SESSION_DISCONNECTION_EVENT_KEY, bundle)
    }

    override fun logSessionRejection(sessionProposal: WalletConnectSessionProposal) {
        if (!isCurrentNetworkMainNet) return
        val bundle = bundleOf(
            DAPP_NAME_PARAM to sessionProposal.peerMeta.name,
            DAPP_URL_PARAM to sessionProposal.peerMeta.url,
            SESSION_TOPIC_PARAM to sessionProposal.proposalIdentifier.proposalIdentifier
        )
        firebaseAnalytics.logEvent(SESSION_REJECTION_EVENT_KEY, bundle)
    }

    /**
     * Takes account address list and returns Firebase Crashlytics compatible string for array queries
     * @param [accountaddress1, accountaddress2, accountaddress3]
     * @return accountaddress1, accountaddress2, accountaddress3
     */
    private fun List<String>.toAccountAddressesString(): String {
        return joinToString(",")
    }

    companion object {
        /**
         * Firebase Event Keys
         */
        private const val REQUEST_CONFIRMATION_EVENT_KEY = "wc_transaction_confirmed"
        private const val REQUEST_REJECTION_EVENT_KEY = "wc_transaction_declined"
        private const val SESSION_CONFIRMATION_EVENT_KEY = "wc_session_approved"
        private const val SESSION_REJECTION_EVENT_KEY = "wc_session_rejected"
        private const val SESSION_DISCONNECTION_EVENT_KEY = "wc_session_disconnected"

        /**
         * Firebase Event Params
         */
        private const val TRANSACTION_ID_PARAM = "tx_id"
        private const val DAPP_NAME_PARAM = "dapp_name"
        private const val DAPP_URL_PARAM = "dapp_url"
        private const val CONNECTED_ACCOUNT_ADDRESS_PARAM = "address"
        private const val TRANSACTION_COUNT_PARAM = "transaction_count"
        private const val SESSION_TOPIC_PARAM = "topic"
        private const val TOTAL_ACCOUNT_ACCOUNT_PARAM = "total_account"
    }
}
