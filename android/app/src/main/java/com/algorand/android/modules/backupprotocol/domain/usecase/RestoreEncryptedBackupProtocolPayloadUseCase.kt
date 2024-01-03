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

package com.algorand.android.modules.backupprotocol.domain.usecase

import com.algorand.android.modules.algosdk.encryptionutil.domain.usecase.DecryptContentUseCase
import com.algorand.android.modules.backupprotocol.model.BackupProtocolPayload
import com.algorand.android.modules.backupprotocol.util.BackupProtocolUtils.convertBackupProtocolAccountTypeToAccountType
import com.algorand.android.modules.peraserializer.PeraSerializer
import javax.inject.Inject

class RestoreEncryptedBackupProtocolPayloadUseCase @Inject constructor(
    private val peraSerializer: PeraSerializer,
    private val decryptContentUseCase: DecryptContentUseCase
) {

    operator fun invoke(cipherText: String, cipherKey: ByteArray): BackupProtocolPayload? {
        val decryptedContent = decryptContentUseCase.invoke(cipherText, cipherKey) ?: return null
        val decryptedBackupProtocolPayload = peraSerializer.fromJson(
            json = decryptedContent,
            type = BackupProtocolPayload::class.java
        )
        val accountTypeUpdatedList = decryptedBackupProtocolPayload?.accounts?.map {
            val accountType = convertBackupProtocolAccountTypeToAccountType(it.accountType)
            it.copy(accountType = accountType?.name)
        }
        return decryptedBackupProtocolPayload?.copy(accounts = accountTypeUpdatedList)
    }
}
