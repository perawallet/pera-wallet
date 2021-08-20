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

package com.algorand.android.models

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity
data class WalletConnectSessionEntity(
    @ColumnInfo(name = "id")
    @PrimaryKey
    val id: Long,

    @ColumnInfo(name = "peer_meta")
    val peerMeta: WalletConnectPeerMeta,

    @ColumnInfo(name = "wc_session")
    val wcSession: WalletConnectSessionMeta,

    @ColumnInfo(name = "date_time_stamp")
    val dateTimeStamp: Long,

    @ColumnInfo(name = "connected_account_public_key")
    val connectedAccountPublicKey: String,

    @ColumnInfo(name = "is_connected")
    val isConnected: Boolean = false
)
