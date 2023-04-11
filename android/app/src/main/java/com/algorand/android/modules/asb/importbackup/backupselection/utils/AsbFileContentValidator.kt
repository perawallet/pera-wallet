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

package com.algorand.android.modules.asb.importbackup.backupselection.utils

import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.asb.util.AlgorandSecureBackupUtils.IMPORT_BACKUP_FILE_MIME_TYPES
import com.algorand.android.modules.backupprotocol.model.BackupProtocolContent
import com.algorand.android.utils.BACKUP_PROTOCOL_SUITE
import com.algorand.android.utils.BACKUP_PROTOCOL_VERSION
import javax.inject.Inject

class AsbFileContentValidator @Inject constructor() {

    fun isBackupFileTypeValid(fileType: String?): Boolean {
        return IMPORT_BACKUP_FILE_MIME_TYPES.contains(fileType)
    }

    @SuppressWarnings("ReturnCount")
    suspend fun validateBackupProtocolContent(
        deserializeContent: BackupProtocolContent?,
        onValidationFailed: suspend (AnnotatedString) -> Unit,
        onValidationSucceed: suspend (String) -> Unit
    ) {
        val safeDeserializeContent = deserializeContent ?: run {
            onValidationFailed.invoke(AnnotatedString(R.string.unable_to_parse_file))
            return
        }

        if (safeDeserializeContent.version == null) {
            val annotatedString = AnnotatedString(
                stringResId = R.string.unable_to_parse_key_name,
                replacementList = listOf("key_name" to VERSION_FIELD_KEY_NAME)
            )
            onValidationFailed.invoke(annotatedString)
            return
        }

        if (safeDeserializeContent.suite == null) {
            val annotatedString = AnnotatedString(
                stringResId = R.string.unable_to_parse_key_name,
                replacementList = listOf("key_name" to SUITE_FIELD_KEY_NAME)
            )
            onValidationFailed.invoke(annotatedString)
            return
        }

        if (safeDeserializeContent.cipherText == null) {
            val annotatedString = AnnotatedString(
                stringResId = R.string.unable_to_parse_key_name,
                replacementList = listOf("key_name" to CIPHER_TEXT_FIELD_KEY_NAME)
            )
            onValidationFailed.invoke(annotatedString)
            return
        }

        val isBackupVersionValid = isBackupVersionValid(deserializeContent.version)
        if (!isBackupVersionValid) {
            onValidationFailed.invoke(AnnotatedString(R.string.backup_file_was_generated_with))
            return
        }

        val isBackupSuiteValid = isBackupSuiteValid(deserializeContent.suite)
        if (!isBackupSuiteValid) {
            onValidationFailed.invoke(AnnotatedString(R.string.unable_to_parse_suite))
            return
        }

        onValidationSucceed.invoke(safeDeserializeContent.cipherText)
    }

    private fun isBackupVersionValid(backupVersion: String?): Boolean {
        return backupVersion == BACKUP_PROTOCOL_VERSION
    }

    private fun isBackupSuiteValid(backupSuite: String?): Boolean {
        return backupSuite == BACKUP_PROTOCOL_SUITE
    }

    companion object {
        private const val VERSION_FIELD_KEY_NAME = "Version"
        private const val SUITE_FIELD_KEY_NAME = "Suite"
        private const val CIPHER_TEXT_FIELD_KEY_NAME = "Ciphertext"
    }
}
