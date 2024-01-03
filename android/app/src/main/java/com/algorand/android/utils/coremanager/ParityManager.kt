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

import com.algorand.android.modules.currency.domain.usecase.CurrencyUseCase
import com.algorand.android.modules.parity.domain.model.SelectedCurrencyDetail
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.sharedpref.SharedPrefLocalSource
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
class ParityManager constructor(
    private val parityUseCase: ParityUseCase,
    private val currencyUseCase: CurrencyUseCase
) : BaseCacheManager() {

    private val currencyChangeListener = SharedPrefLocalSource.OnChangeListener<String> {
        handleCurrencyChange()
    }

    init {
        currencyUseCase.setPrimaryCurrencyChangeListener(currencyChangeListener)
        startJob()
    }

    override fun clearResources() {
        super.clearResources()
        currencyUseCase.removePrimaryCurrencyChangeListener(currencyChangeListener)
    }

    override suspend fun doJob(coroutineScope: CoroutineScope) {
        parityUseCase.getSelectedCurrencyDetailCacheFlow().collectLatest {
            when (it) {
                null -> fetchSelectedCurrencyDetail()
                is CacheResult.Success -> waitAndFetchSelectedCurrencyDetail(NEXT_FETCH_DELAY_AFTER_SUCCESS)
                is CacheResult.Error -> waitAndFetchSelectedCurrencyDetail(NEXT_FETCH_DELAY_AFTER_ERROR)
            }
        }
    }

    suspend fun refreshSelectedCurrencyDetailCache() {
        stopCurrentJob()
        fetchSelectedCurrencyDetail()
        startJob()
    }

    private suspend fun waitAndFetchSelectedCurrencyDetail(delayAsMillis: Long) {
        delay(delayAsMillis)
        fetchSelectedCurrencyDetail()
    }

    private suspend fun fetchSelectedCurrencyDetail() {
        parityUseCase.fetchSelectedCurrencyDetail().collect { dataResource ->
            dataResource.useSuspended(
                onSuccess = ::onSelectedCurrencyDetailResourceSuccess,
                onFailed = ::onSelectedCurrencyDetailDataResourceFailed
            )
        }
    }

    private fun handleCurrencyChange() {
        stopCurrentJob()
        parityUseCase.clearSelectedCurrencyDetailCache()
        startJob()
    }

    private fun onSelectedCurrencyDetailResourceSuccess(currencyWithValueValues: SelectedCurrencyDetail) {
        parityUseCase.cacheSelectedCurrencyDetail(CacheResult.Success.create(currencyWithValueValues))
    }

    private fun onSelectedCurrencyDetailDataResourceFailed(error: DataResource.Error<SelectedCurrencyDetail>) {
        val previousCachedData = parityUseCase.getCachedSelectedCurrencyDetail()
        parityUseCase.cacheSelectedCurrencyDetail(
            CacheResult.Error.create(
                error.exception,
                error.code,
                previousCachedData
            )
        )
    }

    companion object {
        private const val NEXT_FETCH_DELAY_AFTER_ERROR = 2500L
        private const val NEXT_FETCH_DELAY_AFTER_SUCCESS = 60_000L
    }
}
