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

package com.algorand.android.modules.backupprotocol.util

import com.algorand.android.models.Account

// TODO: we need to add other account types as well whenever we started to support them on
//  Algorand Secure Backup, Web import and Web Export feature
object BackupProtocolUtils {

    private const val SINGLE_ACCOUNT_TYPE_NAME = "single"

    fun convertAccountTypeToBackupProtocolAccountType(accountType: Account.Type): String? {
        return when (accountType) {
            Account.Type.STANDARD -> SINGLE_ACCOUNT_TYPE_NAME
            Account.Type.LEDGER,
            Account.Type.REKEYED,
            Account.Type.REKEYED_AUTH,
            Account.Type.WATCH -> null
        }
    }

    fun convertBackupProtocolAccountTypeToAccountType(accountType: String?): Account.Type? {
        return when (accountType) {
            SINGLE_ACCOUNT_TYPE_NAME -> Account.Type.STANDARD
            else -> null
        }
    }
}
