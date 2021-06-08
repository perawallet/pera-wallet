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
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.utils.getBeginningOfDay
import com.algorand.android.utils.getLastMonthRange
import com.algorand.android.utils.getLastWeekRange
import kotlinx.parcelize.Parcelize

sealed class DateFilter(@DrawableRes val iconResId: Int, @StringRes val titleResId: Int) : Parcelable {
    @Parcelize
    object AllTime : DateFilter(R.drawable.ic_default_date, R.string.all_time)
    @Parcelize
    object Today : DateFilter(R.drawable.ic_default_date, R.string.today)
    @Parcelize
    object Yesterday : DateFilter(R.drawable.ic_yesterday, R.string.yesterday)
    @Parcelize
    object LastWeek : DateFilter(R.drawable.ic_week, R.string.last_week)
    @Parcelize
    object LastMonth : DateFilter(R.drawable.ic_default_date, R.string.last_month)
    @Parcelize
    data class CustomRange(
        val customDateRange: DateRange? = null
    ) : DateFilter(R.drawable.ic_custom_range_pick, R.string.custom_range)

    fun getDateRange(): DateRange? {
        return when (this) {
            AllTime -> DateRange()
            Today -> DateRange(from = getBeginningOfDay())
            Yesterday -> DateRange(from = getBeginningOfDay(1), to = getBeginningOfDay())
            LastWeek -> getLastWeekRange()
            LastMonth -> getLastMonthRange()
            is CustomRange -> customDateRange
        }
    }
}
