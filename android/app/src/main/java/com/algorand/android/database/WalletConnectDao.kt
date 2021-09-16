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

package com.algorand.android.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Transaction
import com.algorand.android.models.WalletConnectSessionEntity
import com.algorand.android.models.WalletConnectSessionHistoryEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface WalletConnectDao {

    @Insert
    @Transaction
    suspend fun insertWalletConnectSessionAndHistory(
        wcSessionEntity: WalletConnectSessionEntity,
        wcSessionEntityHistory: WalletConnectSessionHistoryEntity
    ) {
        insertWalletConnectSession(wcSessionEntity)
        insertWalletConnectSessionHistory(wcSessionEntityHistory)
    }

    @Insert
    suspend fun insertWalletConnectSession(wcSessionEntity: WalletConnectSessionEntity)

    @Insert
    suspend fun insertWalletConnectSessionHistory(wcSessionEntity: WalletConnectSessionHistoryEntity)

    @Query("SELECT * FROM WalletConnectSessionEntity")
    fun getAllWCSessions(): Flow<List<WalletConnectSessionEntity>>

    @Query("SELECT * FROM WalletConnectSessionEntity WHERE id = :sessionId")
    suspend fun getSessionById(sessionId: Long): WalletConnectSessionEntity?

    @Query("UPDATE WalletConnectSessionEntity SET is_connected = 0")
    suspend fun setAllSessionsDisconnected()

    @Query("UPDATE WalletConnectSessionEntity SET is_connected = 0 WHERE id = :sessionId")
    suspend fun setSessionDisconnected(sessionId: Long)

    @Query("UPDATE WalletConnectSessionEntity SET is_connected = 1 WHERE id = :sessionId")
    suspend fun setSessionConnected(sessionId: Long)

    @Query("SELECT * FROM WalletConnectSessionEntity WHERE is_connected = 0")
    suspend fun getAllDisconnectedWCSessions(): List<WalletConnectSessionEntity>

    @Query("DELETE FROM WalletConnectSessionEntity WHERE id == :sessionId")
    suspend fun deleteById(sessionId: Long)
}
