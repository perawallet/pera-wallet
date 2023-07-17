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

package com.algorand.android.modules.onboarding.recoverypassphrase.rekeyedaccountselection.selection.ui

import androidx.lifecycle.SavedStateHandle
import com.algorand.android.modules.basefoundaccount.selection.ui.BaseFoundAccountSelectionViewModel
import com.algorand.android.modules.onboarding.recoverypassphrase.rekeyedaccountselection.selection.ui.model.RekeyedAccountSelectionPreview
import com.algorand.android.modules.onboarding.recoverypassphrase.rekeyedaccountselection.selection.ui.usecase.RekeyedAccountSelectionPreviewUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update

@HiltViewModel
class RekeyedAccountSelectionViewModel @Inject constructor(
    private val rekeyedAccountSelectionPreviewUseCase: RekeyedAccountSelectionPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseFoundAccountSelectionViewModel() {

    private val navArgs = RekeyedAccountSelectionFragmentArgs.fromSavedStateHandle(savedStateHandle)
    private val accountCreation = navArgs.accountCreation
    private val rekeyedAccountAddresses = navArgs.rekeyedAccountAddresses

    private val rekeyedAccountSelectionPreviewwFlow = MutableStateFlow(getInitialPreview())
    override val foundAccountSelectionFieldsFlow: StateFlow<RekeyedAccountSelectionPreview>
        get() = rekeyedAccountSelectionPreviewwFlow

    fun onAccountSelected(accountAddress: String) {
        rekeyedAccountSelectionPreviewwFlow.update { preview ->
            rekeyedAccountSelectionPreviewUseCase.updatePreviewWithSelectedAccount(preview, accountAddress)
        }
    }

    fun onChosenAccountAddClick() {
        rekeyedAccountSelectionPreviewwFlow.update { preview ->
            rekeyedAccountSelectionPreviewUseCase.updatePreviewWithChosenAccount(preview, accountCreation)
        }
    }

    fun onSkipForNowClick() {
        rekeyedAccountSelectionPreviewwFlow.update { preview ->
            rekeyedAccountSelectionPreviewUseCase.updatePreviewWithRecoveredAccount(preview, accountCreation)
        }
    }

    private fun getInitialPreview(): RekeyedAccountSelectionPreview {
        return rekeyedAccountSelectionPreviewUseCase.getRekeyedAccountSelectionPreviewFlow(
            rekeyedAccountAddresses = rekeyedAccountAddresses
        )
    }
}
