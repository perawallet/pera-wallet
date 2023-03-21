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

package com.algorand.android.models

import android.os.Parcelable
import com.algorand.android.models.Account.Type.LEDGER
import com.algorand.android.models.Account.Type.REKEYED
import com.algorand.android.models.Account.Type.STANDARD
import com.algorand.android.models.Account.Type.WATCH
import com.algorand.android.modules.sorting.accountsorting.util.NOT_INITIALIZED_ACCOUNT_INDEX
import com.algorand.android.utils.toShortenedAddress
import com.google.gson.annotations.SerializedName
import kotlinx.parcelize.Parcelize

@Parcelize
data class Account constructor(
    @SerializedName("publicKey")
    val address: String,
    @SerializedName("accountName")
    var name: String = "",
    val type: Type? = null,
    val detail: Detail? = null,
    var index: Int = NOT_INITIALIZED_ACCOUNT_INDEX
) : Parcelable {

    fun isRegistrationCompleted(): Boolean {
        return !(address.isBlank() || name.isBlank())
    }

    fun getSecretKey(): ByteArray? {
        return when (detail) {
            is Detail.Standard -> detail.secretKey
            is Detail.Rekeyed -> detail.secretKey
            is Detail.RekeyedAuth -> detail.secretKey
            else -> null // TODO may throw exception later.
        }
    }

    fun canSignTransaction(): Boolean {
        return type != null && type != WATCH && type != REKEYED
    }

    fun getAuthTypeAndDetail(): Detail? {
        return when (val accountDetail = detail) {
            is Detail.RekeyedAuth -> accountDetail.authDetail
            is Detail.Standard -> accountDetail
            is Detail.Ledger -> accountDetail
            else -> null
        }
    }

    // TODO Combine Detail class with Account.Type class
    sealed class Detail : Parcelable {
        @Parcelize
        data class Standard(val secretKey: ByteArray) : Detail()

        @Parcelize
        data class Ledger(
            val bluetoothAddress: String,
            val bluetoothName: String?,
            val positionInLedger: Int = 0
        ) : Detail()

        // TODO: we can't keep account secret key here due to migration issue. we cannot support older version
        @Parcelize
        data class Rekeyed(val secretKey: ByteArray?) : Detail()

        @Parcelize
        data class RekeyedAuth(
            val authDetail: Detail?,
            val authDetailType: Type?,
            val secretKey: ByteArray?,
            val rekeyedAuthDetail: Map<String, Ledger>
        ) : Detail() {
            companion object {
                fun create(
                    authDetail: Detail?,
                    rekeyedAuthDetail: Map<String, Ledger>,
                    secretKey: ByteArray?
                ): RekeyedAuth {
                    val authDetailType = when (authDetail) {
                        is Standard -> STANDARD
                        is Ledger -> LEDGER
                        else -> null
                    }
                    val safeAuthDetail = authDetail.takeIf { authDetailType != null }
                    return RekeyedAuth(safeAuthDetail, authDetailType, secretKey, rekeyedAuthDetail)
                }
            }
        }

        @Parcelize
        object Watch : Detail()
    }

    enum class Type {
        // STANDARD is personal account which its secretKey is stored on the device.
        STANDARD,
        LEDGER,
        REKEYED,
        REKEYED_AUTH,
        WATCH
    }

    override fun toString(): String {
        return "Account(publicKey='$address', accountName='$name', type=$type, detail=$detail, index=$index)"
    }

    companion object {

        val defaultAccountType = STANDARD

        fun create(
            publicKey: String,
            detail: Detail,
            accountName: String = publicKey.toShortenedAddress(),
            index: Int = NOT_INITIALIZED_ACCOUNT_INDEX
        ): Account {
            val type = when (detail) {
                is Detail.Standard -> STANDARD
                is Detail.Ledger -> LEDGER
                is Detail.Rekeyed -> REKEYED
                is Detail.Watch -> WATCH
                is Detail.RekeyedAuth -> Type.REKEYED_AUTH
            }

            return Account(
                address = publicKey,
                name = accountName,
                type = type,
                detail = detail,
                index = index
            )
        }
    }
}
