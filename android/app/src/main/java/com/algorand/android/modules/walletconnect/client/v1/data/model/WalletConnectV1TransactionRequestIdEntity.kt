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
import androidx.room.PrimaryKey
import com.algorand.android.modules.walletconnect.client.v1.data.model.WalletConnectV1TransactionRequestIdEntity.Companion.WALLET_CONNECT_TRANSACTION_REQUEST_ID_TABLE_NAME

@Entity(tableName = WALLET_CONNECT_TRANSACTION_REQUEST_ID_TABLE_NAME)
data class WalletConnectV1TransactionRequestIdEntity(
    @ColumnInfo(name = WALLET_CONNECT_TRANSACTION_REQUEST_ID_ID_COLUMN_NAME)
    @PrimaryKey
    val id: Long,

    @ColumnInfo(name = WALLET_CONNECT_TRANSACTION_REQUEST_ID_TIMESTAMP_COLUMN_NAME)
    val timestampAsSec: Long
) {

    companion object {
        const val WALLET_CONNECT_TRANSACTION_REQUEST_ID_ID_COLUMN_NAME = "id"
        const val WALLET_CONNECT_TRANSACTION_REQUEST_ID_TIMESTAMP_COLUMN_NAME = "timestamp"
        const val WALLET_CONNECT_TRANSACTION_REQUEST_ID_TABLE_NAME = "WalletConnectV1TransactionRequestIdEntity"
    }
}
