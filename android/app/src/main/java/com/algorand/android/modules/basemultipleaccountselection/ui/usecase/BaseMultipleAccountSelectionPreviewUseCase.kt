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

package com.algorand.android.modules.basemultipleaccountselection.ui.usecase

import androidx.annotation.PluralsRes
import androidx.annotation.StringRes
import com.algorand.android.customviews.TriStatesCheckBox
import com.algorand.android.customviews.accountandassetitem.mapper.AccountItemConfigurationMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.ui.AccountAssetItemButtonState.CHECKED
import com.algorand.android.models.ui.AccountAssetItemButtonState.UNCHECKED
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.basemultipleaccountselection.ui.mapper.MultipleAccountSelectionListItemMapper
import com.algorand.android.modules.basemultipleaccountselection.ui.model.MultipleAccountSelectionListItem
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.AccountSortPreferenceUseCase
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.GetSortedAccountsByPreferenceUseCase

open class BaseMultipleAccountSelectionPreviewUseCase constructor(
    private val multipleAccountSelectionListItemMapper: MultipleAccountSelectionListItemMapper,
    private val getSortedAccountsByPreferenceUseCase: GetSortedAccountsByPreferenceUseCase,
    private val accountSortPreferenceUseCase: AccountSortPreferenceUseCase,
    private val accountItemConfigurationMapper: AccountItemConfigurationMapper,
    private val accountDisplayNameUseCase: AccountDisplayNameUseCase
) {

    protected fun getSelectedAccountAddressList(
        multipleAccountSelectionList: List<MultipleAccountSelectionListItem>
    ): List<String> {
        return multipleAccountSelectionList.mapNotNull {
            if (it is MultipleAccountSelectionListItem.AccountItem && it.accountViewButtonState == CHECKED) {
                it.accountDisplayName.getRawAccountAddress()
            } else {
                null
            }
        }
    }

    protected fun updateListItemAfterHeaderCheckBoxClicked(
        currentHeaderCheckBoxState: TriStatesCheckBox.CheckBoxState?,
        multipleAccountSelectionList: List<MultipleAccountSelectionListItem>
    ): List<MultipleAccountSelectionListItem> {
        val headerCheckBoxState = when (currentHeaderCheckBoxState) {
            TriStatesCheckBox.CheckBoxState.UNCHECKED -> TriStatesCheckBox.CheckBoxState.CHECKED
            TriStatesCheckBox.CheckBoxState.CHECKED -> TriStatesCheckBox.CheckBoxState.UNCHECKED
            TriStatesCheckBox.CheckBoxState.PARTIAL_CHECKED -> TriStatesCheckBox.CheckBoxState.CHECKED
            else -> TriStatesCheckBox.CheckBoxState.UNCHECKED
        }
        val accountItemCheckBoxState = if (headerCheckBoxState == TriStatesCheckBox.CheckBoxState.CHECKED) {
            CHECKED
        } else {
            UNCHECKED
        }
        return multipleAccountSelectionList.map { item ->
            when (item) {
                is MultipleAccountSelectionListItem.AccountItem -> {
                    item.copy(accountViewButtonState = accountItemCheckBoxState)
                }
                is MultipleAccountSelectionListItem.AccountHeaderItem -> {
                    item.copy(checkboxState = headerCheckBoxState)
                }
                else -> item
            }
        }
    }

    protected fun updateListItemAfterAccountCheckBoxClicked(
        accountAddress: String,
        multipleAccountSelectionList: List<MultipleAccountSelectionListItem>
    ): List<MultipleAccountSelectionListItem> {
        val updateAccountList = multipleAccountSelectionList.map { item ->
            when (item) {
                is MultipleAccountSelectionListItem.AccountItem -> {
                    if (item.accountDisplayName.getRawAccountAddress() == accountAddress) {
                        val checkBoxState = if (item.accountViewButtonState == CHECKED) UNCHECKED else CHECKED
                        item.copy(accountViewButtonState = checkBoxState)
                    } else {
                        item
                    }
                }
                else -> item
            }
        }
        val accountItems = updateAccountList.filterIsInstance<MultipleAccountSelectionListItem.AccountItem>()
        val areAllAccountsChecked = accountItems.all { it.accountViewButtonState == CHECKED }
        val areAllAccountsUnchecked = accountItems.all { it.accountViewButtonState == UNCHECKED }
        val headerCheckBoxState = when {
            areAllAccountsChecked -> TriStatesCheckBox.CheckBoxState.CHECKED
            areAllAccountsUnchecked -> TriStatesCheckBox.CheckBoxState.UNCHECKED
            else -> TriStatesCheckBox.CheckBoxState.PARTIAL_CHECKED
        }
        return updateAccountList.map {
            if (it is MultipleAccountSelectionListItem.AccountHeaderItem) {
                it.copy(checkboxState = headerCheckBoxState)
            } else {
                it
            }
        }
    }

    protected fun createTitleItem(
        @StringRes textResId: Int
    ): MultipleAccountSelectionListItem.TitleItem {
        return multipleAccountSelectionListItemMapper.mapToTitleItem(textResId = textResId)
    }

    protected fun createDescriptionItem(
        annotatedString: AnnotatedString
    ): MultipleAccountSelectionListItem.DescriptionItem {
        return multipleAccountSelectionListItemMapper.mapToDescriptionItem(
            annotatedString = annotatedString
        )
    }

    protected fun createAccountHeaderItem(
        @PluralsRes titleRes: Int,
        accountCount: Int,
        checkboxState: TriStatesCheckBox.CheckBoxState,
    ): MultipleAccountSelectionListItem.AccountHeaderItem {
        return multipleAccountSelectionListItemMapper.mapToAccountHeaderItem(
            titleRes = titleRes,
            accountCount = accountCount,
            checkboxState = checkboxState
        )
    }

    protected suspend fun createAccountItemList(
        excludedAccountTypes: List<Account.Type>
    ): List<MultipleAccountSelectionListItem.AccountItem> {
        return getSortedAccountsByPreferenceUseCase.getSortedAccountListItems(
            sortingPreferences = accountSortPreferenceUseCase.getAccountSortPreference(),
            excludedAccountTypes = excludedAccountTypes,
            onLoadedAccountConfiguration = {
                accountItemConfigurationMapper.mapTo(
                    accountAddress = account.address,
                    accountDisplayName = accountDisplayNameUseCase.invoke(account.address),
                    accountIconResource = AccountIconResource.getAccountIconResourceByAccountType(account.type),
                    accountType = account.type,
                    showWarningIcon = true
                )
            },
            onFailedAccountConfiguration = {
                if (this == null) return@getSortedAccountListItems null
                accountItemConfigurationMapper.mapTo(
                    accountDisplayName = accountDisplayNameUseCase.invoke(address),
                    accountAddress = address,
                    accountType = type,
                    accountIconResource = AccountIconResource.getAccountIconResourceByAccountType(type)
                )
            }
        ).mapNotNull { accountListItem ->
            multipleAccountSelectionListItemMapper.mapToAccountItem(
                accountDisplayName = accountListItem.itemConfiguration.accountDisplayName ?: return@mapNotNull null,
                accountIconResource = accountListItem.itemConfiguration.accountIconResource ?: return@mapNotNull null,
                accountViewButtonState = CHECKED
            )
        }
    }
}
