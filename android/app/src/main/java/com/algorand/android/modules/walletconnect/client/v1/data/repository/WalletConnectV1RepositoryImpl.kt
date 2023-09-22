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
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto.WalletConnectSessionAccountDtoMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto.WalletConnectSessionByAccountsAddressDtoMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto.WalletConnectSessionDtoMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.dto.WalletConnectSessionWithAccountsAddressesDtoMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.entity.WalletConnectSessionAccountEntityMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.entity.WalletConnectSessionEntityMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.entity.WalletConnectV1SessionRequestIdEntityMapper
import com.algorand.android.modules.walletconnect.client.v1.data.mapper.entity.WalletConnectV1TransactionRequestIdEntityMapper
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionAccountDto
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionByAccountsAddressDto
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionDto
import com.algorand.android.modules.walletconnect.client.v1.domain.model.WalletConnectSessionWithAccountsAddressesDto
import com.algorand.android.modules.walletconnect.client.v1.domain.repository.WalletConnectRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class WalletConnectV1RepositoryImpl constructor(
    private val walletConnectDao: WalletConnectDao,
    private val sessionAccountDtoMapper: WalletConnectSessionAccountDtoMapper,
    private val sessionAccountEntityMapper: WalletConnectSessionAccountEntityMapper,
    private val sessionDtoMapper: WalletConnectSessionDtoMapper,
    private val sessionEntityMapper: WalletConnectSessionEntityMapper,
    private val sessionByAccountsAddressDtoMapper: WalletConnectSessionByAccountsAddressDtoMapper,
    private val sessionWithAccountsAddressesDtoMapper: WalletConnectSessionWithAccountsAddressesDtoMapper,
    private val sessionRequestIdEntityMapper: WalletConnectV1SessionRequestIdEntityMapper,
    private val transactionRequestIdEntityMapper: WalletConnectV1TransactionRequestIdEntityMapper
) : WalletConnectRepository {

    override suspend fun getAllDisconnectedSessions(): List<WalletConnectSessionDto> {
        return walletConnectDao.getAllDisconnectedWCSessions().map {
            sessionDtoMapper.mapToSessionDto(it)
        }
    }

    override suspend fun getSessionById(sessionId: Long): WalletConnectSessionDto? {
        val sessionEntity = walletConnectDao.getSessionById(sessionId) ?: return null
        return sessionDtoMapper.mapToSessionDto(sessionEntity)
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
        wcSession: WalletConnectSessionDto,
        wcSessionAccountList: List<WalletConnectSessionAccountDto>
    ) {
        walletConnectDao.insertWalletConnectSessionAndHistory(
            wcSessionEntity = sessionEntityMapper.mapToSessionEntity(wcSession),
            wcSessionAccountList = wcSessionAccountList.map { sessionAccountEntityMapper.mapToSessionAccountEntity(it) }
        )
    }

    override suspend fun setConnectedSession(sessionId: Long) {
        walletConnectDao.setSessionConnected(sessionId)
    }

    override suspend fun getWCSessionList(): List<WalletConnectSessionDto> {
        return walletConnectDao.getWCSessionList().map { sessionDtoMapper.mapToSessionDto(it) }
    }

    override suspend fun getWCSessionListByAccountAddress(
        accountAddress: String
    ): List<WalletConnectSessionByAccountsAddressDto>? {
        return walletConnectDao.getWCSessionListByAccountAddress(accountAddress)?.map {
            sessionByAccountsAddressDtoMapper.mapToSessionByAccountsAddressDto(it)
        }
    }

    override suspend fun getConnectedAccountsOfSession(
        sessionId: Long
    ): List<WalletConnectSessionAccountDto>? {
        return walletConnectDao.getConnectedAccountsOfSession(sessionId)?.map {
            sessionAccountDtoMapper.mapToSessionAccountDto(it)
        }
    }

    override fun getAllWalletConnectSessionWithAccountAddresses():
        Flow<List<WalletConnectSessionWithAccountsAddressesDto>?> {
        return walletConnectDao.getAllWalletConnectSessionWithAccountAddresses().map { sessionWithAccAddrList ->
            sessionWithAccAddrList?.map { sessionWithAccAddr ->
                sessionWithAccountsAddressesDtoMapper.mapToSessionWithAccountsAddressesDto(sessionWithAccAddr)
            }
        }
    }

    override suspend fun deleteWalletConnectAccountBySession(sessionId: Long, accountAddress: String) {
        return walletConnectDao.deleteWalletConnectAccountBySession(sessionId, accountAddress)
    }

    override suspend fun setGivenSessionAsSubscribed(sessionId: Long) {
        walletConnectDao.setGivenSessionAsSubscribed(sessionId)
    }

    override suspend fun getWalletConnectSessionListOrderedByCreationTime(count: Int): List<WalletConnectSessionDto> {
        return walletConnectDao.getWalletConnectSessionListOrderedByCreationTime(count)?.map { sessionEntity ->
            sessionDtoMapper.mapToSessionDto(sessionEntity)
        }.orEmpty()
    }

    override suspend fun getWalletConnectSessionCount(): Int {
        return walletConnectDao.getWalletConnectSessionCount()
    }

    override suspend fun isSessionRequestIdExist(requestId: Long): Boolean {
        return walletConnectDao.isSessionRequestIdExist(requestId)
    }

    override suspend fun isTransactionRequestIdExist(requestId: Long): Boolean {
        return walletConnectDao.isTransactionRequestIdExist(requestId)
    }

    override suspend fun setSessionRequestId(requestId: Long, timestampAsSec: Long) {
        val sessionRequestIdEntity = sessionRequestIdEntityMapper.mapToEntity(requestId, timestampAsSec)
        walletConnectDao.insertWalletConnectSessionRequestId(sessionRequestIdEntity)
    }

    override suspend fun setTransactionRequestId(requestId: Long, timestampAsSec: Long) {
        val transactionRequestIdEntity = transactionRequestIdEntityMapper.mapToEntity(requestId, timestampAsSec)
        walletConnectDao.insertWalletConnectTransactionRequestId(transactionRequestIdEntity)
    }
}
