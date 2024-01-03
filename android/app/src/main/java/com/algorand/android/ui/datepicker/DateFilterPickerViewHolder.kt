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

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.core.view.isVisible
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.databinding.ItemDateFilterPickerBinding
import com.algorand.android.models.DateFilter
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show

class DateFilterPickerViewHolder(
    private val binding: ItemDateFilterPickerBinding
) : RecyclerView.ViewHolder(binding.root) {

    // TODO: 11.02.2022 Move these logics into domain layer 
    fun bind(dateFilter: DateFilter) {
        with(binding) {
            with(dateFilter) {
                selectedImageView.isVisible = isSelected
                iconImageView.setImageResource(iconResId)
                dateTextView.setText(titleResId)

                val dateRange = getDateRange()
                when (this) {
                    DateFilter.Today -> {
                        dateInIconTextView.text = dateRange?.from?.dayOfMonth.toString()
                        dateInIconTextView.show()
                    }
                    DateFilter.LastMonth -> {
                        dateInIconTextView.text = dateRange?.to?.dayOfMonth.toString()
                        dateInIconTextView.show()
                    }
                    else -> dateInIconTextView.hide()
                }
                val rangeAsText = dateRange?.getRangeAsText(this)
                dateRangeTextView.apply {
                    isVisible = rangeAsText.isNullOrBlank().not()
                    text = rangeAsText
                }
            }
        }
    }

    companion object {
        fun create(parent: ViewGroup): DateFilterPickerViewHolder {
            val binding = ItemDateFilterPickerBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return DateFilterPickerViewHolder(binding)
        }
    }
}
