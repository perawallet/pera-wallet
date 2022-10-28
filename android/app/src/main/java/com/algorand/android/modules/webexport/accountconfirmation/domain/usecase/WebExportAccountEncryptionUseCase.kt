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

import com.algorand.android.deviceregistration.domain.usecase.DeviceIdUseCase
import com.algorand.android.modules.webexport.accountconfirmation.domain.mapper.BackupAccountsPayloadElementMapper
import com.algorand.android.modules.webexport.accountconfirmation.domain.mapper.BackupAccountsPayloadMapper
import com.algorand.android.modules.webexport.accountconfirmation.domain.mapper.EncryptionResultMapper
import com.algorand.android.modules.webexport.accountconfirmation.domain.model.EncryptionResult
import com.algorand.android.modules.webexport.accountconfirmation.domain.model.ExportBackupResponseDTO
import com.algorand.android.modules.webexport.accountconfirmation.domain.repository.WebExportAccountRepository
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.encrypt
import com.google.gson.Gson
import kotlinx.coroutines.flow.flow
import javax.inject.Inject
import javax.inject.Named

class WebExportAccountEncryptionUseCase @Inject constructor(
    private val gson: Gson,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val deviceIdUseCase: DeviceIdUseCase,
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
        encryptedContent?.let { encryptionResult ->
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
                    // TODO handle error with an exception?
                    // emit(DataResource.Error.Local(encryptionResult.errorCode))
                }
            }
        }
    }

    private suspend fun getEncryptedAccountsData(
        encryptionKey: String,
        accountAddresses: List<String>
    ): EncryptionResult? {
        val accountsDetail = accountAddresses.mapNotNull { key ->
            accountDetailUseCase.getCachedAccountDetail(key)?.data?.let { detail ->
                detail.account.getSecretKey()?.let { secretKey ->
                    Pair(detail.account.name, secretKey)
                }
            }
        }
        val exportContent = deviceIdUseCase.getSelectedNodeDeviceId()?.let { deviceId ->
            createWebExportContent(deviceId, accountsDetail)
        }

        return exportContent?.let { createWebExportEncryptedContent(it, encryptionKey) }
    }

    private fun createWebExportContent(deviceId: String, accounts: List<Pair<String, ByteArray>>): String {
        return gson.toJson(
            backupAccountsPayloadMapper.mapToBackupAccountsPayload(
                deviceId,
                accounts.map { accountPair ->
                    backupAccountsPayloadElementMapper.mapToBackupAccountsPayloadElement(
                        accountPair.first,
                        accountPair.second.toPrivateKeyStringFormat()
                    )
                }
            )
        )
    }

    @OptIn(ExperimentalUnsignedTypes::class)
    private fun createWebExportEncryptedContent(content: String, encryptionKey: String): EncryptionResult {
        val encryption = content
            .toByteArray()
            .encrypt(encryptionKey.getEncryptionKeyAsByteArray())
        with(encryption) {
            return if (errorCode == 0L) {
                encryptionResultMapper.mapToEncryptionResultSuccess(
                    encryptedData
                    .toUByteArray()
                    .toTypedArray()
                    .joinToString(separator = SEPARATOR_CHAR) {
                        it.toString()
                    }
                )
            } else {
                encryptionResultMapper.mapToEncryptionResultError(errorCode)
            }
        }
    }

    @OptIn(ExperimentalUnsignedTypes::class)
    private fun String.getEncryptionKeyAsByteArray(): ByteArray {
        return this.split(SEPARATOR_CHAR).map {
            it.toUByte()
        }.toTypedArray().toUByteArray().toByteArray()
    }

    private fun ByteArray.toPrivateKeyStringFormat(): String {
        return this.joinToString(separator = SEPARATOR_CHAR)
    }

    companion object {
        private const val SEPARATOR_CHAR = ","
    }
}
