/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.modules.dapp.moonpay.domain.model

import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import com.algorand.android.R

enum class MoonpayTransactionStatus(
    val value: String,
    @DrawableRes val iconRes: Int,
    @ColorRes val iconTintRes: Int,
    @StringRes val titleRes: Int,
    @StringRes val descriptionRes: Int
) {
    COMPLETED(
        "completed",
        R.drawable.ic_check,
        R.color.link_primary,
        R.string.success_algo_received,
        R.string.congratulations_your_account_has
    ),
    PENDING(
        "pending",
        R.drawable.ic_hourglass,
        R.color.link_primary,
        R.string.your_algos_are,
        R.string.your_payment_is
    ),
    FAILED(
        "failed",
        R.drawable.ic_error,
        R.color.negative,
        R.string.uh_oh_something,
        R.string.looks_like_your
    ),
    WAITING_PAYMENT(
        "waitingpayment",
        R.drawable.ic_hourglass,
        R.color.link_primary,
        R.string.almost_there,
        R.string.your_purchase_request_is_pending
    ),
    WAITING_AUTHORIZATION(
        "waitingauthorization",
        R.drawable.ic_hourglass,
        R.color.link_primary,
        R.string.success_algo_received,
        R.string.your_purchase_request_is_wating
    );

    companion object {
        fun getByValueOrDefault(value: String): MoonpayTransactionStatus {
            return MoonpayTransactionStatus.values().firstOrNull { it.value == value } ?: COMPLETED
        }
    }
}
