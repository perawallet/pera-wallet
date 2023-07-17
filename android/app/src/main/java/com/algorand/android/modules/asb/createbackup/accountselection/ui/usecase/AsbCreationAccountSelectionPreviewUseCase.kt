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

package com.algorand.android.modules.asb.createbackup.accountselection.ui.usecase

import com.algorand.android.R
import com.algorand.android.customviews.TriStatesCheckBox
import com.algorand.android.customviews.accountandassetitem.mapper.AccountItemConfigurationMapper
import com.algorand.android.models.ScreenState
import com.algorand.android.models.ui.AccountAssetItemButtonState.CHECKED
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.asb.createbackup.accountselection.ui.mapper.AsbCreationAccountSelectionPreviewMapper
import com.algorand.android.modules.asb.createbackup.accountselection.ui.model.AsbCreationAccountSelectionPreview
import com.algorand.android.modules.asb.util.AlgorandSecureBackupUtils
import com.algorand.android.modules.basemultipleaccountselection.ui.mapper.MultipleAccountSelectionListItemMapper
import com.algorand.android.modules.basemultipleaccountselection.ui.model.MultipleAccountSelectionListItem
import com.algorand.android.modules.basemultipleaccountselection.ui.usecase.BaseMultipleAccountSelectionPreviewUseCase
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.AccountSortPreferenceUseCase
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.GetSortedAccountsByPreferenceUseCase
import com.algorand.android.utils.Event
import javax.inject.Inject

class AsbCreationAccountSelectionPreviewUseCase @Inject constructor(
    private val asbCreationAccountSelectionPreviewMapper: AsbCreationAccountSelectionPreviewMapper,
    multipleAccountSelectionListItemMapper: MultipleAccountSelectionListItemMapper,
    getSortedAccountsByPreferenceUseCase: GetSortedAccountsByPreferenceUseCase,
    accountSortPreferenceUseCase: AccountSortPreferenceUseCase,
    accountItemConfigurationMapper: AccountItemConfigurationMapper,
    accountDisplayNameUseCase: AccountDisplayNameUseCase,
    createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase
) : BaseMultipleAccountSelectionPreviewUseCase(
    multipleAccountSelectionListItemMapper = multipleAccountSelectionListItemMapper,
    getSortedAccountsByPreferenceUseCase = getSortedAccountsByPreferenceUseCase,
    accountSortPreferenceUseCase = accountSortPreferenceUseCase,
    accountItemConfigurationMapper = accountItemConfigurationMapper,
    accountDisplayNameUseCase = accountDisplayNameUseCase,
    createAccountIconDrawableUseCase = createAccountIconDrawableUseCase
) {

    fun getInitialPreview(): AsbCreationAccountSelectionPreview {
        val titleItem = createTitleItem(textResId = R.string.choose_accounts_n_to_backup)
        return asbCreationAccountSelectionPreviewMapper.mapToMultipleAccountSelectionPreview(
            multipleAccountSelectionList = listOf(titleItem),
            isActionButtonEnabled = false,
            actionButtonTextResId = R.string.backup_accounts,
            isLoadingVisible = true,
            checkedAccountCount = 0
        )
    }

    suspend fun getAsbCreationAccountSelectionPreview(): AsbCreationAccountSelectionPreview {
        val titleItem = createTitleItem(textResId = R.string.choose_accounts_n_to_backup)
        val accountItemList = createAccountItemList(AlgorandSecureBackupUtils.excludedAccountTypes).ifEmpty {
            val emptyScreenState = ScreenState.CustomState(
                title = R.string.we_couldn_t_find_any_accounts
            )
            return asbCreationAccountSelectionPreviewMapper.mapToMultipleAccountSelectionPreview(
                multipleAccountSelectionList = listOf(titleItem),
                isActionButtonEnabled = false,
                actionButtonTextResId = R.string.backup_accounts,
                isLoadingVisible = false,
                checkedAccountCount = 0,
                emptyScreenState = emptyScreenState
            )
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
        return asbCreationAccountSelectionPreviewMapper.mapToMultipleAccountSelectionPreview(
            multipleAccountSelectionList = multipleAccountSelectionList,
            isActionButtonEnabled = true,
            actionButtonTextResId = R.string.backup_accounts,
            isLoadingVisible = false,
            checkedAccountCount = accountSize
        )
    }

    fun updatePreviewAfterHeaderCheckBoxClicked(
        preview: AsbCreationAccountSelectionPreview
    ): AsbCreationAccountSelectionPreview {
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
        preview: AsbCreationAccountSelectionPreview,
        accountAddress: String
    ): AsbCreationAccountSelectionPreview {
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

    fun updatePreviewAfterActionButtonClicked(
        preview: AsbCreationAccountSelectionPreview
    ): AsbCreationAccountSelectionPreview {
        val selectedAccountList = getSelectedAccountAddressList(preview.multipleAccountSelectionList)
        return preview.copy(navToStoreKeyEvent = Event(selectedAccountList))
    }
}
