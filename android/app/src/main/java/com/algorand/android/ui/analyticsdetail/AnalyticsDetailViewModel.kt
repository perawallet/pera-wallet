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

package com.algorand.android.ui.analyticsdetail

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.ChartEntryData
import com.algorand.android.models.ChartInterval
import com.algorand.android.models.ChartTimeFrame
import com.algorand.android.usecase.AnalyticsDetailUseCase
import com.algorand.android.usecase.CurrencyUseCase
import com.algorand.android.utils.Resource
import java.math.BigDecimal
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.launch

// TODO Refactor AnalyticsDetailViewModel line by line and update it based on new architecture
class AnalyticsDetailViewModel @ViewModelInject constructor(
    private val currencyUseCase: CurrencyUseCase,
    private val analyticsDetailUseCase: AnalyticsDetailUseCase
) : BaseViewModel() {

    private val algoPriceHistoryCollector: suspend (value: Resource<ChartEntryData>) -> Unit = {
        _algoPriceHistoryFlow.emit(it)
    }

    private val currencyTimeFrameCollector: suspend (ChartTimeFrame, BigDecimal) -> Unit = { timeFrame, exchangePrice ->
        getAlgoPriceHistory(timeFrame.interval, exchangePrice)
    }
    private val selectedTimeFrameFlow = MutableStateFlow<ChartTimeFrame>(ChartTimeFrame.DEFAULT_TIME_FRAME)

    private val _algoPriceHistoryFlow = MutableStateFlow<Resource<ChartEntryData>>(Resource.Loading)
    val algoPriceHistoryFlow: StateFlow<Resource<ChartEntryData>> = _algoPriceHistoryFlow

    init {
        selectedTimeFrameFlow
            .combine(analyticsDetailUseCase.getAlgoExchangeValueFlow(), currencyTimeFrameCollector)
            .launchIn(viewModelScope)
    }

    fun updateSelectedTimeFrame(chartTimeFrame: ChartTimeFrame) {
        viewModelScope.launch {
            selectedTimeFrameFlow.emit(chartTimeFrame)
        }
    }

    fun getCurrencyFormattedPrice(price: String): String {
        return "$price ${currencyUseCase.getSelectedCurrency()}"
    }

    private fun getAlgoPriceHistory(selectedInterval: ChartInterval, currentAlgoPrice: BigDecimal) {
        viewModelScope.launch(Dispatchers.IO) {
            analyticsDetailUseCase.getAlgoPriceHistory(
                currentAlgoPrice,
                selectedInterval,
                this
            ).collectLatest(algoPriceHistoryCollector)
        }
    }
}
