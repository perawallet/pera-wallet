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

package com.algorand.android.ui.accounts

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.ui.AccountPreview
import com.algorand.android.usecase.AccountsPreviewUseCase
import com.algorand.android.usecase.PeraIntroductionUseCase
import com.algorand.android.utils.coremanager.AlgoPriceManager
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class AccountsViewModel @ViewModelInject constructor(
    private val accountsPreviewUseCase: AccountsPreviewUseCase,
    private val peraIntroductionUseCase: PeraIntroductionUseCase,
    private val algoPriceManager: AlgoPriceManager
) : BaseViewModel() {

    private val _accountPreviewFlow = MutableStateFlow(accountsPreviewUseCase.getInitialAccountPreview())
    val accountPreviewFlow: Flow<AccountPreview>
        get() = _accountPreviewFlow

    init {
        initializeAccountPreviewFlow()
    }

    fun shouldShowPeraIntroductionFragment(): Boolean {
        return peraIntroductionUseCase.shouldShowPeraIntroduction()
    }

    fun refreshCachedAlgoPrice() {
        viewModelScope.launch {
            algoPriceManager.refreshAlgoPriceCache()
        }
    }

    private fun initializeAccountPreviewFlow() {
        viewModelScope.launch {
            accountsPreviewUseCase.getAccountsPreview(_accountPreviewFlow.value).collectLatest {
                _accountPreviewFlow.emit(it)
            }
        }
    }
}
