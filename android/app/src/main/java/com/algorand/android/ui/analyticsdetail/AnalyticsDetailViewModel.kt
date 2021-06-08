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

package com.algorand.android.ui.analyticsdetail

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Transformations
import androidx.lifecycle.asLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.AssetPriceHistory
import com.algorand.android.models.ChartEntryData
import com.algorand.android.models.ChartInterval
import com.algorand.android.models.ChartInterval.FiveMinInterval
import com.algorand.android.models.CurrencyValue
import com.algorand.android.models.Result
import com.algorand.android.repository.PriceRepository
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Resource
import com.algorand.android.utils.awaitOrdered
import com.algorand.android.utils.createChartEntryList
import com.algorand.android.utils.formatAsDollar
import com.algorand.android.utils.getAlgoBalanceAsCurrencyValue
import com.algorand.android.utils.getCurrencyConvertedHistoryList
import java.math.BigDecimal
import java.math.BigInteger
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.async
import kotlinx.coroutines.launch

class AnalyticsDetailViewModel @ViewModelInject constructor(
    private val priceRepository: PriceRepository,
    private val accountCacheManager: AccountCacheManager
) : BaseViewModel() {

    val algoPriceHistoryLiveData = MutableLiveData<Resource<ChartEntryData>>()
    private var getAlgoPriceHistory: Job? = null

    var balanceLiveData: LiveData<BigInteger?>? = null
        private set

    var balanceInSelectedCurrencyValueLiveData: LiveData<String>? = null
        private set

    fun setupBalanceAndDollarValue(currencyValue: CurrencyValue, address: String) {
        setupBalanceLiveData(address)
        setupBalanceInUsd(currencyValue)
    }

    fun getAlgoPriceHistory(selectedCurrencyValueOfPerAlgo: BigDecimal, selectedInterval: ChartInterval) {
        if (getAlgoPriceHistory?.isActive == true) {
            getAlgoPriceHistory?.cancel()
        }
        getAlgoPriceHistory = launchGetAlgoPriceHistory(selectedCurrencyValueOfPerAlgo, selectedInterval)
    }

    private fun setupBalanceLiveData(address: String) {
        balanceLiveData = accountCacheManager.getBalanceFlow(address, ALGORAND_ID).asLiveData()
    }

    private fun setupBalanceInUsd(currencyValue: CurrencyValue) {
        balanceLiveData?.run {
            balanceInSelectedCurrencyValueLiveData = Transformations.map(this) { balance ->
                val valueInCurrency = getAlgoBalanceAsCurrencyValue(balance, currencyValue)
                valueInCurrency?.formatAsDollar().orEmpty()
            }
        }
    }

    private fun launchGetAlgoPriceHistory(
        selectedCurrencyValueOfPerAlgo: BigDecimal,
        selectedInterval: ChartInterval
    ): Job {
        algoPriceHistoryLiveData.postValue(Resource.Loading)
        return viewModelScope.launch(Dispatchers.IO) {
            val resultList = awaitOrdered(
                async { priceRepository.getAlgoPriceHistoryByTimeFrame(selectedInterval) },
                async { priceRepository.getAlgoPriceHistoryByTimeFrame(FiveMinInterval.getDefaultInstance()) }
            )
            algoPriceHistoryLiveData.postValue(getAlgoPriceHistoryResource(selectedCurrencyValueOfPerAlgo, resultList))
        }
    }

    private suspend fun getAlgoPriceHistoryResource(
        selectedCurrencyValueOfPerAlgo: BigDecimal,
        resultList: List<Result<AssetPriceHistory>>
    ): Resource<ChartEntryData> {
        val usdSelectedIntervalHistory = (resultList.firstOrNull() as? Result.Success)?.data?.candleHistory
        val usdLastFiveMinInterval = (resultList.lastOrNull() as? Result.Success)?.data?.candleHistory?.lastOrNull()
        if (usdSelectedIntervalHistory.isNullOrEmpty() || usdLastFiveMinInterval == null) {
            return Resource.Error.Api(IllegalArgumentException())
        }

        val currencyConvertedHistoryList = getCurrencyConvertedHistoryList(
            selectedCurrencyValueOfPerAlgo,
            usdSelectedIntervalHistory,
            usdLastFiveMinInterval
        )
        val chartEntryData = ChartEntryData.create(createChartEntryList(currencyConvertedHistoryList))
        return Resource.Success(chartEntryData)
    }
}
