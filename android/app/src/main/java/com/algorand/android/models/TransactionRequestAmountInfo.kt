/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.models

import java.math.BigInteger

data class TransactionRequestAmountInfo(
    val amount: BigInteger? = null,
    val fee: Long = 0L,
    val assetDecimal: Int? = null,
    val assetShortName: String? = null,
    val shouldShowFeeWarning: Boolean,
    val decimalPlaces: Long? = null,
    val defaultFrozen: Boolean? = null,
    val managerAccount: BaseWalletConnectDisplayedAddress? = null,
    val reserveAccount: BaseWalletConnectDisplayedAddress? = null,
    val freezeAccount: BaseWalletConnectDisplayedAddress? = null,
    val clawbackAccount: BaseWalletConnectDisplayedAddress? = null,
)
