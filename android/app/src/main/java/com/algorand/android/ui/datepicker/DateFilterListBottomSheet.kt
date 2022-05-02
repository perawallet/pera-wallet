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

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetDateFilterListBinding
import com.algorand.android.models.DateFilter
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class DateFilterListBottomSheet : DaggerBaseBottomSheet(R.layout.bottom_sheet_date_filter_list, false, null) {

    private val toolbarConfiguration = ToolbarConfiguration(R.string.filter_by_date)

    private val dateFilterListViewModel: DateFilterListViewModel by viewModels()

    private val binding by viewBinding(BottomSheetDateFilterListBinding::bind)

    private val dateFilterPickerListener = object : DateFilterPickerAdapter.Listener {
        override fun onDateFilterChanged(dateFilter: DateFilter) {
            dateFilterListViewModel.updateSelectedDate(dateFilter)
            setNavigationResult(DATE_FILTER_RESULT, dateFilter)
        }

        override fun onCustomRangeClick(customRange: DateFilter.CustomRange) {
            nav(
                DateFilterListBottomSheetDirections.actionDateFilterPickerBottomSheetToCustomDateRangeBottomSheet(
                    customRange.takeIf { it.customDateRange != null }
                )
            )
        }
    }

    private val dateFilterPickerAdapter: DateFilterPickerAdapter = DateFilterPickerAdapter(dateFilterPickerListener)

    private val dateFilterListObserver = Observer<List<DateFilter>> {
        dateFilterPickerAdapter.submitList(it)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            toolbar.configure(toolbarConfiguration)
            closeButton.setOnClickListener { navBack() }
            filtersRecyclerView.adapter = dateFilterPickerAdapter
        }
    }

    private fun initObservers() {
        dateFilterListViewModel.dateFilterListLiveData.observe(viewLifecycleOwner, dateFilterListObserver)
    }

    override fun onResume() {
        super.onResume()
        initSavedStateListener()
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.dateFilterPickerBottomSheet) {
            useSavedStateValue<DateFilter>(CustomDateRangeBottomSheet.CUSTOM_DATE_FILTER_RESULT) { newDateFilter ->
                setNavigationResult(DATE_FILTER_RESULT, newDateFilter)
                navBack()
            }
        }
    }

    companion object {
        const val DATE_FILTER_RESULT = "date_filter_result"
    }
}
