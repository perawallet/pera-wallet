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

import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.DateFilter.CustomRange
import com.algorand.android.models.ui.CustomDateRangePreview
import com.algorand.android.usecase.CustomDateRangeUseCase
import com.algorand.android.utils.getOrElse
import java.time.ZonedDateTime
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.launch

class CustomDateRangeViewModel @ViewModelInject constructor(
    @Assisted savedStateHandle: SavedStateHandle,
    private val customDateRangeUseCase: CustomDateRangeUseCase
) : BaseViewModel() {

    private val initialCustomRange = savedStateHandle.getOrElse(
        CUSTOM_RANGE_KEY,
        customDateRangeUseCase.getDefaultCustomRange()
    )

    private val _customDateRangeFlow = MutableStateFlow(initialCustomRange)
    private val _isFromFocusedFlow = MutableStateFlow(true)

    fun getInitialZonedDateTime(): ZonedDateTime {
        return initialCustomRange.customDateRange?.from ?: throw Exception("Initial zoned date time cannot be null")
    }

    fun getCustomRange(): CustomRange {
        return _customDateRangeFlow.value
    }

    fun setIsFromFocused(isFromFocused: Boolean) {
        viewModelScope.launch {
            _isFromFocusedFlow.emit(isFromFocused)
        }
    }

    fun updateCustomRange(datePickerYear: Int, datePickerMonth: Int, datePickerDay: Int) {
        viewModelScope.launch {
            val customRange = customDateRangeUseCase.createUpdatedCustomRange(
                customRange = _customDateRangeFlow.value,
                isFromFocused = _isFromFocusedFlow.value,
                datePickerYear = datePickerYear,
                datePickerMonth = datePickerMonth,
                datePickerDay = datePickerDay,
            )
            _customDateRangeFlow.emit(customRange)
        }
    }

    fun getCustomDateRangePreviewFlow(): Flow<CustomDateRangePreview> {
        return combine(_customDateRangeFlow, _isFromFocusedFlow) { customRange, isFromFocused ->
            createCustomDateRangePreview(customRange, isFromFocused)
        }
    }

    private fun createCustomDateRangePreview(
        latestCustomRange: CustomRange,
        isFromFocused: Boolean
    ): CustomDateRangePreview {
        return customDateRangeUseCase.createCustomDateRangePreview(
            latestDateRange = latestCustomRange.customDateRange,
            isFromFocused = isFromFocused
        )
    }

    companion object {
        private const val CUSTOM_RANGE_KEY = "customRange"
    }
}
