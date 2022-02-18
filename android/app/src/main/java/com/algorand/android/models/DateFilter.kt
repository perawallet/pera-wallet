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
import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import com.algorand.android.R
import com.algorand.android.utils.getBeginningOfDay
import com.algorand.android.utils.getLastMonthRange
import com.algorand.android.utils.getLastWeekRange
import kotlinx.parcelize.Parcelize

sealed class DateFilter(
    @DrawableRes val iconResId: Int,
    @StringRes val titleResId: Int
) : Parcelable, RecyclerListItem {

    open var isSelected: Boolean = false

    @Parcelize
    object AllTime : DateFilter(R.drawable.ic_default_date, R.string.all_time) {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is AllTime && isSelected == other.isSelected
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is AllTime && this == other
        }
    }

    @Parcelize
    object Today : DateFilter(R.drawable.ic_default_date, R.string.today) {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is Today && isSelected == other.isSelected
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is Today && this == other
        }
    }

    @Parcelize
    object Yesterday : DateFilter(R.drawable.ic_yesterday, R.string.yesterday) {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is Yesterday && isSelected == other.isSelected
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is Yesterday && this == other
        }
    }

    @Parcelize
    object LastWeek : DateFilter(R.drawable.ic_week, R.string.last_week) {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is LastWeek && isSelected == other.isSelected
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is LastWeek && this == other
        }
    }

    @Parcelize
    object LastMonth : DateFilter(R.drawable.ic_default_date, R.string.last_month) {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is LastMonth && isSelected == other.isSelected
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is LastMonth && this == other
        }
    }

    @Parcelize
    data class CustomRange(
        val customDateRange: DateRange? = null
    ) : DateFilter(R.drawable.ic_custom_range_pick, R.string.custom_range) {
        override fun areItemsTheSame(other: RecyclerListItem): Boolean {
            return other is CustomRange && customDateRange == other.customDateRange && isSelected == other.isSelected
        }

        override fun areContentsTheSame(other: RecyclerListItem): Boolean {
            return other is CustomRange && this == other
        }
    }

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

    companion object {
        val DEFAULT_DATE_FILTER = AllTime

        fun getDateFilterList(customRange: CustomRange? = null): MutableList<DateFilter> {
            return mutableListOf(
                AllTime,
                Today,
                Yesterday,
                LastWeek,
                LastMonth,
                customRange ?: CustomRange()
            )
        }
    }
}
