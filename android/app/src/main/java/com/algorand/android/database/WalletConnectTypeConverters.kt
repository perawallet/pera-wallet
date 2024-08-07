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

import androidx.room.ProvidedTypeConverter
import androidx.room.TypeConverter
import com.algorand.android.modules.walletconnect.client.v1.data.model.WalletConnectPeerMetaEntity
import com.algorand.android.modules.walletconnect.client.v1.data.model.WalletConnectSessionMetaEntity
import com.google.gson.Gson
import javax.inject.Inject

@ProvidedTypeConverter
class WalletConnectTypeConverters @Inject constructor(
    private val gson: Gson
) {

    @TypeConverter
    fun wcSessionToJson(wcSession: WalletConnectSessionMetaEntity): String {
        return gson.toJson(wcSession)
    }

    @TypeConverter
    fun jsonToWcSession(json: String): WalletConnectSessionMetaEntity {
        return gson.fromJson(json, WalletConnectSessionMetaEntity::class.java)
    }

    @TypeConverter
    fun peerMetaToJson(peerMeta: WalletConnectPeerMetaEntity): String {
        return gson.toJson(peerMeta)
    }

    @TypeConverter
    fun jsonToPeerMeta(json: String): WalletConnectPeerMetaEntity {
        return gson.fromJson(json, WalletConnectPeerMetaEntity::class.java)
    }
}
