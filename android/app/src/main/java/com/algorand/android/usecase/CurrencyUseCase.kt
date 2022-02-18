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

package com.algorand.android.usecase

import com.algorand.android.core.BaseUseCase
import com.algorand.android.repository.CurrencyRepository
import com.algorand.android.sharedpref.CurrencyLocalSource.Companion.defaultCurrencyPreference
import com.algorand.android.sharedpref.SharedPrefLocalSource
import javax.inject.Inject

class CurrencyUseCase @Inject constructor(
    private val currencyRepository: CurrencyRepository
) : BaseUseCase() {

    fun getSelectedCurrency(): String {
        return currencyRepository.getSelectedCurrencyPreference(defaultCurrencyPreference)
    }

    fun setSelectedCurrency(selectedCurrency: String) {
        currencyRepository.setSelectedCurrencyPreference(selectedCurrency)
    }

    fun setCurrencyChangeListener(listener: SharedPrefLocalSource.OnChangeListener<String>) {
        currencyRepository.setCurrencyChangeListener(listener)
    }

    fun removeCurrencyChangeListener(listener: SharedPrefLocalSource.OnChangeListener<String>) {
        currencyRepository.removeCurrencyChangeListener(listener)
    }
}
