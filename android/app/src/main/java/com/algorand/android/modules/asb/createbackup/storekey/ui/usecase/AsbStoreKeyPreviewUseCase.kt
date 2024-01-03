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

package com.algorand.android.modules.asb.createbackup.storekey.ui.usecase

import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.algosdk.backuputils.domain.usecase.CreateBackupCipherTextUseCase
import com.algorand.android.modules.algosdk.backuputils.domain.usecase.CreateBackupMnemonicUseCase
import com.algorand.android.modules.asb.backedupaccountssource.domain.usecase.AddBackedUpAccountsUseCase
import com.algorand.android.modules.asb.createbackup.storekey.ui.mapper.AsbStoreKeyPreviewMapper
import com.algorand.android.modules.asb.createbackup.storekey.ui.model.AsbStoreKeyPreview
import com.algorand.android.modules.asb.mnemonics.domain.usecase.GetBackupMnemonicsUseCase
import com.algorand.android.modules.asb.mnemonics.domain.usecase.StoreBackupMnemonicsUseCase
import com.algorand.android.modules.backupprotocol.domain.usecase.CreateBackupProtocolContentUseCase
import com.algorand.android.modules.backupprotocol.domain.usecase.CreateBackupProtocolPayloadUseCase
import com.algorand.android.modules.peraserializer.PeraSerializer
import com.algorand.android.utils.Event
import com.algorand.android.utils.browser.ASB_SUPPORT_URL
import com.algorand.android.utils.extensions.encodeBase64
import com.algorand.android.utils.joinMnemonics
import com.algorand.android.utils.splitMnemonic
import javax.inject.Inject

class AsbStoreKeyPreviewUseCase @Inject constructor(
    private val getBackupMnemonicsUseCase: GetBackupMnemonicsUseCase,
    private val createBackupMnemonicUseCase: CreateBackupMnemonicUseCase,
    private val asbStoreKeyPreviewMapper: AsbStoreKeyPreviewMapper,
    private val createBackupCipherTextUseCase: CreateBackupCipherTextUseCase,
    private val createBackupProtocolContentUseCase: CreateBackupProtocolContentUseCase,
    private val addBackedUpAccountsUseCase: AddBackedUpAccountsUseCase,
    private val storeBackupMnemonicsUseCase: StoreBackupMnemonicsUseCase,
    private val createBackupProtocolPayloadUseCase: CreateBackupProtocolPayloadUseCase,
    private val peraSerializer: PeraSerializer
) {

    suspend fun saveBackedUpAccountToLocalStorage(accountList: Array<String>) {
        addBackedUpAccountsUseCase.invoke(accountList.toSet())
    }

    suspend fun updatePreviewAfterCreatingBackupFile(
        preview: AsbStoreKeyPreview?,
        accountList: List<String>
    ): AsbStoreKeyPreview? {
        val backupProtocolPayload = createBackupProtocolPayloadUseCase.invoke(accountList)
        val serializedPayload = peraSerializer.toJson(backupProtocolPayload)
        val cipherText = createBackupCipherTextUseCase.invoke(
            payload = serializedPayload,
            mnemonics = preview?.mnemonics.orEmpty()
        ) ?: return updatePreviewAfterFailure(preview)

        val backupProtocolContent = createBackupProtocolContentUseCase.invoke(cipherText = cipherText)
        val serializedContent = peraSerializer.toJson(payload = backupProtocolContent)
        val encodedContent = serializedContent.encodeBase64().orEmpty()
        return preview?.copy(navToBackupReadyEvent = Event(encodedContent))
    }

    suspend fun updatePreviewWithNewCreatedKey(): AsbStoreKeyPreview? {
        return createPreviewForFirstBackup()
    }

    fun updatePreviewAfterClickingCreateNewKey(
        preview: AsbStoreKeyPreview?
    ): AsbStoreKeyPreview? {
        return preview?.copy(navToCreateNewKeyConfirmationEvent = Event(Unit))
    }

    fun updatePreviewAfterClickingCreateBackupFile(
        preview: AsbStoreKeyPreview?
    ): AsbStoreKeyPreview? {
        return preview?.copy(navToCreateBackupConfirmationEvent = Event(Unit))
    }

    fun updatePreviewAfterClickingDescriptionUrl(
        preview: AsbStoreKeyPreview?
    ): AsbStoreKeyPreview? {
        return preview?.copy(openUrlEvent = Event(ASB_SUPPORT_URL))
    }

    fun updatePreviewAfterClickingCopyToKeyboard(
        preview: AsbStoreKeyPreview?
    ): AsbStoreKeyPreview? {
        val mnemonics = preview?.mnemonics?.joinMnemonics().orEmpty()
        return preview?.copy(onKeyCopiedEvent = Event(mnemonics))
    }

    suspend fun getAsbStoreKeyPreview(): AsbStoreKeyPreview? {
        val backupMnemonics = getBackupMnemonicsUseCase.invoke()
        return if (backupMnemonics == null) {
            createPreviewForFirstBackup()
        } else {
            createPreviewForSecondBackup(backupMnemonics)
        }
    }

    private suspend fun createPreviewForFirstBackup(): AsbStoreKeyPreview? {
        var asbStoreKeyPreview: AsbStoreKeyPreview? = null
        createBackupMnemonicUseCase.invoke().useSuspended(
            onSuccess = { mnemonics ->
                storeBackupMnemonicsUseCase.invoke(mnemonics)
                asbStoreKeyPreview = asbStoreKeyPreviewMapper.mapToAsbStoreKeyPreview(
                    titleTextResId = R.string.store_your_n_12_word_key,
                    isCreateNewKeyButtonVisible = false,
                    descriptionAnnotatedString = AnnotatedString(stringResId = R.string.your_12_word_key_is),
                    mnemonics = mnemonics.splitMnemonic()
                )
            },
            onFailed = {
                asbStoreKeyPreview = asbStoreKeyPreviewMapper.mapToAsbStoreKeyPreview(
                    titleTextResId = R.string.store_your_n_12_word_key,
                    isCreateNewKeyButtonVisible = false,
                    descriptionAnnotatedString = AnnotatedString(stringResId = R.string.your_12_word_key_is),
                    mnemonics = emptyList(),
                    navToFailureScreenEvent = Event(Unit)
                )
            }
        )
        return asbStoreKeyPreview
    }

    private fun createPreviewForSecondBackup(backupMnemonics: String): AsbStoreKeyPreview {
        return asbStoreKeyPreviewMapper.mapToAsbStoreKeyPreview(
            titleTextResId = R.string.review_your_n_12_word_key,
            isCreateNewKeyButtonVisible = true,
            descriptionAnnotatedString = AnnotatedString(stringResId = R.string.you_stored_your_key_during),
            mnemonics = backupMnemonics.splitMnemonic()
        )
    }

    private fun updatePreviewAfterFailure(preview: AsbStoreKeyPreview?): AsbStoreKeyPreview? {
        return preview?.copy(navToFailureScreenEvent = Event(Unit))
    }
}
