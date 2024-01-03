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

package com.algorand.android.modules.asb.createbackup.fileready.ui.usecase

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.text.format.Formatter
import androidx.documentfile.provider.DocumentFile
import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.asb.createbackup.fileready.ui.mapper.AsbFileReadyPreviewMapper
import com.algorand.android.modules.asb.createbackup.fileready.ui.model.AsbFileReadyPreview
import com.algorand.android.modules.asb.util.AlgorandSecureBackupUtils
import com.algorand.android.modules.baseresult.ui.mapper.ResultListItemMapper
import com.algorand.android.modules.baseresult.ui.usecase.BaseResultPreviewUseCase
import com.algorand.android.utils.Event
import dagger.hilt.android.qualifiers.ApplicationContext
import java.io.IOException
import java.io.OutputStreamWriter
import javax.inject.Inject

class AsbFileReadyPreviewUseCase @Inject constructor(
    @ApplicationContext private val context: Context,
    private val asbFileReadyPreviewMapper: AsbFileReadyPreviewMapper,
    resultListItemMapper: ResultListItemMapper
) : BaseResultPreviewUseCase(resultListItemMapper) {

    fun updatePreviewWithCreateDocumentIntent(preview: AsbFileReadyPreview): AsbFileReadyPreview {
        val documentTreeIntent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = AlgorandSecureBackupUtils.BACKUP_FILE_MIME_TYPE
            putExtra(Intent.EXTRA_TITLE, preview.fileName)
        }
        return preview.copy(launchCreateDocumentIntentEvent = Event(documentTreeIntent))
    }

    fun updatePreviewWithCopyFileContent(
        encryptedContent: String,
        preview: AsbFileReadyPreview
    ): AsbFileReadyPreview {
        return preview.copy(onFileContentCopyEvent = Event(encryptedContent))
    }

    fun updatePreviewWithSelectedBackupLocation(
        fileLocationUri: Uri?,
        encryptedContent: String,
        preview: AsbFileReadyPreview
    ): AsbFileReadyPreview {
        return try {
            if (fileLocationUri == null) {
                return updatePreviewAfterFailure(preview)
            }
            val backupFile = DocumentFile.fromSingleUri(context, fileLocationUri)
                ?: return updatePreviewAfterFailure(preview)
            val fileOutputStream = context.contentResolver?.openOutputStream(backupFile.uri)
            val outputWriter = OutputStreamWriter(fileOutputStream)
            outputWriter.use { writer -> writer.write(encryptedContent) }
            preview.copy(
                fileName = backupFile.name ?: preview.fileName,
                onBackupFileSavedEvent = Event(Unit)
            )
        } catch (exception: IOException) {
            updatePreviewAfterFailure(preview)
        }
    }

    fun getAsbFileReadyPreview(encryptedContent: String): AsbFileReadyPreview {
        val iconItem = createIconItem(
            iconTintColorResId = R.color.link_icon,
            iconResId = R.drawable.ic_check
        )
        val titleItem = createSingularTitleItem(
            titleTextResId = R.string.your_backup_file_is_ready
        )
        val descriptionItem = createSingularDescriptionItem(
            annotatedString = AnnotatedString(stringResId = R.string.save_your_file_somewhere_secure),
            isClickable = true
        )
        val resultItemList = listOf(
            iconItem,
            titleItem,
            descriptionItem
        )
        val fileSizeBytes = encryptedContent.toByteArray().size.toLong()
        return asbFileReadyPreviewMapper.mapToAsbFileReadyPreview(
            resultListItems = resultItemList,
            fileName = AlgorandSecureBackupUtils.createBackupFileName(),
            formattedFileSize = Formatter.formatShortFileSize(context, fileSizeBytes)
        )
    }

    private fun updatePreviewAfterFailure(preview: AsbFileReadyPreview): AsbFileReadyPreview {
        return preview.copy(navToFailureScreenEvent = Event(Unit))
    }
}
