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

package com.algorand.android.modules.asb.importbackup.backupselection.ui

import android.net.Uri
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.asb.importbackup.backupselection.ui.model.AsbFileSelectionPreview
import com.algorand.android.modules.asb.importbackup.backupselection.ui.usecase.AsbFileSelectionPreviewUseCase
import com.algorand.android.utils.launchIO
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.update

@HiltViewModel
class AsbFileSelectionViewModel @Inject constructor(
    private val asbFileSelectionPreviewUseCase: AsbFileSelectionPreviewUseCase
) : BaseViewModel() {

    private var fileUploadJob: Job? = null

    private val _asbFileSelectionPreviewFlow = MutableStateFlow(getInitialPreview())
    val asbFileSelectionPreviewFlow: StateFlow<AsbFileSelectionPreview> get() = _asbFileSelectionPreviewFlow

    fun onUploadCancelClick() {
        fileUploadJob?.cancel()
        _asbFileSelectionPreviewFlow.update { preview ->
            asbFileSelectionPreviewUseCase.updatePreviewWithCancelUpload(preview)
        }
    }

    fun onReplaceFileClick() {
        _asbFileSelectionPreviewFlow.update { preview ->
            asbFileSelectionPreviewUseCase.updatePreviewWithReplaceFile(preview)
        }
    }

    fun onSelectFileClick() {
        _asbFileSelectionPreviewFlow.update { preview ->
            asbFileSelectionPreviewUseCase.updatePreviewWithSelectFile(preview)
        }
    }

    fun onNextButtonClick() {
        _asbFileSelectionPreviewFlow.update { preview ->
            asbFileSelectionPreviewUseCase.updatePreviewWithNextNavigation(preview)
        }
    }

    fun onFileSelected(fileUri: Uri?) {
        fileUploadJob?.cancel()
        fileUploadJob = viewModelScope.launchIO {
            asbFileSelectionPreviewUseCase.updatePreviewWithSelectedFile(
                preview = _asbFileSelectionPreviewFlow.value,
                fileLocationUri = fileUri
            ).collectLatest { preview ->
                _asbFileSelectionPreviewFlow.emit(preview)
            }
        }
    }

    fun onPasteButtonClick() {
        fileUploadJob?.cancel()
        fileUploadJob = viewModelScope.launchIO {
            asbFileSelectionPreviewUseCase.updatePreviewWithClipboardData(
                preview = _asbFileSelectionPreviewFlow.value
            ).collectLatest { preview ->
                _asbFileSelectionPreviewFlow.emit(preview)
            }
        }
    }

    private fun getInitialPreview(): AsbFileSelectionPreview {
        return asbFileSelectionPreviewUseCase.getInitialAsbFileSelectionPreview()
    }
}
