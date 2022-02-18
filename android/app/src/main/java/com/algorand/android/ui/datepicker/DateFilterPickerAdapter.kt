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

package com.algorand.android.ui.datepicker

import android.view.ViewGroup
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.models.BaseDiffUtil
import com.algorand.android.models.DateFilter

class DateFilterPickerAdapter(
    private val listener: Listener
) : ListAdapter<DateFilter, DateFilterPickerViewHolder>(BaseDiffUtil()) {

    // TODO: 11.02.2022 Investigate why we need to call `notifyDataSetChanged` manually
    //  https://stackoverflow.com/a/50031492
    override fun submitList(list: List<DateFilter>?) {
        super.submitList(list)
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): DateFilterPickerViewHolder {
        return DateFilterPickerViewHolder.create(parent).apply {
            itemView.setOnClickListener {
                if (bindingAdapterPosition != RecyclerView.NO_POSITION) {
                    val newSelectedDateFilter = getItem(bindingAdapterPosition)
                    if (newSelectedDateFilter is DateFilter.CustomRange) {
                        listener.onCustomRangeClick(newSelectedDateFilter)
                    } else {
                        listener.onDateFilterChanged(newSelectedDateFilter)
                    }
                }
            }
        }
    }

    override fun onBindViewHolder(holder: DateFilterPickerViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    interface Listener {
        fun onDateFilterChanged(dateFilter: DateFilter)
        fun onCustomRangeClick(customRange: DateFilter.CustomRange)
    }
}
