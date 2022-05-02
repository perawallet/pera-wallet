@file:Suppress("TooManyFunctions")
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

import android.content.res.Resources
import android.text.format.DateUtils
import com.algorand.android.R
import com.algorand.android.models.DateRange
import java.time.DayOfWeek
import java.time.Instant
import java.time.LocalTime
import java.time.OffsetDateTime
import java.time.ZoneId
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import java.time.format.DateTimeFormatterBuilder
import java.time.temporal.TemporalAdjusters

const val MONTH_DAY_YEAR_PATTERN = "MMMM dd, yyyy"
const val MONTH_DAY_YEAR_WITH_DOT_PATTERN = "MM.dd.yyyy"
const val CSV_PATTERN = "MM-dd-yyyy"
const val MONTH_DAY_PATTERN = "MMM dd"
const val DATE_AND_TIME_PATTERN = "MMMM dd, yyyy - HH:mm"
const val DATE_AND_TIME_SEC_PATTERN = "MMMM dd, yyyy - HH:mm:ss"
const val TXN_DATE_AND_TIME_PATTERN = "MMMM dd, yyyy hh:mm a"
const val TXN_DATE_PATTERN = "MMM dd, yyyy"
const val UTC_ZONE_ID = "UTC"

const val UNIX_TIME_STAMP_MULTIPLIER = 1000
private const val WEEK_IN_DAYS = 7L
private const val MINUTE_IN_SECONDS = 60
private const val MIN_TO_SEC_MULTIPLIER = 60
const val ONE_DAY_IN_MILLIS = (1000 * 60 * 60 * 24)

fun ZonedDateTime.formatAsTxString(): String {
    return format(DateTimeFormatter.ofPattern(MONTH_DAY_YEAR_PATTERN))
}

fun ZonedDateTime.formatAsDateAndTime(): String {
    return format(DateTimeFormatter.ofPattern(DATE_AND_TIME_PATTERN))
}

fun ZonedDateTime.format(pattern: String): String {
    return format(DateTimeFormatter.ofPattern(pattern))
}

fun ZonedDateTime.formatAsDate(): String {
    return format(DateTimeFormatter.ofPattern(TXN_DATE_PATTERN))
}

fun ZonedDateTime.formatAsTxnDateAndTime(): String {
    return format(DateTimeFormatter.ofPattern(TXN_DATE_AND_TIME_PATTERN))
}

fun ZonedDateTime.formatAsCustomDateString(): String {
    return format(DateTimeFormatter.ofPattern(MONTH_DAY_YEAR_WITH_DOT_PATTERN))
}

fun Long.getZonedDateTimeFromTimeStamp(): ZonedDateTime {
    val zone = ZoneId.systemDefault()
    return Instant.ofEpochMilli(this * UNIX_TIME_STAMP_MULTIPLIER).atZone(zone)
}

fun getBeginningOfDay(dayBefore: Long = 0): ZonedDateTime {
    return ZonedDateTime.now().minusDays(dayBefore).with(LocalTime.MIN)
}

fun getEndOfDay(dayBefore: Long = 0): ZonedDateTime {
    return ZonedDateTime.now().minusDays(dayBefore).with(LocalTime.MAX)
}

fun getLastWeekRange(): DateRange {
    val beginningOfWeek = ZonedDateTime.now().minusWeeks(1).with(DayOfWeek.MONDAY).with(LocalTime.MIN)
    val endOfWeek = beginningOfWeek.plusDays(WEEK_IN_DAYS - 1).with(LocalTime.MAX)
    return DateRange(from = beginningOfWeek, to = endOfWeek)
}

fun getLastMonthRange(): DateRange {
    val beginningOfMonth = ZonedDateTime.now().minusMonths(1).withDayOfMonth(1).with(LocalTime.MIN)
    val endOfMonth = beginningOfMonth.with(TemporalAdjusters.lastDayOfMonth()).with(LocalTime.MAX)
    return DateRange(from = beginningOfMonth, to = endOfMonth)
}

