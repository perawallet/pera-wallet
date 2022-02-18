/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.usecase

import com.algorand.android.models.DateFilter
import javax.inject.Inject

class DateFilterListUseCase @Inject constructor() {

    fun getDateFilterListPreview(dateFilter: DateFilter?, dateFilterList: MutableList<DateFilter>): List<DateFilter> {
        val customDate = dateFilter.takeIf { it is DateFilter.CustomRange }
        if (customDate != null) {
            // Custom Date Range is keeping last index of list
            dateFilterList[dateFilterList.size - 1] = customDate
        }
        return dateFilterList.onEach { it.isSelected = it == dateFilter }
    }
}
