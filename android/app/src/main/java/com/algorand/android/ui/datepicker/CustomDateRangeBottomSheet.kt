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
import android.widget.DatePicker
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetCustomDateRangeBinding
import com.algorand.android.models.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.ui.CustomDateRangePreview
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collect

@AndroidEntryPoint
class CustomDateRangeBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_custom_date_range, false) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.custom_range,
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_left_arrow
    )

    private val customDateRangePreviewFlowCollector: suspend (CustomDateRangePreview) -> Unit = { preview ->
        updateUiWithPreview(preview)
    }

    private val binding by viewBinding(BottomSheetCustomDateRangeBinding::bind)

    private val customDateRangeViewModel: CustomDateRangeViewModel by viewModels()

    private val onDateChangeListener = DatePicker.OnDateChangedListener { _, year, month, day ->
        customDateRangeViewModel.updateCustomRange(year, month, day)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        isCancelable = false
        setDraggableEnabled(isEnabled = false)
        initUi()
        initObservers()
    }

    private fun initUi() {
        configureToolbar()
        configureDatePicker()
        with(binding) {
            toolbar.addButtonToEnd(TextButton(stringResId = R.string.done, onClick = ::onDoneClick))
            fromTextView.setOnClickListener { customDateRangeViewModel.setIsFromFocused(true) }
            toTextView.setOnClickListener { customDateRangeViewModel.setIsFromFocused(false) }
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launchWhenResumed {
            customDateRangeViewModel.getCustomDateRangePreviewFlow().collect(customDateRangePreviewFlowCollector)
        }
    }

    private fun configureToolbar() {
        binding.toolbar.configure(toolbarConfiguration)
    }

    private fun configureDatePicker() {
        with(customDateRangeViewModel.getInitialZonedDateTime()) {
            binding.datePicker.init(year, monthValue, dayOfMonth, onDateChangeListener)
        }
    }

    private fun updateUiWithPreview(preview: CustomDateRangePreview) {
        with(binding) {
            with(preview) {
                fromTextView.text = formattedFromDate
                toTextView.text = formattedToDate
                datePicker.minDate = minDateInMillis
                datePicker.maxDate = maxDateInMillis
                datePicker.updateDate(focusedDateYear, focusedDateMonth, focusedDateDay)
                fromDividerView.isSelected = isFromFocused
                toDividerView.isSelected = isFromFocused.not()
            }
        }
    }

    private fun onDoneClick() {
        setNavigationResult(CUSTOM_DATE_FILTER_RESULT, customDateRangeViewModel.getCustomRange())
        navBack()
    }

    companion object {
        const val CUSTOM_DATE_FILTER_RESULT = "custom_date_filter_result"
    }
}
