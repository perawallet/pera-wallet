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

package com.algorand.android.modules.asb.createbackup.accountselection.ui

import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.asb.createbackup.accountselection.ui.model.AsbCreationAccountSelectionPreview
import com.algorand.android.modules.asb.createbackup.accountselection.ui.usecase.AsbCreationAccountSelectionPreviewUseCase
import com.algorand.android.modules.basemultipleaccountselection.ui.BaseMultipleAccountSelectionViewModel
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update

@HiltViewModel
class AsbCreationAccountSelectionViewModel @Inject constructor(
    private val asbCreationAccountSelectionPreviewUseCase: AsbCreationAccountSelectionPreviewUseCase
) : BaseMultipleAccountSelectionViewModel() {

    private val _multipleAccountSelectionPreviewFlow = MutableStateFlow(getInitialPreview())
    override val multipleAccountSelectionPreviewFlow: StateFlow<AsbCreationAccountSelectionPreview>
        get() = _multipleAccountSelectionPreviewFlow

    init {
        initMultipleAccountSelectionPreview()
    }

    fun onHeaderCheckBoxClick() {
        _multipleAccountSelectionPreviewFlow.update { preview ->
            asbCreationAccountSelectionPreviewUseCase.updatePreviewAfterHeaderCheckBoxClicked(preview)
        }
    }

    fun onAccountCheckBoxClick(accountAddress: String) {
        _multipleAccountSelectionPreviewFlow.update { preview ->
            asbCreationAccountSelectionPreviewUseCase.updatePreviewAfterAccountCheckBoxClicked(preview, accountAddress)
        }
    }

    fun onBackupAccountClick() {
        _multipleAccountSelectionPreviewFlow.update { preview ->
            asbCreationAccountSelectionPreviewUseCase.updatePreviewAfterActionButtonClicked(preview)
        }
    }

    private fun initMultipleAccountSelectionPreview() {
        viewModelScope.launchIO {
            val preview = asbCreationAccountSelectionPreviewUseCase.getAsbCreationAccountSelectionPreview()
            _multipleAccountSelectionPreviewFlow.emit(preview)
        }
    }

    private fun getInitialPreview(): AsbCreationAccountSelectionPreview {
        return asbCreationAccountSelectionPreviewUseCase.getInitialPreview()
    }
}