fun ZonedDateTime?.formatAsRFC3339Version(): String? {
    return this?.format(DateTimeFormatter.ISO_OFFSET_DATE_TIME)
}

fun Long.getTimeAsMinSecondPair(): Pair<Long, Long> {
    val timeInSeconds = this / DateUtils.SECOND_IN_MILLIS
    return Pair(timeInSeconds / MINUTE_IN_SECONDS, timeInSeconds % MINUTE_IN_SECONDS)
}

fun getAlgorandMobileDateFormatter(): DateTimeFormatter {
    return DateTimeFormatterBuilder()
        .append(DateTimeFormatter.ISO_LOCAL_DATE_TIME).appendOffset("+HHMM", "0000")
        .toFormatter()
}

fun String?.parseFormattedDate(dateTimeFormatter: DateTimeFormatter): ZonedDateTime? {
    return try {
        if (this == null) {
            null
        } else {
            OffsetDateTime.parse(this, dateTimeFormatter).toZonedDateTime()
        }
    } catch (exception: Exception) {
        null
    }
}

fun ZonedDateTime?.orNow(): ZonedDateTime {
    return this ?: ZonedDateTime.now()
}

fun getRelativeTimeDifference(resources: Resources, time: ZonedDateTime, timeDifference: Long): String {
    return when {
        timeDifference < DateUtils.MINUTE_IN_MILLIS -> resources.getString(R.string.just_now)
        timeDifference < DateUtils.HOUR_IN_MILLIS -> {
            val minute = (timeDifference / DateUtils.MINUTE_IN_MILLIS).toInt()
            resources.getQuantityString(R.plurals.min_ago, minute, minute)
        }
        timeDifference < DateUtils.DAY_IN_MILLIS -> {
            val hours = (timeDifference / DateUtils.HOUR_IN_MILLIS).toInt()
            resources.getQuantityString(R.plurals.hours_ago, hours, hours)
        }
        timeDifference < DateUtils.WEEK_IN_MILLIS -> {
            val days = (timeDifference / DateUtils.DAY_IN_MILLIS).toInt()
            resources.getQuantityString(R.plurals.days_ago, days, days)
        }
        else -> {
            time.format(DateTimeFormatter.ofPattern(MONTH_DAY_YEAR_PATTERN))
        }
    }
}

fun getCurrentTimeAsSec() = System.currentTimeMillis() / UNIX_TIME_STAMP_MULTIPLIER

fun getCurrentSystemTimeAsMillis() = System.currentTimeMillis()

fun convertMinToSec(min: Long) = min * MIN_TO_SEC_MULTIPLIER

fun getZonedDateTimeAsSec() = ZonedDateTime.now().toEpochSecond()

fun getZonedDateTimeFromSec(sec: Long): ZonedDateTime? {
    return ZonedDateTime.ofInstant(Instant.ofEpochSecond(sec), ZoneId.systemDefault())
}

fun createBeginningOfDayZonedDateTime(year: Int, month: Int, day: Int): ZonedDateTime {
    return ZonedDateTime.of(
        year,
        month,
        day,
        LocalTime.MIN.hour,
        LocalTime.MIN.minute,
        LocalTime.MIN.second,
        LocalTime.MIN.nano,
        ZoneId.of(UTC_ZONE_ID)
    )
}

fun createEndOfDayZonedDateTime(year: Int, month: Int, day: Int): ZonedDateTime {
    return ZonedDateTime.of(
        year,
        month,
        day,
        LocalTime.MAX.hour,
        LocalTime.MAX.minute,
        LocalTime.MAX.second,
        LocalTime.MAX.nano,
        ZoneId.of(UTC_ZONE_ID)
    )
}

fun getCurrentTimeAsZonedDateTime(): ZonedDateTime {
    return ZonedDateTime.now()
}

fun getPreviousDayZonedDateTime(differenceAsDay: Long): ZonedDateTime {
    return ZonedDateTime.now().minusDays(differenceAsDay)
}

fun convertDateInMillisToStartOfDay(date: Long): Long {
    return date - (date % ONE_DAY_IN_MILLIS)
}
