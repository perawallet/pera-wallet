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

import com.google.firebase.crashlytics.FirebaseCrashlytics
import com.google.gson.JsonDeserializationContext
import com.google.gson.JsonDeserializer
import com.google.gson.JsonElement
import com.google.gson.JsonObject
import com.google.gson.reflect.TypeToken
import java.lang.reflect.Type

class AccountDeserializer : JsonDeserializer<Account> {
    override fun deserialize(json: JsonElement, typeOfT: Type, context: JsonDeserializationContext): Account {
        val jsonObject = json.asJsonObject

        val type: Account.Type? = try {
            Account.Type.valueOf(jsonObject.get("type").asString)
        } catch (exception: Exception) {
            null
        }

        // This object comes null because used without in pre-3.0.2. Don't change null check here.
        val detail = if (type == null) {
            val secretKeyObject = jsonObject.get("secretKey")
            val secretKey = context.deserialize<ByteArray>(secretKeyObject, ByteArray::class.java)
            if (secretKey != null) {
                Account.Detail.Standard(secretKey)
            } else {
                val exception = Exception("secretKey is unknown. $jsonObject")
                FirebaseCrashlytics.getInstance().recordException(exception)
                throw exception
            }
        } else {
            val detailJsonObject = jsonObject.get("detail")?.asJsonObject
            context.deserializeDetail(type, detailJsonObject)
        }

        val name = jsonObject.get("accountName").asString
        val publicKey = jsonObject.get("publicKey").asString

        return Account.create(publicKey, detail, name)
    }

    private fun JsonDeserializationContext.deserializeDetail(
        type: Account.Type,
        detailJsonObject: JsonObject?
    ): Account.Detail {
        return when (type) {
            Account.Type.STANDARD -> {
                deserialize<Account.Detail.Standard>(detailJsonObject, Account.Detail.Standard::class.java)
            }
            Account.Type.LEDGER -> {
                deserialize<Account.Detail.Ledger>(detailJsonObject, Account.Detail.Ledger::class.java)
            }
            Account.Type.REKEYED -> {
                deserialize<Account.Detail.Rekeyed>(detailJsonObject, Account.Detail.Rekeyed::class.java)
            }
            Account.Type.WATCH -> {
                deserialize<Account.Detail.Watch>(detailJsonObject, Account.Detail.Watch::class.java)
            }
            Account.Type.REKEYED_AUTH -> {
                deserializeRekeyedAuth(detailJsonObject)
            }
        }
    }

    private fun JsonDeserializationContext.deserializeRekeyedAuth(jsonObject: JsonObject?): Account.Detail.RekeyedAuth {
        val authDetailJsonObject = jsonObject?.get("authDetail")?.asJsonObject

        var rekeyedAuthDetail: Account.Detail? = null
        var rekeyedAuthType: Account.Type? = null
        if (authDetailJsonObject != null) {
            rekeyedAuthType = try {
                Account.Type.valueOf(jsonObject.get("authDetailType").asString)
            } catch (exception: Exception) {
                null
            }
            if (rekeyedAuthType != null) {
                rekeyedAuthDetail = deserializeDetail(rekeyedAuthType, authDetailJsonObject)
            }
        }
        val rekeyedAuthDetailJsonObject = jsonObject?.get("rekeyedAuthDetail")?.asJsonObject
        val rekeyedAuthDetailMapType = object : TypeToken<Map<String, Account.Detail.Ledger>>() {}.type
        val rekeyedAuthDetailMap = deserialize<Map<String, Account.Detail.Ledger>>(
            rekeyedAuthDetailJsonObject,
            rekeyedAuthDetailMapType
        )
        return Account.Detail.RekeyedAuth(rekeyedAuthDetail, rekeyedAuthType, rekeyedAuthDetailMap)
    }
}
