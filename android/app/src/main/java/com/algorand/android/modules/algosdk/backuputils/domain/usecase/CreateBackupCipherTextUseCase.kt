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

package com.algorand.android.modules.algosdk.backuputils.domain.usecase

import com.algorand.android.modules.algosdk.encryptionutil.domain.usecase.EncryptContentUseCase
import com.algorand.android.utils.joinMnemonics
import javax.inject.Inject

class CreateBackupCipherTextUseCase @Inject constructor(
    private val createBackupCipherKeyUseCase: CreateBackupCipherKeyUseCase,
    private val encryptContentUseCase: EncryptContentUseCase
) {

    suspend operator fun invoke(payload: String, mnemonics: List<String>): String? {
        var backupCipherKey: ByteArray? = null
        createBackupCipherKeyUseCase.invoke(mnemonics.joinMnemonics()).useSuspended(
            onSuccess = { cipherKey ->
                backupCipherKey = cipherKey
            },
            onFailed = {
                backupCipherKey = null
            }
        )
        if (backupCipherKey == null) return null
        return encryptContentUseCase.invoke(payload.toByteArray(), backupCipherKey ?: return null)
    }
}
