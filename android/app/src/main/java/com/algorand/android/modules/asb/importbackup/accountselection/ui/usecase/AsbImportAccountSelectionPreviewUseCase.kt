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

package com.algorand.android.modules.asb.importbackup.accountselection.ui.usecase

import com.algorand.android.R
import com.algorand.android.customviews.TriStatesCheckBox
import com.algorand.android.customviews.accountandassetitem.mapper.AccountItemConfigurationMapper
import com.algorand.android.mapper.AccountDisplayNameMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.ScreenState
import com.algorand.android.models.ui.AccountAssetItemButtonState.CHECKED
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.asb.importbackup.accountselection.ui.mapper.AsbImportAccountSelectionPreviewMapper
import com.algorand.android.modules.asb.importbackup.accountselection.ui.model.AsbImportAccountSelectionPreview
import com.algorand.android.modules.asb.importbackup.accountselection.utils.AsbAccountImportParser
import com.algorand.android.modules.backupprotocol.model.BackupProtocolElement
import com.algorand.android.modules.basemultipleaccountselection.ui.mapper.MultipleAccountSelectionListItemMapper
import com.algorand.android.modules.basemultipleaccountselection.ui.model.MultipleAccountSelectionListItem
import com.algorand.android.modules.basemultipleaccountselection.ui.usecase.BaseMultipleAccountSelectionPreviewUseCase
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.AccountSortPreferenceUseCase
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.GetSortedAccountsByPreferenceUseCase
import com.algorand.android.usecase.AccountAdditionUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.analytics.CreationType
import com.algorand.android.utils.extensions.decodeBase64ToByteArray
import com.algorand.android.utils.toShortenedAddress
import javax.inject.Inject
import kotlinx.coroutines.flow.flow

