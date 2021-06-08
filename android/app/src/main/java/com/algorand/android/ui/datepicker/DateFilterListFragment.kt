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

import android.content.Context
import android.os.Bundle
import android.util.TypedValue
import android.view.View
import androidx.annotation.AttrRes
import androidx.core.util.Pair
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.FragmentDateFilterListBinding
import com.algorand.android.models.DateFilter
import com.algorand.android.models.DateRange
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.showWithStateCheck
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.datepicker.CalendarConstraints
import com.google.android.material.datepicker.MaterialDatePicker
import java.time.Instant
import java.time.LocalTime
import java.time.ZoneOffset
import java.time.ZonedDateTime

class DateFilterListFragment : BaseBottomSheet(R.layout.fragment_date_filter_list), DateFilterPickerAdapter.Listener {

    private var materialDatePicker: MaterialDatePicker<Pair<Long, Long>>? = null
    private val toolbarConfiguration = ToolbarConfiguration(R.string.sort_by_date)
    private var selectedDateFilter: DateFilter = DateFilter.AllTime
    private var dateFilterPickerAdapter: DateFilterPickerAdapter? = null

    private val args: DateFilterListFragmentArgs by navArgs()

    private val binding by viewBinding(FragmentDateFilterListBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        selectedDateFilter = args.selectedDateFilter
        binding.toolbar.configure(toolbarConfiguration)
        setupRecyclerView(selectedDateFilter)
        binding.closeButton.setOnClickListener { findNavController().navigateUp() }
    }

    private fun setupRecyclerView(dateFilter: DateFilter) {
        dateFilterPickerAdapter = DateFilterPickerAdapter(
            listener = this,
            selectedDateFilter = dateFilter,
            customRange = if (dateFilter is DateFilter.CustomRange) dateFilter else DateFilter.CustomRange()
        )

        binding.filtersRecyclerView.adapter = dateFilterPickerAdapter
    }

    private fun resolveAttributeResId(context: Context?, @AttrRes attributeResId: Int): Int? {
        val typedValue = TypedValue()
        if (context?.theme?.resolveAttribute(attributeResId, typedValue, true) == true) {
            return typedValue.data
        }
        return null
    }

    override fun onDateFilterChanged(dateFilter: DateFilter) {
        selectedDateFilter = dateFilter
        setNavigationResult(DATE_FILTER_RESULT, selectedDateFilter)
    }

    override fun onCustomRangeClick(customRange: DateFilter.CustomRange) {
        if (materialDatePicker == null) {
            val calendarConstraints = CalendarConstraints.Builder().setValidator(DatePickerValidator()).build()

            materialDatePicker = MaterialDatePicker.Builder
                .dateRangePicker()
                .setCalendarConstraints(calendarConstraints)
                .setTheme(R.style.CustomMaterialCalendar)
                .build().apply {
                    addOnPositiveButtonClickListener { selection ->
                        onNewCustomRangeSelected(selection.first, selection.second)
                    }
                    addOnCancelListener { navBack() }
                }
        }
        if (materialDatePicker?.isAdded == false) {
            materialDatePicker?.showWithStateCheck(childFragmentManager)
        }
    }

    private fun onNewCustomRangeSelected(from: Long?, to: Long?) {
        if (from != null && to != null) {
            val fromZonedDateTime = ZonedDateTime
                .ofInstant(Instant.ofEpochMilli(from), ZoneOffset.UTC)
                .with(LocalTime.MIN)

            val toZonedDateFilter = ZonedDateTime
                .ofInstant(Instant.ofEpochMilli(to), ZoneOffset.UTC)
                .with(LocalTime.MAX)

            selectedDateFilter = DateFilter.CustomRange(DateRange(fromZonedDateTime, toZonedDateFilter)).also {
                dateFilterPickerAdapter?.newCustomRangeSelected(it)
            }
            setNavigationResult(DATE_FILTER_RESULT, selectedDateFilter)
        }
    }

    companion object {
        private const val DATE_PICKER_TAG = "date_picker_tag"

        const val DATE_FILTER_RESULT = "date_filter_result"
    }
}
