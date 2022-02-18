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

import java.math.BigDecimal
import java.math.BigInteger

data class BalanceInput(
    val formattedBalance: BigInteger,
    val formattedBalanceString: String,
    val formattedBalanceInBigDecimal: BigDecimal,
    val isAmountValid: Boolean,
    val decimal: Int
) {

    companion object {
        fun createDefaultBalanceInput(): BalanceInput {
            return BalanceInput(
                formattedBalance = BigInteger.ZERO,
                formattedBalanceString = "",
                formattedBalanceInBigDecimal = BigDecimal.ZERO,
                isAmountValid = false,
                decimal = 0
            )
        }
    }
}
