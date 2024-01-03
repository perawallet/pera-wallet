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

package com.algorand.android.modules.rekey.rekeytostandardaccount.accountselection.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.basesingleaccountselection.ui.BaseSingleAccountSelectionViewModel
import com.algorand.android.modules.rekey.rekeytostandardaccount.accountselection.ui.model.RekeyToStandardAccountSelectionPreview
import com.algorand.android.modules.rekey.rekeytostandardaccount.accountselection.ui.usecase.RekeyToStandardAccountSelectionPreviewUseCase
import com.algorand.android.utils.getOrThrow
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest

@HiltViewModel
class RekeyToStandardAccountSelectionViewModel @Inject constructor(
    private val rekeyToStandardAccountSelectionPreviewUseCase: RekeyToStandardAccountSelectionPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseSingleAccountSelectionViewModel() {

    val accountAddress = savedStateHandle.getOrThrow<String>(ACCOUNT_ADDRESS_KEY)

    override val singleAccountSelectionFieldsFlow: StateFlow<RekeyToStandardAccountSelectionPreview>
        get() = rekeyToAccountSingleAccountSelectionPreview
    private val rekeyToAccountSingleAccountSelectionPreview = MutableStateFlow(getInitialPreview())

    init {
        initPreviewFlow()
    }

    private fun initPreviewFlow() {
        viewModelScope.launchIO {
            rekeyToStandardAccountSelectionPreviewUseCase.getRekeyToAccountSingleAccountSelectionPreviewFlow(
                accountAddress = accountAddress
            ).collectLatest { preview ->
                rekeyToAccountSingleAccountSelectionPreview.emit(preview)
            }
        }
    }

    private fun getInitialPreview(): RekeyToStandardAccountSelectionPreview {
        return rekeyToStandardAccountSelectionPreviewUseCase
            .getInitialRekeyToAccountSingleAccountSelectionPreview()
    }

    companion object {
        private const val ACCOUNT_ADDRESS_KEY = "accountAddress"
    }
}
