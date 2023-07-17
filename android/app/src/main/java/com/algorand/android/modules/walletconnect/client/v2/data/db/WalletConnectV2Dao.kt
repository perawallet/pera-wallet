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

package com.algorand.android.modules.walletconnect.client.v2.data.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.algorand.android.modules.walletconnect.client.v2.data.model.WalletConnectV2SessionEntity

@Dao
interface WalletConnectV2Dao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertWalletConnectSession(wcSessionEntity: WalletConnectV2SessionEntity)

    @Query("SELECT * FROM WalletConnectV2SessionEntity WHERE topic = :sessionTopic")
    suspend fun getSessionById(sessionTopic: String): WalletConnectV2SessionEntity?

    @Query("DELETE FROM WalletConnectV2SessionEntity WHERE topic == :sessionTopic")
    suspend fun deleteById(sessionTopic: String)

    @Query("SELECT * FROM WalletConnectV2SessionEntity")
    suspend fun getWCSessionList(): List<WalletConnectV2SessionEntity>

    @Query("UPDATE WalletConnectV2SessionEntity SET is_subscribed = 1 WHERE topic == :sessionTopic")
    suspend fun setGivenSessionAsSubscribed(sessionTopic: String)
}
