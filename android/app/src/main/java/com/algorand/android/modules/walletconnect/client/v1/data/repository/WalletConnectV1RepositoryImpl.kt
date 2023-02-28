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

package com.algorand.android.modules.walletconnect.client.v1.data.repository

import com.algorand.android.database.WalletConnectDao
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto.WalletConnectSessionAccountDTOMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto.WalletConnectSessionByAccountsAddressDTOMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto.WalletConnectSessionDTOMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto.WalletConnectSessionWithAccountsAddressesDTOMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.entity.WalletConnectSessionAccountEntityMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.entity.WalletConnectSessionEntityMapper
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionAccountDTO
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionByAccountsAddressDTO
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionDTO
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionWithAccountsAddressesDTO
import com.algorand.android.modules.walletconnect.client.v1.domain.repository.WalletConnectRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class WalletConnectV1RepositoryImpl constructor(
    private val walletConnectDao: WalletConnectDao,
    private val sessionAccountDTOMapper: WalletConnectSessionAccountDTOMapper,
    private val sessionAccountEntityMapper: WalletConnectSessionAccountEntityMapper,
    private val sessionDTOMapper: WalletConnectSessionDTOMapper,
    private val sessionEntityMapper: WalletConnectSessionEntityMapper,
    private val sessionByAccountsAddressDTOMapper: WalletConnectSessionByAccountsAddressDTOMapper,
    private val sessionWithAccountsAddressesDTOMapper: WalletConnectSessionWithAccountsAddressesDTOMapper
) : WalletConnectRepository {

    override suspend fun getAllDisconnectedSessions(): List<WalletConnectSessionDTO> {
        return walletConnectDao.getAllDisconnectedWCSessions().map {
            sessionDTOMapper.mapToSessionDTO(it)
        }
    }

    override suspend fun getSessionById(sessionId: Long): WalletConnectSessionDTO? {
        val sessionEntity = walletConnectDao.getSessionById(sessionId) ?: return null
        return sessionDTOMapper.mapToSessionDTO(sessionEntity)
    }

    override suspend fun deleteSessionById(sessionId: Long) {
        walletConnectDao.deleteById(sessionId)
    }

    override suspend fun setAllSessionsDisconnected() {
        walletConnectDao.setAllSessionsDisconnected()
    }

    override suspend fun setSessionDisconnected(sessionId: Long) {
        walletConnectDao.setSessionDisconnected(sessionId)
    }

    override suspend fun insertConnectedWalletConnectSession(
        wcSession: WalletConnectSessionDTO,
        wcSessionAccountList: List<WalletConnectSessionAccountDTO>
    ) {
        walletConnectDao.insertWalletConnectSessionAndHistory(
            wcSessionEntity = sessionEntityMapper.mapToSessionEntity(wcSession),
            wcSessionAccountList = wcSessionAccountList.map { sessionAccountEntityMapper.mapToSessionAccountEntity(it) }
        )
    }

    override suspend fun setConnectedSession(sessionId: Long) {
        walletConnectDao.setSessionConnected(sessionId)
    }

    override suspend fun getWCSessionList(): List<WalletConnectSessionDTO> {
        return walletConnectDao.getWCSessionList().map { sessionDTOMapper.mapToSessionDTO(it) }
    }

    override suspend fun getWCSessionListByAccountAddress(
        accountAddress: String
    ): List<WalletConnectSessionByAccountsAddressDTO>? {
        return walletConnectDao.getWCSessionListByAccountAddress(accountAddress)?.map {
            sessionByAccountsAddressDTOMapper.mapToSessionByAccountsAddressDTO(it)
        }
    }

    override suspend fun getConnectedAccountsOfSession(
        sessionId: Long
    ): List<WalletConnectSessionAccountDTO>? {
        return walletConnectDao.getConnectedAccountsOfSession(sessionId)?.map {
            sessionAccountDTOMapper.mapToSessionAccountDTO(it)
        }
    }

    override fun getAllWalletConnectSessionWithAccountAddresses():
        Flow<List<WalletConnectSessionWithAccountsAddressesDTO>?> {
        return walletConnectDao.getAllWalletConnectSessionWithAccountAddresses().map { sessionWithAccAddrList ->
            sessionWithAccAddrList?.map { sessionWithAccAddr ->
                sessionWithAccountsAddressesDTOMapper.mapToSessionWithAccountsAddressesDTO(sessionWithAccAddr)
            }
        }
    }

    override suspend fun deleteWalletConnectAccountBySession(sessionId: Long, accountAddress: String) {
        return walletConnectDao.deleteWalletConnectAccountBySession(sessionId, accountAddress)
    }

    override suspend fun setGivenSessionAsSubscribed(sessionId: Long) {
        walletConnectDao.setGivenSessionAsSubscribed(sessionId)
    }

    override suspend fun getWalletConnectSessionListOrderedByCreationTime(count: Int): List<WalletConnectSessionDTO> {
        return walletConnectDao.getWalletConnectSessionListOrderedByCreationTime(count)?.map { sessionEntity ->
            sessionDTOMapper.mapToSessionDTO(sessionEntity)
        }.orEmpty()
    }

    override suspend fun getWalletConnectSessionCount(): Int {
        return walletConnectDao.getWalletConnectSessionCount()
    }
}
