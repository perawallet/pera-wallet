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

package com.algorand.android.repository

import android.content.SharedPreferences
import com.algorand.android.cache.AlgoPriceSingleLocalCache
import com.algorand.android.models.ChartInterval
import com.algorand.android.models.CurrencyValue
import com.algorand.android.network.AlgodExplorerPriceApi
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.algorand.android.utils.CacheResult
import com.algorand.android.utils.preference.getCurrencyPreference
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.withContext

class PriceRepository @Inject constructor(
    private val sharedPref: SharedPreferences,
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val hipoApiErrorHandler: RetrofitErrorHandler,
    private val algodExplorerPriceApi: AlgodExplorerPriceApi,
    private val algoPriceLocalCache: AlgoPriceSingleLocalCache
) {

    fun cacheAlgoPrice(currencyValue: CacheResult<CurrencyValue>) {
        algoPriceLocalCache.put(currencyValue)
    }

    fun clearAlgoPriceCache() {
        algoPriceLocalCache.clear()
    }

    fun getCachedAlgoPrice(): CacheResult<CurrencyValue>? {
        return algoPriceLocalCache.getOrNull()
    }

    fun getAlgoPriceCacheFlow(): StateFlow<CacheResult<CurrencyValue>?> = algoPriceLocalCache.cacheFlow

    suspend fun getCurrencies() = requestWithHipoErrorHandler(hipoApiErrorHandler) {
        mobileAlgorandApi.getCurrencies()
    }

    suspend fun getAlgorandCurrencyValue(currencyPreference: String? = null) =
        requestWithHipoErrorHandler(hipoApiErrorHandler) {
            mobileAlgorandApi.getAlgorandCurrenyValue(currencyPreference ?: sharedPref.getCurrencyPreference())
        }

    suspend fun getAlgoPriceHistoryByTimeFrame(chartInterval: ChartInterval) = withContext(Dispatchers.IO) {
        requestWithHipoErrorHandler(hipoApiErrorHandler) {
            with(chartInterval) {
                algodExplorerPriceApi.getAlgoUsdPriceHistoryByTimeFrame(sinceAsSec, untilAsSec, intervalQueryParam)
            }
        }
    }
}
