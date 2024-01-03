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

package com.algorand.android.modules.parity.data.repository

import com.algorand.android.cache.SelectedCurrencyDetailSingleLocalCache
import com.algorand.android.models.Result
import com.algorand.android.modules.parity.data.mapper.CurrencyDetailDTOMapper
import com.algorand.android.modules.parity.domain.model.CurrencyDetailDTO
import com.algorand.android.modules.parity.domain.model.SelectedCurrencyDetail
import com.algorand.android.modules.parity.domain.repository.ParityRepository
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.algorand.android.utils.CacheResult
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import kotlinx.coroutines.flow.StateFlow

class ParityRepositoryImpl(
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val hipoApiErrorHandler: RetrofitErrorHandler,
    private val selectedCurrencyDetailSingleLocalCache: SelectedCurrencyDetailSingleLocalCache,
    private val currencyDetailDTOMapper: CurrencyDetailDTOMapper
) : ParityRepository {

    override fun cacheSelectedCurrencyDetail(
        selectedCurrencyDetail: CacheResult<SelectedCurrencyDetail>
    ) {
        selectedCurrencyDetailSingleLocalCache.put(selectedCurrencyDetail)
    }

    override fun clearSelectedCurrencyDetailCache() {
        selectedCurrencyDetailSingleLocalCache.clear()
    }

    override fun getCachedSelectedCurrencyDetail(): CacheResult<SelectedCurrencyDetail>? {
        return selectedCurrencyDetailSingleLocalCache.getOrNull()
    }

    override fun getSelectedCurrencyDetailCacheFlow(): StateFlow<CacheResult<SelectedCurrencyDetail>?> {
        return selectedCurrencyDetailSingleLocalCache.cacheFlow
    }

    override suspend fun fetchCurrencyDetailDTO(
        currencyPreference: String
    ): Result<CurrencyDetailDTO> {
        return requestWithHipoErrorHandler(hipoApiErrorHandler) {
            mobileAlgorandApi.getCurrencyDetail(currencyPreference)
        }.map { response ->
            currencyDetailDTOMapper.mapToCurrencyDetailDTO(response)
        }
    }
}
