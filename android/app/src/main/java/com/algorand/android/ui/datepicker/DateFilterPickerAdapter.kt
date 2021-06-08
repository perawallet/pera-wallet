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

package com.algorand.android.ui.datepicker

import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.DateFilter

class DateFilterPickerAdapter(
    private val listener: Listener,
    private var selectedDateFilter: DateFilter,
    private var customRange: DateFilter.CustomRange
) : RecyclerView.Adapter<DateFilterPickerViewHolder>() {

    private val dateFilters = mutableListOf(
        DateFilter.AllTime,
        DateFilter.Today,
        DateFilter.Yesterday,
        DateFilter.LastWeek,
        DateFilter.LastMonth,
        customRange
    )

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): DateFilterPickerViewHolder {
        return DateFilterPickerViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    val newSelectedDateFilter = dateFilters[bindingAdapterPosition]
                    if (newSelectedDateFilter is DateFilter.CustomRange) {
                        listener.onCustomRangeClick(customRange)
                    } else {
                        if (selectedDateFilter != newSelectedDateFilter) {
                            selectedDateFilter = newSelectedDateFilter
                            listener.onDateFilterChanged(newSelectedDateFilter)
                            notifyDataSetChanged() // Used NotifyDataSetChanged to update all dates.
                        }
                    }
                }
            }
        }
    }

    override fun getItemCount() = dateFilters.count()

    override fun onBindViewHolder(holder: DateFilterPickerViewHolder, position: Int) {
        holder.bind(dateFilters[position], isFilterSelected(position))
    }

    private fun isFilterSelected(position: Int): Boolean {
        return selectedDateFilter == dateFilters[position]
    }

    fun newCustomRangeSelected(customRange: DateFilter.CustomRange) {
        dateFilters.remove(this.customRange)
        selectedDateFilter = customRange
        this.customRange = customRange
        dateFilters.add(dateFilters.size, customRange)
        notifyDataSetChanged() // Used NotifyDataSetChanged to update all dates.
    }

    interface Listener {
        fun onDateFilterChanged(dateFilter: DateFilter)
        fun onCustomRangeClick(customRange: DateFilter.CustomRange)
    }
}
