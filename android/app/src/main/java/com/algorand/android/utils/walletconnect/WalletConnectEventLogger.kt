/*
 * Copyright 2019 Algorand, Inc.
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

import com.algorand.android.models.WalletConnectSession
import com.algorand.android.models.WalletConnectTransaction

interface WalletConnectEventLogger {

    /**
     * After the transaction is confirmed, for all signed transactions
     *
     * KEY wc_transaction_confirmed
     *
     * PARAMS tx_id, dapp_name, dapp_url
     */
    fun logTransactionRequestConfirmation(transaction: WalletConnectTransaction)

    /**
     * After the transaction is declined
     *
     * KEY wc_transaction_declined
     *
     * PARAMS dapp_name, dapp_url, address, transaction_count
     */
    fun logTransactionRequestRejection(transaction: WalletConnectTransaction)

    /**
     * After the user approves the session
     *
     * KEY wc_session_approved
     *
     * PARAMS dapp_name, dapp_url, topic, address
     */
    fun logSessionConfirmation(session: WalletConnectSession, connectedAccountPublicKey: String)

    /**
     * After the user rejects the session
     *
     * KEY wc_session_rejected
     *
     * PARAMS dapp_name, dapp_url, topic
     */
    fun logSessionRejection(session: WalletConnectSession)

    /**
     * After the user taps to disconnect
     *
     * KEY wc_session_disconnected
     *
     * PARAMS dapp_name, dapp_url, address
     */
    fun logSessionDisconnection(session: WalletConnectSession)
}
