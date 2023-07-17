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

import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.utils.Event
import java.math.BigDecimal
import java.math.BigInteger

data class AssetTransferAmountPreview(
    val assetPreview: AssetTransferAmountAssetPreview? = null,
    val senderAddress: String? = null,
    val enteredAmountSelectedCurrencyValue: String? = null,
    val decimalSeparator: String? = null,
    val selectedAmount: BigDecimal? = null,
    val onPopulateAmountWithMaxEvent: Event<Unit>? = null,
    val amountIsValidEvent: Event<BigInteger?>? = null,
    val amountIsMoreThanBalanceEvent: Event<Unit>? = null,
    val insufficientBalanceToPayFeeEvent: Event<Unit>? = null,
    val minimumBalanceIsViolatedResultEvent: Event<String?>? = null,
    val assetNotFoundErrorEvent: Event<Unit>? = null,
    val accountName: String? = null,
    val accountIconDrawablePreview: AccountIconDrawablePreview? = null
)
