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

import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import com.algorand.android.R

enum class AccountIconResource(
    @DrawableRes val iconResId: Int,
    @ColorRes val backgroundColorResId: Int,
    @ColorRes val iconTintResId: Int
) {
    WATCH(R.drawable.ic_eye, R.color.wallet_1, R.color.wallet_1_icon),

    LEDGER(R.drawable.ic_ledger, R.color.wallet_3, R.color.wallet_3_icon),

    REKEYED(R.drawable.ic_ledger_rekeyed, R.color.wallet_3, R.color.wallet_3_icon),

    REKEYED_AUTH(R.drawable.ic_ledger_rekeyed, R.color.wallet_3, R.color.wallet_3_icon),

    STANDARD(R.drawable.ic_wallet, R.color.wallet_4, R.color.wallet_4_icon),

    UNDEFINED(R.drawable.ic_wallet, R.color.transparent, R.color.transparent);

    companion object {
        fun getAccountIconResourceByAccountType(accountType: Account.Type?): AccountIconResource {
            return when (accountType) {
                Account.Type.STANDARD -> STANDARD
                Account.Type.LEDGER -> LEDGER
                Account.Type.REKEYED -> REKEYED
                Account.Type.REKEYED_AUTH -> REKEYED_AUTH
                Account.Type.WATCH -> WATCH
                null -> UNDEFINED
            }
        }

        fun getByName(name: String?): AccountIconResource {
            return values().firstOrNull { it.name == name } ?: UNDEFINED
        }
    }
}
