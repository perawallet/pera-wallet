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

import com.algorand.android.models.WalletConnectSession
import com.algorand.android.models.WalletConnectSessionMeta
import com.algorand.android.models.WalletConnectTransactionErrorResponse

const val ALGO_CHAIN_ID = 4160L

interface WalletConnectClient {

    fun connect(uri: String)
    fun connect(sessionId: Long, sessionMeta: WalletConnectSessionMeta)

    fun setListener(listener: WalletConnectClientListener)

    fun approveSession(id: Long, accountAddress: String)
    fun rejectSession(id: Long)

    fun disconnectFromSession(id: Long)
    fun killSession(id: Long)

    fun rejectRequest(sessionId: Long, requestId: Long, errorResponse: WalletConnectTransactionErrorResponse)
    fun approveRequest(sessionId: Long, requestId: Long, payload: Any)

    fun getWalletConnectSession(sessionId: Long): WalletConnectSession?
}
