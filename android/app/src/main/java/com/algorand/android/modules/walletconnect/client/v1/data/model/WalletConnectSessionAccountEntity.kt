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

package com.algorand.android.modules.walletconnect.client.v1.data.model

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.ForeignKey.Companion.CASCADE
import androidx.room.PrimaryKey
import com.algorand.android.modules.walletconnect.client.v1.data.model.WalletConnectSessionAccountEntity.Companion.WALLET_CONNECT_SESSION_ACCOUNT_TABLE_SESSION_ID_COLUMN_NAME
import com.algorand.android.modules.walletconnect.client.v1.data.model.WalletConnectSessionEntity.Companion.WALLET_CONNECT_SESSION_TABLE_SESSION_ID_COLUMN_NAME

@Entity(
    foreignKeys = [
        ForeignKey(
            entity = WalletConnectSessionEntity::class,
            parentColumns = arrayOf(WALLET_CONNECT_SESSION_TABLE_SESSION_ID_COLUMN_NAME),
            childColumns = arrayOf(WALLET_CONNECT_SESSION_ACCOUNT_TABLE_SESSION_ID_COLUMN_NAME),
            onDelete = CASCADE,
            onUpdate = CASCADE
        )
    ]
)
data class WalletConnectSessionAccountEntity(
    @ColumnInfo(name = "id")
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,

    @ColumnInfo(name = WALLET_CONNECT_SESSION_ACCOUNT_TABLE_SESSION_ID_COLUMN_NAME)
    val sessionId: Long,

    @ColumnInfo(name = "connected_account_address")
    val connectedAccountsAddress: String
) {

    companion object {
        const val WALLET_CONNECT_SESSION_ACCOUNT_TABLE_SESSION_ID_COLUMN_NAME = "session_id"
    }
}
