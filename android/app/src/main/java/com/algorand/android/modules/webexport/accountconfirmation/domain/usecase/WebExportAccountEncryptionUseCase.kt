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

package com.algorand.android.modules.webexport.accountconfirmation.domain.usecase

import com.algorand.android.models.AccountDetail
import com.algorand.android.modules.webexport.accountconfirmation.domain.mapper.BackupAccountsPayloadElementMapper
import com.algorand.android.modules.webexport.accountconfirmation.domain.mapper.BackupAccountsPayloadMapper
import com.algorand.android.modules.webexport.accountconfirmation.domain.mapper.EncryptionResultMapper
import com.algorand.android.modules.webexport.accountconfirmation.domain.model.EncryptionResult
import com.algorand.android.modules.webexport.accountconfirmation.domain.model.ExportBackupResponseDTO
import com.algorand.android.modules.webexport.accountconfirmation.domain.repository.WebExportAccountRepository
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.ENCRYPTION_SEPARATOR_CHAR
import com.algorand.android.utils.PROVIDER_NAME
import com.algorand.android.utils.SDK_RESULT_SUCCESS
import com.algorand.android.utils.decodeBase64OrByteArray
import com.algorand.android.utils.encodeBase64
import com.algorand.android.utils.encrypt
import com.algorand.android.utils.exceptions.EncryptionException
import com.google.gson.Gson
import kotlinx.coroutines.flow.flow
import javax.inject.Inject
import javax.inject.Named

class WebExportAccountEncryptionUseCase @Inject constructor(
    private val gson: Gson,
    private val accountDetailUseCase: AccountDetailUseCase,
    @Named(WebExportAccountRepository.REPOSITORY_INJECTION_NAME)
    private val webExportAccountRepository: WebExportAccountRepository,
    private val encryptionResultMapper: EncryptionResultMapper,
    private val backupAccountsPayloadMapper: BackupAccountsPayloadMapper,
    private val backupAccountsPayloadElementMapper: BackupAccountsPayloadElementMapper
) {

    suspend fun exportEncryptedBackup(
        backupId: String,
        modificationKey: String,
        encryptionKey: String,
        accountAddresses: List<String>
    ) = flow<DataResource<ExportBackupResponseDTO>> {
        emit(DataResource.Loading())
        val encryptedContent = getEncryptedAccountsData(encryptionKey, accountAddresses)
        encryptedContent.let { encryptionResult ->
            when (encryptionResult) {
                is EncryptionResult.Success -> {
                    webExportAccountRepository.exportEncryptedBackup(
                        backupId = backupId,
                        modificationKey = modificationKey,
                        encryptedString = encryptionResult.encryptedString
                    ).use(
                        onSuccess = { exportBackupResponse ->
                            emit(DataResource.Success(exportBackupResponse))
                        },
                        onFailed = { exception, code ->
                            emit(DataResource.Error.Api(exception, code))
                        }
                    )
                }

                is EncryptionResult.Error -> {
                    emit(DataResource.Error.Local(EncryptionException(encryptionResult.errorCode)))
                }
            }
        }
    }

    private fun getEncryptedAccountsData(
        encryptionKey: String,
        accountAddresses: List<String>
    ): EncryptionResult {
        val accountsDetail = accountAddresses.mapNotNull { key ->
            accountDetailUseCase.getCachedAccountDetail(key)?.data
        }
        val exportContent = createWebExportContent(accountsDetail)

        return createWebExportEncryptedContent(exportContent, encryptionKey)
    }

    private fun createWebExportContent(accounts: List<AccountDetail>): String {
        return gson.toJson(
            backupAccountsPayloadMapper.mapToBackupAccountsPayload(
                PROVIDER_NAME,
                accounts.mapNotNull { accountDetail ->
                    backupAccountsPayloadElementMapper.mapToBackupAccountsPayloadElement(
                        address = accountDetail.account.address,
                        name = accountDetail.account.name,
                        accountType = accountDetail.account.type?.name,
                        privateKey = accountDetail.account.getSecretKey()?.encodeBase64(),
                        metadata = null
                    )
                }
            )
        )
    }

    @OptIn(ExperimentalUnsignedTypes::class)
    private fun createWebExportEncryptedContent(content: String, encryptionKey: String): EncryptionResult {
        encryptionKey.decodeBase64OrByteArray()?.let { byteArray ->
            val encryption = content
                .toByteArray()
                .encrypt(byteArray)
            return if (encryption.errorCode == SDK_RESULT_SUCCESS) {
                encryptionResultMapper.mapToEncryptionResultSuccess(
                    encryption.encryptedData
                        .toUByteArray()
                        .toTypedArray()
                        .joinToString(separator = ENCRYPTION_SEPARATOR_CHAR) {
                            it.toString()
                        }
                )
            } else {
                encryptionResultMapper.mapToEncryptionResultError(encryption.errorCode)
            }
        } ?: return encryptionResultMapper.mapToEncryptionResultError(null)
    }
}
