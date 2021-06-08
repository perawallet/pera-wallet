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

import android.content.res.ColorStateList
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.core.widget.ImageViewCompat
import androidx.recyclerview.widget.RecyclerView
import com.algorand.android.R
import com.algorand.android.databinding.ItemDateFilterPickerBinding
import com.algorand.android.models.DateFilter

class DateFilterPickerViewHolder(
    private val binding: ItemDateFilterPickerBinding
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(dateFilter: DateFilter, isSelected: Boolean) {
        binding.iconImageView.setImageResource(dateFilter.iconResId)
        binding.dateTextView.setText(dateFilter.titleResId)
        val dateRange = dateFilter.getDateRange()
        when (dateFilter) {
            DateFilter.Today -> {
                binding.dateInIconTextView.text = dateRange?.from?.dayOfMonth.toString()
                binding.dateInIconTextView.visibility = View.VISIBLE
            }
            DateFilter.LastMonth -> {
                binding.dateInIconTextView.text = dateRange?.to?.dayOfMonth.toString()
                binding.dateInIconTextView.visibility = View.VISIBLE
            }
            else -> {
                binding.dateInIconTextView.visibility = View.GONE
            }
        }
        val rangeAsText = dateRange?.getRangeAsText(dateFilter)
        binding.dateRangeTextView.apply {
            isVisible = rangeAsText.isNullOrBlank().not()
            text = rangeAsText
        }
        bindSelected(isSelected)
    }

    fun bindSelected(isSelected: Boolean) {
        binding.selectedImageView.isVisible = isSelected

        val titleTextColor =
            ContextCompat.getColor(itemView.context, if (isSelected) R.color.green_0D else R.color.primaryTextColor)

        binding.dateTextView.setTextColor(titleTextColor)

        val iconTintColor =
            ContextCompat.getColor(itemView.context, if (isSelected) R.color.green_0D else R.color.gray_8A)

        binding.dateInIconTextView.setTextColor(iconTintColor)
        ImageViewCompat.setImageTintList(binding.iconImageView, ColorStateList.valueOf(iconTintColor))
    }

    companion object {
        fun create(parent: ViewGroup): DateFilterPickerViewHolder {
            val binding = ItemDateFilterPickerBinding.inflate(LayoutInflater.from(parent.context), parent, false)
            return DateFilterPickerViewHolder(binding)
        }
    }
}
