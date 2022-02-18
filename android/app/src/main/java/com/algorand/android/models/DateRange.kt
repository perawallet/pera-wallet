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
import com.algorand.android.utils.MONTH_DAY_PATTERN
import com.algorand.android.utils.MONTH_DAY_YEAR_PATTERN
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import kotlinx.parcelize.Parcelize

@Parcelize
data class DateRange(val from: ZonedDateTime? = null, val to: ZonedDateTime? = null) : Parcelable {

    fun getRangeAsText(dateFilter: DateFilter): String? {
        return when (dateFilter) {
            DateFilter.AllTime -> null
            DateFilter.Today, DateFilter.Yesterday -> {
                from?.format(DateTimeFormatter.ofPattern(MONTH_DAY_PATTERN))
            }
            DateFilter.LastWeek -> {
                if (from != null && to != null) {
                    val monthDayFormatter = DateTimeFormatter.ofPattern(MONTH_DAY_PATTERN)
                    val formattedFrom = from.format(monthDayFormatter)
                    if (from.monthValue == to.monthValue) {
                        "$formattedFrom - ${to.dayOfMonth}"
                    } else {
                        val formattedTo = to.format(monthDayFormatter)
                        "$formattedFrom - $formattedTo"
                    }
                } else {
                    null
                }
            }
            DateFilter.LastMonth -> {
                "${from?.format(DateTimeFormatter.ofPattern(MONTH_DAY_PATTERN))} - ${to?.dayOfMonth}"
            }
            is DateFilter.CustomRange -> {
                if (from != null && to != null) {
                    val monthDayYearFormatter = DateTimeFormatter.ofPattern(MONTH_DAY_YEAR_PATTERN)
                    val formattedFrom = from.format(monthDayYearFormatter)
                    val formattedTo = to.format(monthDayYearFormatter)
                    "$formattedFrom - $formattedTo"
                } else {
                    null
                }
            }
        }
    }
}
