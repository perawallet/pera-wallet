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

package com.algorand.android.ui.settings.selection.currencyselection

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.repository.PriceRepository
import com.algorand.android.ui.settings.selection.CurrencyListItem
import com.algorand.android.usecase.CurrencyUseCase
import com.algorand.android.utils.Resource
import com.algorand.android.utils.analytics.logCurrencyChange
import com.google.firebase.analytics.FirebaseAnalytics
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch

class CurrencySelectionViewModel @ViewModelInject constructor(
    private val firebaseAnalytics: FirebaseAnalytics,
    private val priceRepository: PriceRepository,
    private val currencyUseCase: CurrencyUseCase
) : BaseViewModel() {

    val currencyListLiveData = MutableLiveData<Resource<List<CurrencyListItem>>>()

    private var getCurrenciesJob: Job? = null

    init {
        getCurrencyList()
    }

    fun getCurrencyList() {
        if (getCurrenciesJob?.isActive == true) {
            return
        }
        getCurrenciesJob = viewModelScope.launch(Dispatchers.IO) {
            priceRepository.getCurrencies().use(
                onSuccess = { fetchedList ->
                    val currencyListItem = fetchedList.map { fetchedCurrencyItem ->
                        fetchedCurrencyItem.toCurrentListItem(selectedCurrencyId = getSelectedCurrencyId())
                    }
                    currencyListLiveData.postValue(Resource.Success(currencyListItem))
                },
                onFailed = { exception, _ ->
                    currencyListLiveData.postValue(Resource.Error.Api(exception))
                }
            )
        }
    }

    private fun getSelectedCurrencyId() = currencyUseCase.getSelectedCurrency()

    fun setCurrencySelected(currencyListItem: CurrencyListItem) {
        currencyUseCase.setSelectedCurrency(currencyListItem.currencyId)
        logCurrencyChange(currencyListItem.currencyId)
    }

    private fun logCurrencyChange(newCurrencyId: String) {
        firebaseAnalytics.logCurrencyChange(newCurrencyId)
    }
}
