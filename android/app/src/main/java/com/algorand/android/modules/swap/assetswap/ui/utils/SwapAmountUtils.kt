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

package com.algorand.android.modules.swap.assetswap.ui.utils

import com.algorand.android.utils.isGreaterThan
import com.algorand.android.utils.toBigDecimalOrZero
import java.math.BigDecimal

object SwapAmountUtils {

    fun isAmountValidForApiRequest(amount: String?): Boolean {
        val isAmountNull = amount?.toBigDecimalOrNull() == null
        val isAmountEndsWithNonDigitCharacter = amount?.lastOrNull()?.isDigit() != true
        val isAmountGreaterThanZero = amount.toBigDecimalOrZero() isGreaterThan BigDecimal.ZERO
        return !isAmountNull && !isAmountEndsWithNonDigitCharacter && isAmountGreaterThanZero
    }
}
