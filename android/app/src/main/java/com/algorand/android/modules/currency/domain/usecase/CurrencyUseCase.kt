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

package com.algorand.android.modules.currency.domain.usecase

import com.algorand.android.core.BaseUseCase
import com.algorand.android.modules.currency.data.local.CurrencyLocalSource.Companion.defaultCurrencyPreference
import com.algorand.android.modules.currency.domain.mapper.SelectedCurrencyMapper
import com.algorand.android.modules.currency.domain.model.Currency
import com.algorand.android.modules.currency.domain.model.SelectedCurrency
import com.algorand.android.modules.currency.domain.repository.CurrencyRepository
import com.algorand.android.sharedpref.SharedPrefLocalSource
import javax.inject.Inject
import javax.inject.Named

class CurrencyUseCase @Inject constructor(
    @Named(CurrencyRepository.INJECTION_NAME)
    private val currencyRepository: CurrencyRepository,
    private val selectedCurrencyMapper: SelectedCurrencyMapper
) : BaseUseCase() {

    fun getSelectedCurrency(): SelectedCurrency {
        val selectedCurrencyPreferenceId = currencyRepository.getPrimaryCurrencyPreference(defaultCurrencyPreference)
        val secondaryCurrencyId = getSecondaryCurrency().id
        return selectedCurrencyMapper.mapToSelectedCurrency(
            primaryCurrencyId = selectedCurrencyPreferenceId,
            secondaryCurrencyId = secondaryCurrencyId
        )
    }

    fun getPrimaryCurrencyId(): String {
        return currencyRepository.getPrimaryCurrencyPreference(defaultCurrencyPreference)
    }

    fun setPrimaryCurrency(selectedCurrency: String) {
        currencyRepository.setPrimaryCurrencyPreference(selectedCurrency)
    }

    fun setPrimaryCurrencyChangeListener(listener: SharedPrefLocalSource.OnChangeListener<String>) {
        currencyRepository.setPrimaryCurrencyChangeListener(listener)
    }

    fun removePrimaryCurrencyChangeListener(listener: SharedPrefLocalSource.OnChangeListener<String>) {
        currencyRepository.removePrimaryCurrencyChangeListener(listener)
    }

    fun isPrimaryCurrencyAlgo(): Boolean {
        return getPrimaryCurrencyId() == Currency.ALGO.id
    }

    // If Primary currency;
    //  is Algo -> App always display the $ as secondary currency.
    //  is other than Algo -> App always display Algo as secondary currency
    private fun getSecondaryCurrency(): Currency {
        return if (isPrimaryCurrencyAlgo()) {
            Currency.USD
        } else {
            Currency.ALGO
        }
    }
}
