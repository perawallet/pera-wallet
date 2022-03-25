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

import com.algorand.android.core.BaseUseCase
import com.algorand.android.models.AssetPriceHistory
import com.algorand.android.models.ChartEntryData
import com.algorand.android.models.ChartInterval
import com.algorand.android.models.Result
import com.algorand.android.repository.PriceRepository
import com.algorand.android.utils.Resource
import com.algorand.android.utils.awaitOrdered
import com.algorand.android.utils.createChartEntryList
import com.algorand.android.utils.getCurrencyConvertedHistoryList
import java.math.BigDecimal
import java.math.BigDecimal.ZERO
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.map

class AnalyticsDetailUseCase @Inject constructor(
    private val priceRepository: PriceRepository,
    private val algoPriceUseCase: AlgoPriceUseCase,
) : BaseUseCase() {

    fun getAlgoExchangeValueFlow(): Flow<BigDecimal> {
        return algoPriceUseCase.getAlgoPriceCacheFlow()
            .map { algoPriceUseCase.getAlgoToCachedCurrencyConversionRate() ?: ZERO }
    }

    suspend fun getAlgoPriceHistory(
        cachedCurrencyValueOfPerAlgo: BigDecimal,
        selectedInterval: ChartInterval,
        coroutineScope: CoroutineScope
    ) = flow {
        emit(Resource.Loading)
        val resultList = awaitOrdered(
            coroutineScope.async { priceRepository.getAlgoPriceHistoryByTimeFrame(selectedInterval) },
            coroutineScope.async {
                priceRepository.getAlgoPriceHistoryByTimeFrame(ChartInterval.FiveMinInterval.getDefaultInstance())
            }
        )
        emit(getAlgoPriceHistoryResource(cachedCurrencyValueOfPerAlgo, resultList))
    }

    private suspend fun getAlgoPriceHistoryResource(
        cachedCurrencyValueOfPerAlgo: BigDecimal,
        resultList: List<Result<AssetPriceHistory>>
    ): Resource<ChartEntryData> {
        val usdSelectedIntervalHistory = (resultList.firstOrNull() as? Result.Success)?.data?.candleHistory
        val usdLastFiveMinInterval = (resultList.lastOrNull() as? Result.Success)?.data?.candleHistory?.lastOrNull()
        if (usdSelectedIntervalHistory.isNullOrEmpty() || usdLastFiveMinInterval == null) {
            return Resource.Error.Api(IllegalArgumentException())
        }

        val currencyConvertedHistoryList = getCurrencyConvertedHistoryList(
            cachedCurrencyValueOfPerAlgo,
            usdSelectedIntervalHistory,
            usdLastFiveMinInterval
        )
        val chartEntryData = ChartEntryData.create(createChartEntryList(currencyConvertedHistoryList))
        return Resource.Success(chartEntryData)
    }

    fun getSelectedCurrencyId(): String {
        return algoPriceUseCase.getCachedCurrencyId()
    }
}
