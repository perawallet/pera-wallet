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

package com.algorand.android.modules.webimport.loading.domain.usecase

import com.algorand.algosdk.mobile.Mobile
import com.algorand.android.core.AccountManager
import com.algorand.android.models.Account
import com.algorand.android.models.Result
import com.algorand.android.models.BackupTransferAccountElement
import com.algorand.android.modules.webimport.loading.domain.model.ImportedAccountResult
import com.algorand.android.modules.webimport.loading.domain.repository.WebImportAccountRepository
import com.algorand.android.usecase.AccountAdditionUseCase
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.analytics.CreationType
import com.algorand.android.utils.decrypt
import com.algorand.android.utils.exceptions.DecryptionException
import com.algorand.android.utils.exceptions.EmptyContentException
import com.algorand.android.utils.fromJson
import com.algorand.android.utils.decodeBase64OrByteArray
import com.algorand.android.utils.toShortenedAddress
import com.google.gson.Gson
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.flow

class WebImportAccountDecryptionUseCase @Inject constructor(
    private val gson: Gson,
    private val accountAdditionUseCase: AccountAdditionUseCase,
    private val accountManager: AccountManager,
    @Named(WebImportAccountRepository.REPOSITORY_INJECTION_NAME)
    private val webImportAccountRepository: WebImportAccountRepository
) {

    suspend fun importEncryptedBackup(
        backupId: String,
        encryptionKey: String
    ) = flow<DataResource<ImportedAccountResult>> {
        emit(DataResource.Loading())
        webImportAccountRepository
            .importEncryptedBackup(backupId).use(
                onSuccess = { importBackupResponse ->
                    if (importBackupResponse.encryptedContent != null) {
                        val result = createWebImportDecryptedContent(
                            importBackupResponse.encryptedContent,
                            encryptionKey
                        )
                        emit(handleDecryptionResult(result))
                    } else {
                        emit(DataResource.Error.Local(EmptyContentException()))
                    }
                },
                onFailed = { exception, code ->
                    emit(DataResource.Error.Api(exception, code))
                }
            )
    }

    private fun createWebImportDecryptedContent(content: String, encryptionKey: String): Result<String> {
        encryptionKey.decodeBase64OrByteArray()?.let { byteArray ->
            val decryption = content
                .decodeBase64OrByteArray()
                ?.decrypt(byteArray) ?: return Result.Error(DecryptionException(0))
            return if (decryption.errorCode == 0L) {
                Result.Success(String(decryption.decryptedData))
            } else {
                Result.Error(DecryptionException(decryption.errorCode))
            }
        } ?: return Result.Error(DecryptionException(null))
    }

    private suspend fun handleDecryptionResult(result: Result<String>): DataResource<ImportedAccountResult> {
        when (result) {
            is Result.Success -> {
                val elements = gson.fromJson<List<BackupTransferAccountElement>>(result.data)
                val importedAccounts = mutableListOf<String>()
                val unimportedAccounts = mutableListOf<String>()
                elements?.forEach {
                    val privateKey = it.privateKey?.decodeBase64OrByteArray()
                    val publicKey = Mobile.generateAddressFromSK(privateKey)
                    if (shouldSkipImport(publicKey) || privateKey == null) {
                        unimportedAccounts.add(publicKey)
                    } else {
                        val recoveredAccount = Account.create(
                            publicKey,
                            Account.Detail.Standard(privateKey),
                            it.name ?: publicKey.toShortenedAddress()
                        )
                        addNewAccount(recoveredAccount)
                        importedAccounts.add(publicKey)
                    }
                }
                return DataResource.Success(ImportedAccountResult(importedAccounts, unimportedAccounts))
            }
            is Result.Error -> {
                return DataResource.Error.Local(result.exception)
            }
        }
    }

    private fun shouldSkipImport(publicKey: String): Boolean {
        val sameAccount = getAccountIfExist(publicKey)
        return sameAccount != null &&
            sameAccount.type != Account.Type.REKEYED &&
            sameAccount.type != Account.Type.WATCH
    }

    private suspend fun addNewAccount(account: Account, creationType: CreationType? = CreationType.RECOVER) {
        accountAdditionUseCase.addNewAccount(account, creationType)
    }

    private fun getAccountIfExist(publicKey: String): Account? {
        return accountManager.getAccounts().find { account -> account.address == publicKey }
    }
}
