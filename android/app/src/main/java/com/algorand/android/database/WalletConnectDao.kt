@file:Suppress("MaxLineLength")
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

package com.algorand.android.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import com.algorand.android.modules.walletconnect.client.v1.data.model.WalletConnectSessionAccountEntity
import com.algorand.android.modules.walletconnect.client.v1.data.model.WalletConnectSessionByAccountsAddress
import com.algorand.android.modules.walletconnect.client.v1.data.model.WalletConnectSessionEntity
import com.algorand.android.modules.walletconnect.client.v1.data.model.WalletConnectSessionWithAccountsAddresses
import kotlinx.coroutines.flow.Flow

@Dao
interface WalletConnectDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    @Transaction
    suspend fun insertWalletConnectSessionAndHistory(
        wcSessionEntity: WalletConnectSessionEntity,
        wcSessionAccountList: List<WalletConnectSessionAccountEntity>
    ) {
        insertWalletConnectSession(wcSessionEntity)
        wcSessionAccountList.forEach { insertWalletConnectSessionAccount(it) }
    }

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertWalletConnectSession(wcSessionEntity: WalletConnectSessionEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertWalletConnectSessionAccount(walletConnectSessionAccountEntity: WalletConnectSessionAccountEntity)

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

    @Query("SELECT * FROM WalletConnectSessionEntity")
    suspend fun getWCSessionList(): List<WalletConnectSessionEntity>

    @Transaction
    @Query("SELECT * FROM WalletConnectSessionAccountEntity WHERE connected_account_address = :accountAddress")
    suspend fun getWCSessionListByAccountAddress(accountAddress: String): List<WalletConnectSessionByAccountsAddress>?

    @Transaction
    @Query("SELECT * FROM WalletConnectSessionAccountEntity WHERE session_id = :sessionId")
    suspend fun getConnectedAccountsOfSession(sessionId: Long): List<WalletConnectSessionAccountEntity>?

    @Transaction
    @Query("SELECT * FROM WalletConnectSessionEntity")
    fun getAllWalletConnectSessionWithAccountAddresses(): Flow<List<WalletConnectSessionWithAccountsAddresses>?>

    @Query("DELETE FROM WalletConnectSessionAccountEntity WHERE session_id = :sessionId AND connected_account_address = :accountAddress")
    suspend fun deleteWalletConnectAccountBySession(sessionId: Long, accountAddress: String)

    @Query("UPDATE WalletConnectSessionEntity SET is_subscribed = 1 WHERE id = :sessionId")
    suspend fun setGivenSessionAsSubscribed(sessionId: Long)

    @Query("SELECT * FROM WalletConnectSessionEntity ORDER BY date_time_stamp ASC LIMIT :count")
    suspend fun getWalletConnectSessionListOrderedByCreationTime(count: Int): List<WalletConnectSessionEntity>?

    @Query("SELECT COUNT(*) FROM WalletConnectSessionEntity")
    suspend fun getWalletConnectSessionCount(): Int
}