class AsbImportAccountSelectionPreviewUseCase @Inject constructor(
    private val asbImportAccountSelectionPreviewMapper: AsbImportAccountSelectionPreviewMapper,
    private val multipleAccountSelectionListItemMapper: MultipleAccountSelectionListItemMapper,
    private val asbAccountImportParser: AsbAccountImportParser,
    private val accountDisplayNameMapper: AccountDisplayNameMapper,
    private val accountAdditionUseCase: AccountAdditionUseCase,
    accountDisplayNameUseCase: AccountDisplayNameUseCase,
    getSortedAccountsByPreferenceUseCase: GetSortedAccountsByPreferenceUseCase,
    accountSortPreferenceUseCase: AccountSortPreferenceUseCase,
    accountItemConfigurationMapper: AccountItemConfigurationMapper
) : BaseMultipleAccountSelectionPreviewUseCase(
    multipleAccountSelectionListItemMapper = multipleAccountSelectionListItemMapper,
    getSortedAccountsByPreferenceUseCase = getSortedAccountsByPreferenceUseCase,
    accountSortPreferenceUseCase = accountSortPreferenceUseCase,
    accountItemConfigurationMapper = accountItemConfigurationMapper,
    accountDisplayNameUseCase = accountDisplayNameUseCase
) {
    fun getInitialPreview(): AsbImportAccountSelectionPreview {
        val titleItem = createTitleItem(textResId = R.string.choose_accounts_n_to_restore)
        return asbImportAccountSelectionPreviewMapper.mapToAsbImportAccountSelectionPreview(
            multipleAccountSelectionList = listOf(titleItem),
            isActionButtonEnabled = false,
            actionButtonTextResId = R.string.restore_account,
            isLoadingVisible = true,
            checkedAccountCount = 0,
            unsupportedAccounts = null
        )
    }

    fun updatePreviewAfterHeaderCheckBoxClicked(
        preview: AsbImportAccountSelectionPreview
    ): AsbImportAccountSelectionPreview {
        val currentHeaderCheckBoxState = preview.multipleAccountSelectionList.firstOrNull {
            it is MultipleAccountSelectionListItem.AccountHeaderItem
        } as? MultipleAccountSelectionListItem.AccountHeaderItem

        val newMultipleAccountSelectionList = updateListItemAfterHeaderCheckBoxClicked(
            currentHeaderCheckBoxState = currentHeaderCheckBoxState?.checkboxState,
            multipleAccountSelectionList = preview.multipleAccountSelectionList
        )
        val checkedAccountCount = newMultipleAccountSelectionList.count {
            it is MultipleAccountSelectionListItem.AccountItem && it.accountViewButtonState == CHECKED
        }

        return preview.copy(
            multipleAccountSelectionList = newMultipleAccountSelectionList,
            isActionButtonEnabled = checkedAccountCount > 0,
            checkedAccountCount = checkedAccountCount,
        )
    }

    fun updatePreviewAfterAccountCheckBoxClicked(
        preview: AsbImportAccountSelectionPreview,
        accountAddress: String
    ): AsbImportAccountSelectionPreview {
        val multipleAccountSelectionList = preview.multipleAccountSelectionList
        val newMultipleAccountSelectionList = updateListItemAfterAccountCheckBoxClicked(
            multipleAccountSelectionList = multipleAccountSelectionList,
            accountAddress = accountAddress
        )
        val checkedAccountCount = newMultipleAccountSelectionList.count {
            it is MultipleAccountSelectionListItem.AccountItem && it.accountViewButtonState == CHECKED
        }
        return preview.copy(
            multipleAccountSelectionList = newMultipleAccountSelectionList,
            isActionButtonEnabled = checkedAccountCount > 0,
            checkedAccountCount = checkedAccountCount,
        )
    }

    fun updatePreviewWithRestoredAccounts(
        preview: AsbImportAccountSelectionPreview,
        backupProtocolElements: Array<BackupProtocolElement>
    ) = flow {
        emit(preview.copy(isLoadingVisible = true))
        val selectedAccounts = getSelectedAccountAddressList(preview.multipleAccountSelectionList)
        val accountImportMap = selectedAccounts.mapNotNull { address ->
            address to (backupProtocolElements.firstOrNull { it.address == address } ?: return@mapNotNull null)
        }
        val accountImportResult = asbAccountImportParser.parseAsbImportedAccounts(
            accountImportMap = accountImportMap,
            unsupportedAccounts = preview.unsupportedAccounts
        )

        accountImportResult.importedAccountList.forEach { accountAddress ->
            val importedAccount = backupProtocolElements.firstOrNull { it.address == accountAddress }
            addImportedAccount(importedAccount)
        }

        val successPreview = preview.copy(
            navToRestoreCompleteEvent = Event(accountImportResult),
            isLoadingVisible = false
        )
        emit(successPreview)
    }

    suspend fun getAsbImportAccountSelectionPreview(
        preview: AsbImportAccountSelectionPreview,
        backupProtocolElements: Array<BackupProtocolElement>
    ): AsbImportAccountSelectionPreview {
        val titleItem = createTitleItem(textResId = R.string.choose_accounts_n_to_restore)

        val supportedAccounts = mutableListOf<BackupProtocolElement>()
        val unsupportedAccounts = mutableListOf<BackupProtocolElement>()
        backupProtocolElements.forEach { payload ->
            val isAccountSupported = asbAccountImportParser.isAccountSupported(payload)
            if (isAccountSupported) {
                supportedAccounts.add(payload)
            } else {
                unsupportedAccounts.add(payload)
            }
        }

        if (supportedAccounts.isEmpty()) {
            val emptyScreenState = ScreenState.CustomState(title = R.string.we_couldn_t_find_any_accounts)
            return preview.copy(isLoadingVisible = false, emptyScreenState = emptyScreenState)
        }

        val accountItemList = createAccountItemListByPayload(supportedAccounts)
        if (accountItemList.isEmpty()) {
            val emptyScreenState = ScreenState.CustomState(title = R.string.we_couldn_t_find_any_accounts)
            return preview.copy(isLoadingVisible = false, emptyScreenState = emptyScreenState)
        }

        val accountSize = accountItemList.size
        val accountHeaderItem = createAccountHeaderItem(
            titleRes = R.plurals.account_count,
            accountCount = accountSize,
            checkboxState = TriStatesCheckBox.CheckBoxState.CHECKED
        )
        val multipleAccountSelectionList = mutableListOf<MultipleAccountSelectionListItem>().apply {
            add(titleItem)
            add(accountHeaderItem)
            addAll(accountItemList)
        }
        return preview.copy(
            multipleAccountSelectionList = multipleAccountSelectionList,
            isActionButtonEnabled = true,
            isLoadingVisible = false,
            checkedAccountCount = accountSize,
            unsupportedAccounts = unsupportedAccounts
        )
    }

    private fun createAccountItemListByPayload(
        backupProtocolElements: List<BackupProtocolElement>
    ): List<MultipleAccountSelectionListItem.AccountItem> {
        return backupProtocolElements.mapNotNull { payload ->
            val safeAccountType = Account.Type.valueOf(payload.accountType ?: return@mapNotNull null)
            // Since these accounts are not saved in local, we have to create [AccountDisplayName] model by using
            // mapper instead of using `AccountDisplayNameUseCase`
            val accountDisplayName = accountDisplayNameMapper.mapToAccountDisplayName(
                accountAddress = payload.address ?: return@mapNotNull null,
                accountName = payload.name,
                nfDomainName = null,
                type = safeAccountType
            )
            val accountIconResource = AccountIconResource.getAccountIconResourceByAccountType(safeAccountType)
            multipleAccountSelectionListItemMapper.mapToAccountItem(
                accountDisplayName = accountDisplayName,
                accountIconResource = accountIconResource,
                accountViewButtonState = CHECKED
            )
        }
    }

    private suspend fun addImportedAccount(importedAccount: BackupProtocolElement?) {
        if (importedAccount == null) return
        val safeAccountAddress = importedAccount.address ?: return
        val safeAccountPrivateKey = importedAccount.privateKey?.decodeBase64ToByteArray() ?: return
        val safeAccountName = importedAccount.name.orEmpty().ifBlank { safeAccountAddress.toShortenedAddress() }
        val recoveredAccount = Account.create(
            publicKey = safeAccountAddress,
            detail = Account.Detail.Standard(safeAccountPrivateKey),
            accountName = safeAccountName
        )
        accountAdditionUseCase.addNewAccount(recoveredAccount, CreationType.RECOVER)
    }
}
