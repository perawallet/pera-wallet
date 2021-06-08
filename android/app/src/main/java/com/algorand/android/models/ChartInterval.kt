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

import com.algorand.android.models.ChartTimeFrame.Companion.ALGORAND_API_START_DATE_TIMESTAMP_AS_SEC
import com.algorand.android.utils.convertMinToSec
import com.algorand.android.utils.getCurrentTimeAsSec

sealed class ChartInterval(protected open val timeFrameAsMin: Int) {

    abstract val intervalQueryParam: String
    abstract val intervalAsMin: Int

    val untilAsSec: Long by lazy { getCurrentTimeAsSec() }
    val sinceAsSec: Long by lazy { calculateSinceAsSec() }

    private fun calculateSinceAsSec(): Long {
        return if (timeFrameAsMin == ChartTimeFrame.UNDEFINED_TIME_FRAME_AS_MIN) {
            ALGORAND_API_START_DATE_TIMESTAMP_AS_SEC
        } else {
            val timeDifferenceAsMin = (timeFrameAsMin / intervalAsMin) * intervalAsMin
            return untilAsSec - convertMinToSec(timeDifferenceAsMin.toLong())
        }
    }

    companion object {
        protected const val FIVE_MIN_AS_MIN = 5
        protected const val TEN_MIN_AS_MIN = 10
        protected const val FIFTEEN_MIN_AS_MIN = 15
        protected const val THREE_HOURS_AS_MIN = 180
        protected const val TWELVE_HOURS_AS_MIN = 720
        protected const val ONE_WEEK_AS_MIN = 10080
        protected const val TWO_WEEKS_AS_MIN = 20160
    }

    data class FiveMinInterval(override val timeFrameAsMin: Int) : ChartInterval(timeFrameAsMin) {
        override val intervalQueryParam: String = "5m"
        override val intervalAsMin: Int = FIVE_MIN_AS_MIN

        companion object {
            fun getDefaultInstance(): FiveMinInterval {
                return FiveMinInterval(TEN_MIN_AS_MIN)
            }
        }
    }

    data class FifteenMinInterval(override val timeFrameAsMin: Int) : ChartInterval(timeFrameAsMin) {
        override val intervalQueryParam: String = "15m"
        override val intervalAsMin: Int = FIFTEEN_MIN_AS_MIN
    }

    data class ThreeHoursInterval(override val timeFrameAsMin: Int) : ChartInterval(timeFrameAsMin) {
        override val intervalQueryParam: String = "3H"
        override val intervalAsMin: Int = THREE_HOURS_AS_MIN
    }

    data class TwelveHoursInterval(override val timeFrameAsMin: Int) : ChartInterval(timeFrameAsMin) {
        override val intervalQueryParam: String = "12H"
        override val intervalAsMin: Int = TWELVE_HOURS_AS_MIN
    }

    data class OneWeekInterval(override val timeFrameAsMin: Int) : ChartInterval(timeFrameAsMin) {
        override val intervalQueryParam: String = "7D"
        override val intervalAsMin: Int = ONE_WEEK_AS_MIN
    }

    data class TwoWeeksInterval(override val timeFrameAsMin: Int) : ChartInterval(timeFrameAsMin) {
        override val intervalQueryParam: String = "2W"
        override val intervalAsMin: Int = TWO_WEEKS_AS_MIN
    }
}
