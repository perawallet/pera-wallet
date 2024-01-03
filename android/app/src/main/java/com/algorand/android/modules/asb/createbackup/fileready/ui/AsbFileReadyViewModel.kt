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

package com.algorand.android.modules.asb.createbackup.fileready.ui

import android.net.Uri
import androidx.lifecycle.SavedStateHandle
import com.algorand.android.modules.asb.createbackup.fileready.ui.model.AsbFileReadyPreview
import com.algorand.android.modules.asb.createbackup.fileready.ui.usecase.AsbFileReadyPreviewUseCase
import com.algorand.android.modules.baseresult.ui.BaseResultViewModel
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update

@HiltViewModel
class AsbFileReadyViewModel @Inject constructor(
    private val asbFileReadyPreviewUseCase: AsbFileReadyPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseResultViewModel() {

    private val encryptedContent = savedStateHandle.getOrThrow<String>(ENCRYPTED_CONTENT_KEY)

    private val _asbFileReadyPreviewFlow = MutableStateFlow(getInitialPreview())
    override val baseResultPreviewFlow: StateFlow<AsbFileReadyPreview> get() = _asbFileReadyPreviewFlow

    fun onFileContentCopy() {
        _asbFileReadyPreviewFlow.update { preview ->
            asbFileReadyPreviewUseCase.updatePreviewWithCopyFileContent(encryptedContent, preview)
        }
    }

    fun onBackupLocationSelected(fileLocationUri: Uri?) {
        _asbFileReadyPreviewFlow.update { preview ->
            asbFileReadyPreviewUseCase.updatePreviewWithSelectedBackupLocation(
                fileLocationUri = fileLocationUri,
                encryptedContent = encryptedContent,
                preview = preview
            )
        }
    }

    fun onSaveBackupFileClick() {
        _asbFileReadyPreviewFlow.update { preview ->
            asbFileReadyPreviewUseCase.updatePreviewWithCreateDocumentIntent(preview)
        }
    }

    private fun getInitialPreview(): AsbFileReadyPreview {
        return asbFileReadyPreviewUseCase.getAsbFileReadyPreview(encryptedContent)
    }

    companion object {
        private const val ENCRYPTED_CONTENT_KEY = "encryptedContent"
    }
}
