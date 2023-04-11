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

package com.algorand.android.modules.asb.util

import com.algorand.android.models.Account.Type
import com.algorand.android.utils.ISO_EXTENDED_DATE_FORMAT
import com.algorand.android.utils.getCurrentTimeAsZonedDateTime
import java.time.format.DateTimeFormatter

object AlgorandSecureBackupUtils {

    private const val BACKUP_FILE_SUFFIX = "_backup.txt"
    const val BACKUP_FILE_MIME_TYPE = "text/plain"
    val IMPORT_BACKUP_FILE_MIME_TYPES = arrayOf(BACKUP_FILE_MIME_TYPE, "application/json")

    const val BACKUP_PASSPHRASES_WORD_COUNT = 12

    val eligibleAccountTypes = listOf(Type.STANDARD)
    val excludedAccountTypes = listOf(Type.LEDGER, Type.WATCH, Type.REKEYED, Type.REKEYED_AUTH)

    fun createBackupFileName(): String {
        val backupFileNameFormatter = DateTimeFormatter.ofPattern(ISO_EXTENDED_DATE_FORMAT)
        return getCurrentTimeAsZonedDateTime().format(backupFileNameFormatter) + BACKUP_FILE_SUFFIX
    }
}
