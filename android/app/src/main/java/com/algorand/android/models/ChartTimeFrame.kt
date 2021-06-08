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

import com.algorand.android.R

sealed class ChartTimeFrame {
    abstract val buttonDisplayResId: Int
    abstract val percentageChangeDescriptionResId: Int
    abstract val interval: ChartInterval

    object HourTimeFrame : ChartTimeFrame() {
        override val buttonDisplayResId: Int = R.string.one_hour_abbr
        override val percentageChangeDescriptionResId: Int = R.string.last_one_hour
        override val interval: ChartInterval = ChartInterval.FiveMinInterval(HOUR_TIME_FRAME_AS_MIN)
    }

    object DayTimeFrame : ChartTimeFrame() {
        override val buttonDisplayResId = R.string.one_day_abbr
        override val percentageChangeDescriptionResId: Int = R.string.last_one_day
        override val interval: ChartInterval = ChartInterval.FifteenMinInterval(DAY_TIME_FRAME_AS_MIN)
    }

    object WeekTimeFrame : ChartTimeFrame() {
        override val buttonDisplayResId = R.string.one_week_abbr
        override val percentageChangeDescriptionResId: Int = R.string.last_one_week
        override val interval: ChartInterval = ChartInterval.ThreeHoursInterval(WEEK_TIME_FRAME_AS_MIN)
    }

    object MonthTimeFrame : ChartTimeFrame() {
        override val buttonDisplayResId = R.string.one_month_abbr
        override val percentageChangeDescriptionResId: Int = R.string.last_one_month
        override val interval: ChartInterval = ChartInterval.TwelveHoursInterval(MONTH_TIME_FRAME_AS_MIN)
    }

    object YearTimeFrame : ChartTimeFrame() {
        override val buttonDisplayResId = R.string.one_year_abbr
        override val percentageChangeDescriptionResId: Int = R.string.last_one_year
        override val interval: ChartInterval = ChartInterval.OneWeekInterval(YEAR_TIME_FRAME_AS_MIN)
    }

    object AllTimeFrame : ChartTimeFrame() {
        override val buttonDisplayResId = R.string.all_time_abbr
        override val percentageChangeDescriptionResId: Int = R.string.all_time
        override val interval: ChartInterval = ChartInterval.TwoWeeksInterval(UNDEFINED_TIME_FRAME_AS_MIN)
    }

    companion object {
        const val ALGORAND_API_START_DATE_TIMESTAMP_AS_SEC = 1571227200L
        private const val HOUR_TIME_FRAME_AS_MIN = 60
        private const val DAY_TIME_FRAME_AS_MIN = 60 * 24
        private const val WEEK_TIME_FRAME_AS_MIN = 60 * 24 * 7
        private const val MONTH_TIME_FRAME_AS_MIN = 60 * 24 * 30
        private const val YEAR_TIME_FRAME_AS_MIN = 60 * 24 * 365
        const val UNDEFINED_TIME_FRAME_AS_MIN = -1
    }
}
