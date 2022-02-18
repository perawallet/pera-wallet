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

package com.algorand.android.utils

import com.algorand.android.models.CurrencyValue
import java.math.BigDecimal
import java.math.BigInteger
import java.math.RoundingMode

fun getAlgoBalanceAsCurrencyValue(balance: BigInteger?, currencyValue: CurrencyValue): BigDecimal? {
    val algoValue = balance?.toBigDecimal()?.movePointLeft(ALGO_DECIMALS) ?: return null
    return currencyValue.getAlgorandCurrencyValue()?.multiply(algoValue)
}

fun BigDecimal.formatAsCurrency(symbol: String): String {
    val formattedAmount = getFullStringFormat(DOLLAR_DECIMALS).apply {
        roundingMode = RoundingMode.FLOOR
    }.format(this)
    return StringBuilder(symbol).append(formattedAmount).toString()
}

fun BigInteger.toAlgoDisplayValue(): BigDecimal {
    return toBigDecimal().movePointLeft(ALGO_DECIMALS)
}
