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

package com.algorand.android.modules.walletconnect.client.v1.domain.repository

import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionAccountDto
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionByAccountsAddressDto
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionDto
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionWithAccountsAddressesDto
import kotlinx.coroutines.flow.Flow

interface WalletConnectRepository {

    suspend fun getAllDisconnectedSessions(): List<WalletConnectSessionDto>

    suspend fun getSessionById(sessionId: Long): WalletConnectSessionDto?

    suspend fun deleteSessionById(sessionId: Long)

    suspend fun setAllSessionsDisconnected()

    suspend fun setSessionDisconnected(sessionId: Long)

    suspend fun insertConnectedWalletConnectSession(
        wcSession: WalletConnectSessionDto,
        wcSessionAccountList: List<WalletConnectSessionAccountDto>
    )

    suspend fun setConnectedSession(sessionId: Long)

    suspend fun getWCSessionList(): List<WalletConnectSessionDto>

    suspend fun getWCSessionListByAccountAddress(
        accountAddress: String
    ): List<WalletConnectSessionByAccountsAddressDto>?

    suspend fun getConnectedAccountsOfSession(sessionId: Long): List<WalletConnectSessionAccountDto>?

    fun getAllWalletConnectSessionWithAccountAddresses(): Flow<List<WalletConnectSessionWithAccountsAddressesDto>?>

    suspend fun deleteWalletConnectAccountBySession(sessionId: Long, accountAddress: String)

    suspend fun getWalletConnectSessionListOrderedByCreationTime(count: Int): List<WalletConnectSessionDto>

    suspend fun getWalletConnectSessionCount(): Int

    suspend fun isSessionRequestIdExist(requestId: Long): Boolean

    suspend fun isTransactionRequestIdExist(requestId: Long): Boolean

    suspend fun setSessionRequestId(requestId: Long, timestampAsSec: Long)

    suspend fun setTransactionRequestId(requestId: Long, timestampAsSec: Long)

    companion object {
        const val INJECTION_NAME = "walletConnectV1RepositoryInjectionName"
    }
}
