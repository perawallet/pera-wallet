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

import com.algorand.android.sharedpref.CurrencyLocalSource
import com.algorand.android.sharedpref.SharedPrefLocalSource
import javax.inject.Inject

class CurrencyRepository @Inject constructor(
    private val currencyLocalSource: CurrencyLocalSource
) {

    fun setCurrencyChangeListener(listener: SharedPrefLocalSource.OnChangeListener<String>) {
        currencyLocalSource.addListener(listener)
    }

    fun removeCurrencyChangeListener(listener: SharedPrefLocalSource.OnChangeListener<String>) {
        currencyLocalSource.removeListener(listener)
    }

    fun getSelectedCurrencyPreference(defaultValue: String): String {
        return currencyLocalSource.getData(defaultValue)
    }

    fun setSelectedCurrencyPreference(currencyPreference: String) {
        currencyLocalSource.saveData(currencyPreference)
    }
}
