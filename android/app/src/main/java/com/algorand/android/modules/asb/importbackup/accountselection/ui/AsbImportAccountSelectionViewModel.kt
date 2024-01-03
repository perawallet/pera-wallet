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

package com.algorand.android.modules.asb.importbackup.accountselection.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.modules.asb.importbackup.accountselection.ui.model.AsbImportAccountSelectionPreview
import com.algorand.android.modules.asb.importbackup.accountselection.ui.usecase.AsbImportAccountSelectionPreviewUseCase
import com.algorand.android.modules.backupprotocol.model.BackupProtocolElement
import com.algorand.android.modules.basemultipleaccountselection.ui.BaseMultipleAccountSelectionViewModel
import com.algorand.android.utils.getOrThrow
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.update

@HiltViewModel
class AsbImportAccountSelectionViewModel @Inject constructor(
    private val asbImportAccountSelectionPreviewUseCase: AsbImportAccountSelectionPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseMultipleAccountSelectionViewModel() {

    private var accountImportJob: Job? = null

    private val backupProtocolElements = savedStateHandle.getOrThrow<Array<BackupProtocolElement>>(
        argKey = BACKUP_PROTOCOL_ELEMENTS_KEY
    )

    private val _asbImportAccountSelectionPreviewFlow = MutableStateFlow(getInitialPreview())
    override val multipleAccountSelectionPreviewFlow: StateFlow<AsbImportAccountSelectionPreview>
        get() = _asbImportAccountSelectionPreviewFlow

    init {
        setAsbImportAccountSelectionPreview()
    }

    fun onHeaderCheckBoxClick() {
        _asbImportAccountSelectionPreviewFlow.update { preview ->
            asbImportAccountSelectionPreviewUseCase.updatePreviewAfterHeaderCheckBoxClicked(preview)
        }
    }

    fun onAccountCheckBoxClick(accountAddress: String) {
        _asbImportAccountSelectionPreviewFlow.update { preview ->
            asbImportAccountSelectionPreviewUseCase.updatePreviewAfterAccountCheckBoxClicked(preview, accountAddress)
        }
    }

    fun onRestoreClick() {
        accountImportJob?.cancel()
        accountImportJob = viewModelScope.launchIO {
            asbImportAccountSelectionPreviewUseCase.updatePreviewWithRestoredAccounts(
                preview = _asbImportAccountSelectionPreviewFlow.value,
                backupProtocolElements = backupProtocolElements
            ).collectLatest { preview ->
                _asbImportAccountSelectionPreviewFlow.emit(preview)
            }
        }
    }

    private fun getInitialPreview(): AsbImportAccountSelectionPreview {
        return asbImportAccountSelectionPreviewUseCase.getInitialPreview()
    }

    private fun setAsbImportAccountSelectionPreview() {
        viewModelScope.launchIO {
            val preview = asbImportAccountSelectionPreviewUseCase.getAsbImportAccountSelectionPreview(
                preview = _asbImportAccountSelectionPreviewFlow.value,
                backupProtocolElements = backupProtocolElements
            )
            _asbImportAccountSelectionPreviewFlow.value = preview
        }
    }

    companion object {
        private const val BACKUP_PROTOCOL_ELEMENTS_KEY = "backupProtocolElements"
    }
}
