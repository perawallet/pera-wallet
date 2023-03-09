/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.modules.webexport.accountconfirmation.data.repository

import com.algorand.android.models.Result
import com.algorand.android.modules.webexport.accountconfirmation.data.mapper.ExportBackupResponseDTOMapper
import com.algorand.android.modules.webexport.accountconfirmation.domain.repository.WebExportAccountRepository
import com.algorand.android.modules.webexport.common.data.model.WebBackupRequestBody
import com.algorand.android.modules.webexport.accountconfirmation.domain.model.ExportBackupResponseDTO
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.requestWithHipoErrorHandler
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import javax.inject.Inject

class WebExportAccountRepositoryImpl @Inject constructor(
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val hipoApiErrorHandler: RetrofitErrorHandler,
    private val exportBackupResponseDTOMapper: ExportBackupResponseDTOMapper
) : WebExportAccountRepository {

    override suspend fun exportEncryptedBackup(
        backupId: String,
        modificationKey: String,
        encryptedString: String
    ): Result<ExportBackupResponseDTO> {
        return requestWithHipoErrorHandler(hipoApiErrorHandler) {
            mobileAlgorandApi.putBackup(
                id = backupId,
                modificationKey = modificationKey,
                body = WebBackupRequestBody(
                    encryptedContent = encryptedString
                )
            )
        }.map { response ->
            exportBackupResponseDTOMapper.mapToExportBackupResponseDTO(response)
        }
    }
}
