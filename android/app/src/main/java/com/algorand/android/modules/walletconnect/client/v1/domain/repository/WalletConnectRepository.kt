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

import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionAccountDTO
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionByAccountsAddressDTO
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionDTO
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionWithAccountsAddressesDTO
import kotlinx.coroutines.flow.Flow

interface WalletConnectRepository {

    suspend fun getAllDisconnectedSessions(): List<WalletConnectSessionDTO>

    suspend fun getSessionById(sessionId: Long): WalletConnectSessionDTO?

    suspend fun deleteSessionById(sessionId: Long)

    suspend fun setAllSessionsDisconnected()

    suspend fun setSessionDisconnected(sessionId: Long)

    suspend fun insertConnectedWalletConnectSession(
        wcSession: WalletConnectSessionDTO,
        wcSessionAccountList: List<WalletConnectSessionAccountDTO>
    )

    suspend fun setConnectedSession(sessionId: Long)

    suspend fun getWCSessionList(): List<WalletConnectSessionDTO>

    suspend fun getWCSessionListByAccountAddress(
        accountAddress: String
    ): List<WalletConnectSessionByAccountsAddressDTO>?

    suspend fun getConnectedAccountsOfSession(sessionId: Long): List<WalletConnectSessionAccountDTO>?

    fun getAllWalletConnectSessionWithAccountAddresses(): Flow<List<WalletConnectSessionWithAccountsAddressesDTO>?>

    suspend fun deleteWalletConnectAccountBySession(sessionId: Long, accountAddress: String)

    suspend fun setGivenSessionAsSubscribed(sessionId: Long)

    suspend fun getWalletConnectSessionListOrderedByCreationTime(count: Int): List<WalletConnectSessionDTO>

    suspend fun getWalletConnectSessionCount(): Int

    companion object {
        const val INJECTION_NAME = "walletConnectV1RepositoryInjectionName"
    }
}
