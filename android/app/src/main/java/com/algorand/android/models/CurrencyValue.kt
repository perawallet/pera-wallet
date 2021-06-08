/*
 * Copyright 2019 Algorand, Inc.
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
import com.algorand.android.utils.formatAsDollar
import com.google.gson.annotations.SerializedName
import java.math.BigDecimal
import kotlinx.parcelize.Parcelize

@Parcelize
data class CurrencyValue(
    @SerializedName("currency_id")
    val id: String,

    @SerializedName("name")
    val name: String?,

    @SerializedName("exchange_price")
    val exchangePrice: String?
) : Parcelable {

    fun getAlgorandCurrencyValue(): BigDecimal? = exchangePrice?.toBigDecimalOrNull()

    fun getFormattedSignedCurrencyValue(price: BigDecimal? = null): String {
        val formattedCurrencyValue = (price ?: getAlgorandCurrencyValue())?.formatAsDollar()
        return if (formattedCurrencyValue.isNullOrBlank()) "" else "$formattedCurrencyValue $id"
    }
}
