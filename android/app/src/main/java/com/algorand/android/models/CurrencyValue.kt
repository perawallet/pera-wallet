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
    val exchangePrice: String?,

    @SerializedName("symbol")
    val symbol: String?,

    @SerializedName("usd_value")
    val usdValue: BigDecimal?,

    @SerializedName("last_updated_at")
    val lastUpdateTimestamp: String?, // "2021-12-15 11:21:31"

    @SerializedName("s")
    val source: String?
) : Parcelable {

    fun getAlgorandCurrencyValue(): BigDecimal? = exchangePrice?.toBigDecimalOrNull()
}
