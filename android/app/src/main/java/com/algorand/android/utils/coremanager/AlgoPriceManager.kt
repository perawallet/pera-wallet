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

package com.algorand.android.utils.coremanager

import com.algorand.android.models.CurrencyValue
import com.algorand.android.sharedpref.SharedPrefLocalSource
import com.algorand.android.usecase.AlgoPriceUseCase
import com.algorand.android.usecase.CurrencyUseCase
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.DataResource
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.collectLatest

/**
 * Helper class to manage Algo price by selected currency
 * Should be provided by Hilt as Singleton
 */
class AlgoPriceManager constructor(
    private val algoPriceUseCase: AlgoPriceUseCase,
    private val currencyUseCase: CurrencyUseCase
) : BaseCacheManager() {

    private val currencyChangeListener = SharedPrefLocalSource.OnChangeListener<String> {
        handleCurrencyChange()
    }

    init {
        currencyUseCase.setCurrencyChangeListener(currencyChangeListener)
        startJob()
    }

    override fun clearResources() {
        super.clearResources()
        currencyUseCase.removeCurrencyChangeListener(currencyChangeListener)
    }

    override suspend fun doJob(coroutineScope: CoroutineScope) {
        algoPriceUseCase.getAlgoPriceCacheFlow().collectLatest {
            when (it) {
                null -> fetchAlgoPrice()
                is CacheResult.Success -> waitAndFetchAlgoPrice(NEXT_FETCH_DELAY_AFTER_SUCCESS)
                is CacheResult.Error -> waitAndFetchAlgoPrice(NEXT_FETCH_DELAY_AFTER_ERROR)
            }
        }
    }

    suspend fun refreshAlgoPriceCache() {
        stopCurrentJob()
        fetchAlgoPrice()
        startJob()
    }

    private suspend fun waitAndFetchAlgoPrice(delayAsMillis: Long) {
        delay(delayAsMillis)
        fetchAlgoPrice()
    }

    private suspend fun fetchAlgoPrice() {
        algoPriceUseCase.fetchAlgoPrice().collect { dataResource ->
            dataResource.useSuspended(
                onSuccess = ::onAlgoPriceDataResourceSuccess,
                onFailed = ::onAlgoPriceDataResourceFailed
            )
        }
    }

    private fun handleCurrencyChange() {
        stopCurrentJob()
        algoPriceUseCase.clearAlgoPriceCache()
        startJob()
    }

    private fun onAlgoPriceDataResourceSuccess(currencyValue: CurrencyValue) {
        algoPriceUseCase.cacheAlgoPrice(CacheResult.Success.create(currencyValue))
    }

    private fun onAlgoPriceDataResourceFailed(error: DataResource.Error<CurrencyValue>) {
        val previousCachedData = algoPriceUseCase.getCachedAlgoPrice()
        algoPriceUseCase.cacheAlgoPrice(CacheResult.Error.create(error.exception, error.code, previousCachedData))
    }

    companion object {
        private const val NEXT_FETCH_DELAY_AFTER_ERROR = 2500L
        private const val NEXT_FETCH_DELAY_AFTER_SUCCESS = 60_000L
    }
}
