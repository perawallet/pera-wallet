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
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.ui.CurrencySelectionPreview
import com.algorand.android.ui.settings.selection.CurrencyListItem
import com.algorand.android.usecase.CurrencySelectionPreviewUseCase
import com.algorand.android.usecase.CurrencyUseCase
import com.algorand.android.utils.analytics.logCurrencyChange
import com.google.firebase.analytics.FirebaseAnalytics
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class CurrencySelectionViewModel @ViewModelInject constructor(
    private val firebaseAnalytics: FirebaseAnalytics,
    private val currencyUseCase: CurrencyUseCase,
    private val currencySelectionPreviewUseCase: CurrencySelectionPreviewUseCase
) : BaseViewModel() {

    val currencySelectionPreviewFlow: Flow<CurrencySelectionPreview?>
        get() = _currencySelectionPreviewFlow
    private val _currencySelectionPreviewFlow = MutableStateFlow<CurrencySelectionPreview?>(null)

    private var previewJob: Job? = null

    private var searchKeyword = ""

    init {
        initPreviewFlow()
    }

    private fun initPreviewFlow() {
        previewJob = getPreviewJob()
    }

    fun refreshPreview() {
        previewJob?.cancel()
        previewJob = getPreviewJob()
    }

    fun updateSearchKeyword(searchKeyword: String) {
        this.searchKeyword = searchKeyword
        refreshPreview()
    }

    private fun getPreviewJob(): Job {
        return viewModelScope.launch {
            currencySelectionPreviewUseCase.getCurrencySelectionPreviewFlow(searchKeyword).collectLatest {
                _currencySelectionPreviewFlow.value = it
            }
        }
    }

    fun setCurrencySelected(currencyListItem: CurrencyListItem) {
        currencyUseCase.setSelectedCurrency(currencyListItem.currencyId)
        logCurrencyChange(currencyListItem.currencyId)
    }

    private fun logCurrencyChange(newCurrencyId: String) {
        firebaseAnalytics.logCurrencyChange(newCurrencyId)
    }
}
