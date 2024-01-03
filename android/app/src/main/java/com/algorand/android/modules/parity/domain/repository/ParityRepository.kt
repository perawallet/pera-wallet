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

package com.algorand.android.modules.parity.domain.repository

import com.algorand.android.models.Result
import com.algorand.android.modules.parity.domain.model.CurrencyDetailDTO
import com.algorand.android.modules.parity.domain.model.SelectedCurrencyDetail
import com.algorand.android.utils.CacheResult
import kotlinx.coroutines.flow.StateFlow

interface ParityRepository {
    fun cacheSelectedCurrencyDetail(selectedCurrencyDetail: CacheResult<SelectedCurrencyDetail>)
    fun clearSelectedCurrencyDetailCache()
    fun getCachedSelectedCurrencyDetail(): CacheResult<SelectedCurrencyDetail>?
    fun getSelectedCurrencyDetailCacheFlow(): StateFlow<CacheResult<SelectedCurrencyDetail>?>
    suspend fun fetchCurrencyDetailDTO(currencyPreference: String): Result<CurrencyDetailDTO>

    companion object {
        const val INJECTION_NAME = "parityRepositoryInjectionName"
    }
}
