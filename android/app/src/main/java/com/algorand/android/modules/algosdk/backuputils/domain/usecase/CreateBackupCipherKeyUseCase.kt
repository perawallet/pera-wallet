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

import com.algorand.android.utils.DataResource
import javax.inject.Inject

class CreateBackupCipherKeyUseCase @Inject constructor(
    private val derivePrivateKeyFromMnemonicsUseCase: DerivePrivateKeyFromMnemonicsUseCase,
    private val generateBackupCipherKeyUseCase: GenerateBackupCipherKeyUseCase
) {

    suspend operator fun invoke(mnemonics: String): DataResource<ByteArray> {
        val privateKey = derivePrivateKeyFromMnemonicsUseCase.invoke(mnemonics)
            ?: return DataResource.Error.Local(IllegalStateException())
        val cipherKey = generateBackupCipherKeyUseCase.invoke(privateKey)
            ?: return DataResource.Error.Local(IllegalStateException())
        return DataResource.Success(cipherKey)
    }
}
