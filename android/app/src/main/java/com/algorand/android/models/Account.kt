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
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import com.algorand.android.R
import com.algorand.android.usecase.BaseAccountOrderUseCase.Companion.NOT_INITIALIZED_ACCOUNT_INDEX
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
    var accountIconColor: AccountIconColor,
    var index: Int = NOT_INITIALIZED_ACCOUNT_INDEX
) : Parcelable {

    fun isRegistrationCompleted(): Boolean {
        return !(address.isBlank() || name.isBlank())
    }

    fun getSecretKey(): ByteArray? {
        return when (detail) {
            is Detail.Standard -> detail.secretKey
            else -> null // TODO may throw exception later.
        }
    }

    fun createAccountIcon(): AccountIcon {
        return AccountIcon.create(accountIconColor, type?.iconResId)
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

        @Parcelize
        object Rekeyed : Detail()

        @Parcelize
        data class RekeyedAuth(
            val authDetail: Detail?,
            val authDetailType: Type?,
            val rekeyedAuthDetail: Map<String, Ledger>
        ) : Detail() {
            companion object {
                fun create(authDetail: Detail?, rekeyedAuthDetail: Map<String, Ledger>): RekeyedAuth {
                    val authDetailType = when (authDetail) {
                        is Standard -> Type.STANDARD
                        is Ledger -> Type.LEDGER
                        else -> null
                    }
                    val safeAuthDetail = authDetail.takeIf { authDetailType != null }
                    return RekeyedAuth(safeAuthDetail, authDetailType, rekeyedAuthDetail)
                }
            }
        }

        @Parcelize
        object Watch : Detail()
    }

    enum class Type(@DrawableRes val iconResId: Int) {
        // STANDARD is personal account which its secretKey is stored on the device.
        STANDARD(R.drawable.ic_wallet_curve),
        LEDGER(R.drawable.ic_ledger),
        REKEYED(R.drawable.ic_ledger_rekeyed),
        REKEYED_AUTH(R.drawable.ic_ledger_rekeyed),
        WATCH(R.drawable.ic_eye)
    }

    override fun toString(): String {
        return "Account(publicKey='$address', accountName='$name', type=$type, detail=$detail, index=$index)"
    }

    /**
     * Should be used in Account class only and it shouldn't be changed
     * It may break migration, so changes should be tested.
     */
    enum class AccountIconColor(@ColorRes val backgroundColorResId: Int, @ColorRes val iconTintResId: Int) {

        BLUSH(R.color.account_icon_background_color_blush, R.color.account_icon_tint_color_blush),

        ORANGE(R.color.account_icon_background_color_orange, R.color.account_icon_tint_color_orange),

        PURPLE(R.color.account_icon_background_color_purple, R.color.account_icon_tint_color_purple),

        TURQUOISE(R.color.account_icon_background_color_turquoise, R.color.account_icon_tint_color_turquoise),

        SALMON(R.color.account_icon_background_color_salmon, R.color.account_icon_tint_color_salmon),

        UNDEFINED(R.color.transparent, R.color.transparent);

        companion object {
            fun getRandomColor() = listOf(BLUSH, ORANGE, PURPLE, TURQUOISE, SALMON).random()

            fun getByName(name: String?): AccountIconColor {
                return values().firstOrNull { it.name == name } ?: UNDEFINED
            }
        }
    }

    companion object {

        val defaultAccountType = Type.STANDARD
        val defaultAccountIconColor = AccountIconColor.UNDEFINED

        fun create(
            publicKey: String,
            detail: Detail,
            accountName: String = publicKey.toShortenedAddress(),
            iconColor: AccountIconColor? = null,
            index: Int = NOT_INITIALIZED_ACCOUNT_INDEX
        ): Account {
            val type = when (detail) {
                is Detail.Standard -> Type.STANDARD
                is Detail.Ledger -> Type.LEDGER
                is Detail.Rekeyed -> Type.REKEYED
                is Detail.Watch -> Type.WATCH
                is Detail.RekeyedAuth -> Type.REKEYED_AUTH
            }
            return Account(publicKey, accountName, type, detail, iconColor ?: AccountIconColor.getRandomColor(), index)
        }
    }
}
