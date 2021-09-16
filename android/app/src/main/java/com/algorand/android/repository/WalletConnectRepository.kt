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

package com.algorand.android.repository

import com.algorand.android.database.WalletConnectDao
import com.algorand.android.models.WalletConnectSessionEntity
import com.algorand.android.models.WalletConnectSessionHistoryEntity
import javax.inject.Inject

class WalletConnectRepository @Inject constructor(
    private val walletConnectDao: WalletConnectDao
) {

    fun getAllWCSession() = walletConnectDao.getAllWCSessions()

    suspend fun getAllDisconnectedSessions(): List<WalletConnectSessionEntity> {
        return walletConnectDao.getAllDisconnectedWCSessions()
    }

    suspend fun getSessionById(sessionId: Long): WalletConnectSessionEntity? {
        return walletConnectDao.getSessionById(sessionId)
    }

    suspend fun deleteSessionById(sessionId: Long) {
        walletConnectDao.deleteById(sessionId)
    }

    suspend fun setAllSessionsDisconnected() {
        walletConnectDao.setAllSessionsDisconnected()
    }

    suspend fun setSessionDisconnected(sessionId: Long) {
        walletConnectDao.setSessionDisconnected(sessionId)
    }

    suspend fun insertConnectedWalletConnectSession(
        wcSessionEntity: WalletConnectSessionEntity,
        wcSessionHistoryEntity: WalletConnectSessionHistoryEntity
    ) {
        walletConnectDao.insertWalletConnectSessionAndHistory(
            wcSessionEntity = wcSessionEntity,
            wcSessionEntityHistory = wcSessionHistoryEntity
        )
    }

    suspend fun setConnectedSession(session: WalletConnectSessionEntity) {
        walletConnectDao.setSessionConnected(session.id)
    }
}
