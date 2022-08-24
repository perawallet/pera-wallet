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

package com.algorand.android.modules.parity.domain.mapper

import com.algorand.android.modules.parity.domain.model.SelectedCurrencyDetail
import java.math.BigDecimal
import javax.inject.Inject

class SelectedCurrencyDetailMapper @Inject constructor() {
    fun mapToSelectedCurrencyDetail(
        currencyId: String,
        currencyName: String?,
        currencySymbol: String?,
        algoToSelectedCurrencyConversionRate: BigDecimal?,
        usdToSelectedCurrencyConversionRate: BigDecimal?,
    ): SelectedCurrencyDetail {
        return SelectedCurrencyDetail(
            currencyId = currencyId,
            currencyName = currencyName,
            currencySymbol = currencySymbol,
            algoToSelectedCurrencyConversionRate = algoToSelectedCurrencyConversionRate,
            usdToSelectedCurrencyConversionRate = usdToSelectedCurrencyConversionRate
        )
    }
}
