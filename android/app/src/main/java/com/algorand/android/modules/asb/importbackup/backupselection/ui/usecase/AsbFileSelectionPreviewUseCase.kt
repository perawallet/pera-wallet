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

package com.algorand.android.modules.asb.importbackup.backupselection.ui.usecase

import android.content.Context
import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import com.algorand.android.R
import com.algorand.android.customviews.perafileuploadview.mapper.FileUploadStateMapper
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.asb.importbackup.backupselection.ui.mapper.AsbFileSelectionPreviewMapper
import com.algorand.android.modules.asb.importbackup.backupselection.ui.model.AsbFileSelectionPreview
import com.algorand.android.modules.asb.importbackup.backupselection.utils.AsbFileContentValidator
import com.algorand.android.modules.backupprotocol.model.BackupProtocolContent
import com.algorand.android.modules.peraserializer.PeraSerializer
import com.algorand.android.utils.Event
import com.algorand.android.utils.clipboard.manager.PeraClipboardManager
import com.algorand.android.utils.extensions.decodeBase64ToString
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.flowOn

class AsbFileSelectionPreviewUseCase @Inject constructor(
    @ApplicationContext private val context: Context,
    private val asbFileSelectionPreviewMapper: AsbFileSelectionPreviewMapper,
    @Named(PeraClipboardManager.INJECTION_NAME)
    private val peraClipboardManager: PeraClipboardManager,
    private val fileUploadStateMapper: FileUploadStateMapper,
    private val asbFileContentValidator: AsbFileContentValidator,
    private val peraSerializer: PeraSerializer
) {

    fun updatePreviewWithNextNavigation(preview: AsbFileSelectionPreview): AsbFileSelectionPreview {
        val safeCipherText = preview.fileCipherText ?: run {
            return createClipboardDataErrorState(preview)
        }
        return preview.copy(navToAsbEnterKeyFragmentEvent = Event(safeCipherText))
    }

    fun updatePreviewWithClipboardData(preview: AsbFileSelectionPreview) = flow {
        val clipboardData = peraClipboardManager.getTextFromClipboard()
        if (clipboardData.isNullOrBlank()) {
            val titleAnnotatedString = AnnotatedString(R.string.nothing_to_paste)
            val descriptionAnnotatedString = AnnotatedString(R.string.nothing_is_copied_to_the)
            val errorPair = titleAnnotatedString to descriptionAnnotatedString
            emit(preview.copy(showGlobalErrorEvent = Event(errorPair)))
            return@flow
        }
        val decodedBackupProtocolContent = clipboardData.decodeBase64ToString().orEmpty()
        val backupProtocolContent = peraSerializer.fromJson(
            json = decodedBackupProtocolContent,
            type = BackupProtocolContent::class.java
        )
        asbFileContentValidator.validateBackupProtocolContent(
            deserializeContent = backupProtocolContent,
            onValidationFailed = { errorStatusAnnotatedString ->
                emit(createClipboardDataErrorState(preview, errorStatusAnnotatedString))
            },
            onValidationSucceed = { fileCipherText ->
                val successPreview = preview.copy(
                    navToAsbEnterKeyFragmentEvent = Event(fileCipherText),
                    showGlobalSuccessEvent = Event(R.string.backup_file_successfully_pasted)
                )
                emit(successPreview)
            }
        )
    }.catch {
        emit(createClipboardDataErrorState(preview))
    }.flowOn(Dispatchers.IO)

    @SuppressWarnings("LongMethod")
    fun updatePreviewWithSelectedFile(preview: AsbFileSelectionPreview, fileLocationUri: Uri?) = flow {
        if (fileLocationUri == null) {
            emit(createUploadFileErrorState(preview))
            return@flow
        }

        val backupFile = DocumentFile.fromSingleUri(context, fileLocationUri) ?: run {
            emit(createUploadFileErrorState(preview))
            return@flow
        }

        val loadingState = preview.copy(
            fileUploadState = fileUploadStateMapper.mapToUploading(backupFile.name),
            isNextButtonEnabled = false,
            isPasteButtonVisible = false
        )
        emit(loadingState)

        val isFileTypeValid = asbFileContentValidator.isBackupFileTypeValid(backupFile.type)
        if (!isFileTypeValid) {
            val errorState = createUploadFileErrorState(
                preview = preview,
                fileName = backupFile.name,
                errorStatusAnnotatedString = AnnotatedString(R.string.this_file_type_isn_t_supported)
            )
            emit(errorState)
            return@flow
        }

        val fileInputStream = context.contentResolver?.openInputStream(backupFile.uri)
        if (fileInputStream == null) {
            emit(createUploadFileErrorState(preview, backupFile.name))
            return@flow
        }

        val fileContent = fileInputStream.use { inputStream -> inputStream.readBytes().toString(Charsets.UTF_8) }
        val decodedBackupProtocolContent = fileContent.decodeBase64ToString().orEmpty()
        val backupProtocolContent = peraSerializer.fromJson(
            json = decodedBackupProtocolContent,
            type = BackupProtocolContent::class.java
        )
        asbFileContentValidator.validateBackupProtocolContent(
            deserializeContent = backupProtocolContent,
            onValidationFailed = { errorStatusAnnotatedString ->
                val errorState = createUploadFileErrorState(
                    preview = preview,
                    fileName = backupFile.name,
                    errorStatusAnnotatedString = errorStatusAnnotatedString
                )
                emit(errorState)
            },
            onValidationSucceed = { fileCipherText ->
                val successState = preview.copy(
                    fileUploadState = fileUploadStateMapper.mapToSuccessful(backupFile.name),
                    isNextButtonEnabled = true,
                    isPasteButtonVisible = true,
                    fileCipherText = fileCipherText
                )
                emit(successState)
            }
        )
    }.catch {
        val errorState = createUploadFileErrorState(preview)
        emit(errorState)
    }.flowOn(Dispatchers.IO)

    fun updatePreviewWithCancelUpload(preview: AsbFileSelectionPreview): AsbFileSelectionPreview {
        return preview.copy(
            fileUploadState = fileUploadStateMapper.mapToInitial(),
            fileCipherText = null
        )
    }

    fun updatePreviewWithReplaceFile(preview: AsbFileSelectionPreview): AsbFileSelectionPreview {
        return preview.copy(
            openFileSelectorEvent = Event(Unit),
            fileCipherText = null
        )
    }

    fun updatePreviewWithSelectFile(preview: AsbFileSelectionPreview): AsbFileSelectionPreview {
        return preview.copy(openFileSelectorEvent = Event(Unit))
    }

    fun getInitialAsbFileSelectionPreview(): AsbFileSelectionPreview {
        return asbFileSelectionPreviewMapper.mapToAsbFileSelectionPreview(
            isNextButtonEnabled = false,
            isPasteButtonVisible = true,
            fileUploadState = fileUploadStateMapper.mapToInitial()
        )
    }

    private fun createUploadFileErrorState(
        preview: AsbFileSelectionPreview,
        fileName: String? = null,
        errorStatusAnnotatedString: AnnotatedString = AnnotatedString(R.string.upload_failed)
    ): AsbFileSelectionPreview {
        return preview.copy(
            fileUploadState = fileUploadStateMapper.mapToFailure(
                fileName = fileName,
                errorStatusAnnotatedString = errorStatusAnnotatedString
            ),
            isNextButtonEnabled = false,
            isPasteButtonVisible = true,
            fileCipherText = null
        )
    }

    private fun createClipboardDataErrorState(
        preview: AsbFileSelectionPreview,
        errorStatusAnnotatedString: AnnotatedString = AnnotatedString(R.string.upload_failed)
    ): AsbFileSelectionPreview {
        val errorPair = errorStatusAnnotatedString to null
        return preview.copy(showGlobalErrorEvent = Event(errorPair), fileCipherText = null)
    }
}
