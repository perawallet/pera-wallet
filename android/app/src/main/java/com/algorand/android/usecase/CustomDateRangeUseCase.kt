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

package com.algorand.android.usecase

import com.algorand.android.mapper.CustomDateRangePreviewMapper
import com.algorand.android.mapper.CustomRangeMapper
import com.algorand.android.mapper.DatePickerDateMapper
import com.algorand.android.mapper.DateRangeMapper
import com.algorand.android.models.DateFilter
import com.algorand.android.models.DateRange
import com.algorand.android.models.ui.CustomDateRangePreview
import com.algorand.android.utils.ONE_DAY_IN_MILLIS
import com.algorand.android.utils.convertDateInMillisToStartOfDay
import com.algorand.android.utils.createBeginningOfDayZonedDateTime
import com.algorand.android.utils.createEndOfDayZonedDateTime
import com.algorand.android.utils.formatAsCustomDateString
import com.algorand.android.utils.getCurrentTimeAsZonedDateTime
import com.algorand.android.utils.getPreviousDayZonedDateTime
import java.time.ZonedDateTime
import javax.inject.Inject

class CustomDateRangeUseCase @Inject constructor(
    private val customDateRangePreviewMapper: CustomDateRangePreviewMapper,
    private val datePickerDateMapper: DatePickerDateMapper,
    private val dateRangeMapper: DateRangeMapper,
    private val customRangeMapper: CustomRangeMapper
) {
    fun createCustomDateRangePreview(latestDateRange: DateRange?, isFromFocused: Boolean): CustomDateRangePreview {
        val defaultToDate = getCurrentTimeAsZonedDateTime()
        val defaultFromDate = getPreviousDayZonedDateTime(DEFAULT_DAY_DIFFERENCE_BETWEEN_FROM_AND_TO)

        val fromDate = latestDateRange?.from ?: defaultFromDate
        val toDate = latestDateRange?.to ?: defaultToDate

        val formattedFromDate = fromDate.formatAsCustomDateString()
        val formattedToDate = toDate.formatAsCustomDateString()

        val minDate = createMinDate(fromDate, isFromFocused)
        val maxDate = createMaxDate(toDate, isFromFocused, System.currentTimeMillis())

        // Subtracting 1 from month as date picker in UI level accepts months from 0-11
        val focusedDatePickerDate = if (isFromFocused) {
            with(fromDate) { datePickerDateMapper.mapTo(year, monthValue - 1, dayOfMonth) }
        } else {
            with(toDate) { datePickerDateMapper.mapTo(year, monthValue - 1, dayOfMonth) }
        }

        return customDateRangePreviewMapper.mapTo(
            formattedFromDate = formattedFromDate,
            formattedToDate = formattedToDate,
            focusedDatePickerDate = focusedDatePickerDate,
            isFromFocused = isFromFocused,
            minDate = minDate,
            maxDate = maxDate
        )
    }

    fun createUpdatedCustomRange(
        customRange: DateFilter.CustomRange,
        isFromFocused: Boolean,
        datePickerYear: Int,
        datePickerMonth: Int,
        datePickerDay: Int
    ): DateFilter.CustomRange {
        // Adding 1 to month because date picker in UI level return months from 0-11
        val dateRange = if (isFromFocused) {
            dateRangeMapper.mapTo(
                createBeginningOfDayZonedDateTime(datePickerYear, datePickerMonth + 1, datePickerDay),
                customRange.customDateRange?.to
            )
        } else {
            dateRangeMapper.mapTo(
                customRange.customDateRange?.from,
                createEndOfDayZonedDateTime(datePickerYear, datePickerMonth + 1, datePickerDay)
            )
        }
        return DateFilter.CustomRange(dateRange)
    }

    fun getDefaultCustomRange(): DateFilter.CustomRange {
        return customRangeMapper.mapTo(
            dateRangeMapper.mapTo(
                getPreviousDayZonedDateTime(DEFAULT_DAY_DIFFERENCE_BETWEEN_FROM_AND_TO),
                getCurrentTimeAsZonedDateTime()
            )
        )
    }

    private fun createMinDate(fromZonedDateTime: ZonedDateTime?, isFromFocused: Boolean): Long {
        return if (isFromFocused) {
            DEFAULT_MIN_DATE_IN_MILLIS
        } else {
            fromZonedDateTime?.toInstant()?.toEpochMilli()?.plus(ONE_DAY_IN_MILLIS) ?: DEFAULT_MIN_DATE_IN_MILLIS
        }
    }

    private fun createMaxDate(toZonedDateTime: ZonedDateTime?, isFromFocused: Boolean, defaultMax: Long): Long {
        // We need to convert date to start of day because date picker rounds it up to next day after 11PM
        return if (isFromFocused) {
            toZonedDateTime?.toInstant()
                ?.toEpochMilli()
                ?.minus(ONE_DAY_IN_MILLIS)
                ?.let { convertDateInMillisToStartOfDay(it) }
                ?: convertDateInMillisToStartOfDay(defaultMax)
        } else {
            convertDateInMillisToStartOfDay(defaultMax) + 1
        }
    }

    companion object {
        private const val DEFAULT_DAY_DIFFERENCE_BETWEEN_FROM_AND_TO = 1L

        // This date corresponds to 01.01.2019
        const val DEFAULT_MIN_DATE_IN_MILLIS = 1546290000000
    }
}
