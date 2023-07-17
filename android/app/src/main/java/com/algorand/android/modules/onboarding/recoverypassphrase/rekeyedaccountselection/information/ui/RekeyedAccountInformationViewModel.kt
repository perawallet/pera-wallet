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

package com.algorand.android.modules.onboarding.recoverypassphrase.rekeyedaccountselection.information.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.basefoundaccount.information.ui.BaseFoundAccountInformationViewModel
import com.algorand.android.modules.onboarding.recoverypassphrase.rekeyedaccountselection.information.ui.model.RekeyedAccountInformationPreview
import com.algorand.android.modules.onboarding.recoverypassphrase.rekeyedaccountselection.information.ui.usecase.RekeyedAccountInformationPreviewUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@HiltViewModel
class RekeyedAccountInformationViewModel @Inject constructor(
    private val rekeyedAccountInformationPreviewUseCase: RekeyedAccountInformationPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseFoundAccountInformationViewModel() {

    private val navArgs = RekeyedAccountInformationFragmentArgs.fromSavedStateHandle(savedStateHandle)
    private val accountAddress = navArgs.accountAddress

    private val rekeyedAccountInformationPreviewFlow = MutableStateFlow(getInitialPreview())
    override val foundAccountInformationFieldsFlow: StateFlow<RekeyedAccountInformationPreview>
        get() = rekeyedAccountInformationPreviewFlow

    init {
        initRekeyedAccountInformationPreviewFlow()
    }

    private fun initRekeyedAccountInformationPreviewFlow() {
        viewModelScope.launch(Dispatchers.IO) {
            rekeyedAccountInformationPreviewUseCase.getRekeyedAccountInformationPreviewFlow(
                accountAddress = accountAddress,
                coroutineScope = this,
                preview = rekeyedAccountInformationPreviewFlow.value
            ).collectLatest { preview ->
                rekeyedAccountInformationPreviewFlow.emit(preview)
            }
        }
    }

    private fun getInitialPreview(): RekeyedAccountInformationPreview {
        return rekeyedAccountInformationPreviewUseCase.getInitialRekeyedAccountInformationPreview()
    }
}
