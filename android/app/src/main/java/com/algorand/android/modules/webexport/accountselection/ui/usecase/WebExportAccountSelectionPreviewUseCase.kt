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

package com.algorand.android.modules.webexport.accountselection.ui.usecase

import androidx.annotation.DimenRes
import com.algorand.android.R
import com.algorand.android.customviews.TriStatesCheckBox
import com.algorand.android.customviews.TriStatesCheckBox.CheckBoxState.CHECKED
import com.algorand.android.customviews.TriStatesCheckBox.CheckBoxState.PARTIAL_CHECKED
import com.algorand.android.customviews.TriStatesCheckBox.CheckBoxState.UNCHECKED
import com.algorand.android.customviews.accountasseticonnameitem.mapper.AccountAssetIconNameConfigurationMapper
import com.algorand.android.models.AccountDetail
import com.algorand.android.modules.webexport.accountselection.ui.mapper.BaseAccountMultipleSelectionListItemMapper
import com.algorand.android.modules.webexport.accountselection.ui.mapper.WebExportAccountSelectionPreviewMapper
import com.algorand.android.modules.webexport.accountselection.ui.model.BaseAccountMultipleSelectionListItem
import com.algorand.android.modules.webexport.accountselection.ui.model.BaseAccountMultipleSelectionListItem.AccountItem
import com.algorand.android.modules.webexport.accountselection.ui.model.BaseAccountMultipleSelectionListItem.HeaderItem
import com.algorand.android.modules.webexport.accountselection.ui.model.WebExportAccountSelectionPreview
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.GetIsActiveNodeTestnetUseCase
import com.algorand.android.utils.Event
import javax.inject.Inject

class WebExportAccountSelectionPreviewUseCase @Inject constructor(
    private val webExportAccountSelectionPreviewMapper: WebExportAccountSelectionPreviewMapper,
    private val baseAccountMultipleSelectionListItemMapper: BaseAccountMultipleSelectionListItemMapper,
    private val accountAssetIconNameConfigurationMapper: AccountAssetIconNameConfigurationMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val getIsActiveNodeTestnetUseCase: GetIsActiveNodeTestnetUseCase
) {

    fun getInitialPreview(): WebExportAccountSelectionPreview {
        return webExportAccountSelectionPreviewMapper.mapTo(
            isContinueButtonEnabled = false,
            listItems = emptyList(),
            isLoadingStateVisible = true,
            isEmptyStateVisible = false,
            isSingleAccountItem = false,
            activeNodeIsTestnetErrorEvent = getActiveNodeIsTestnetErrorEvent()
        )
    }

    fun getWebExportAccountSelectionPreview(): WebExportAccountSelectionPreview {
        val cachedStandardAccounts = accountDetailUseCase.getCachedStandardAccountDetails()
        val listItems = mutableListOf<BaseAccountMultipleSelectionListItem>().apply {
            add(getTitleItem())
            add(getWarningDescriptionItem())
            add(getDescriptionItem())
            add(getHeaderItem(cachedStandardAccounts.size))
            cachedStandardAccounts.forEachIndexed { index, cacheResult ->
                cacheResult.data?.let { accountDetail ->
                    val topMarginResId = if (index == 0) R.dimen.spacing_large else R.dimen.spacing_xxsmall
                    add(
                        getAccountItem(
                            accountDetail = accountDetail,
                            isChecked = true,
                            topMarginResId = topMarginResId
                        )
                    )
                }
            }
        }

        val isSingleAccountItem = cachedStandardAccounts.size == 1
        return webExportAccountSelectionPreviewMapper.mapTo(
            isContinueButtonEnabled = isSingleAccountItem || listItems.any { (it as? AccountItem)?.isChecked == true },
            listItems = listItems,
            isLoadingStateVisible = false,
            isEmptyStateVisible = cachedStandardAccounts.isEmpty(),
            isSingleAccountItem = isSingleAccountItem,
            activeNodeIsTestnetErrorEvent = getActiveNodeIsTestnetErrorEvent()
        )
    }

    private fun getTitleItem(): BaseAccountMultipleSelectionListItem.TextItem {
        return baseAccountMultipleSelectionListItemMapper.mapToTextItem(
            textResId = R.string.export_to_pera_web,
            textAppearanceResId = R.style.TextAppearance_Title_Sans_Medium,
            topMarginResId = R.dimen.spacing_small
        )
    }

    private fun getWarningDescriptionItem(): BaseAccountMultipleSelectionListItem.TextItem {
        return baseAccountMultipleSelectionListItemMapper.mapToTextItem(
            textResId = R.string.you_re_about_to_share,
            textAppearanceResId = R.style.TextAppearance_Body_Sans_Medium,
            textColorRestId = R.color.negative,
            topMarginResId = R.dimen.spacing_normal
        )
    }

    private fun getDescriptionItem(): BaseAccountMultipleSelectionListItem.TextItem {
        return baseAccountMultipleSelectionListItemMapper.mapToTextItem(
            textResId = R.string.do_not_proceed_if_you,
            textAppearanceResId = R.style.TextAppearance_Footnote_Description,
            topMarginResId = R.dimen.spacing_xxsmall
        )
    }

    private fun getHeaderItem(accountCount: Int): HeaderItem {
        return baseAccountMultipleSelectionListItemMapper.mapToHeaderItem(
            titleRes = R.plurals.account_count,
            accountCount = accountCount,
            checkboxState = CHECKED,
            topMarginResId = R.dimen.spacing_xxxxlarge
        )
    }

    private fun getAccountItem(
        accountDetail: AccountDetail,
        isChecked: Boolean,
        @DimenRes topMarginResId: Int
    ): AccountItem {
        return baseAccountMultipleSelectionListItemMapper.mapToAccountItem(
            accountAssetIconNameConfiguration = accountAssetIconNameConfigurationMapper.mapTo(accountDetail),
            topMarginResId = topMarginResId,
            isChecked = isChecked,
            accountAddress = accountDetail.account.address
        )
    }

    fun updatePreviewWithCheckBoxClickEvent(
        currentCheckBoxState: TriStatesCheckBox.CheckBoxState,
        previousState: WebExportAccountSelectionPreview
    ): WebExportAccountSelectionPreview {
        val newCheckBoxState = when (currentCheckBoxState) {
            UNCHECKED -> CHECKED
            CHECKED -> UNCHECKED
            PARTIAL_CHECKED -> CHECKED
        }
        val updatedList = previousState.listItems.map { item ->
            when (item) {
                is HeaderItem -> item.copy(checkboxState = newCheckBoxState)
                is AccountItem -> {
                    when (newCheckBoxState) {
                        CHECKED -> item.copy(isChecked = true)
                        UNCHECKED -> item.copy(isChecked = false)
                        else -> item
                    }
                }
                else -> item
            }
        }
        return previousState.copy(listItems = updatedList, isContinueButtonEnabled = newCheckBoxState != UNCHECKED)
    }

    fun updatePreviewWithAccountClicked(
        accountAddress: String,
        previousState: WebExportAccountSelectionPreview
    ): WebExportAccountSelectionPreview {
        var updatedList = previousState.listItems.map { item ->
            when (item) {
                is AccountItem -> if (item.address == accountAddress) {
                    item.copy(isChecked = item.isChecked.not())
                } else {
                    item
                }
                else -> item
            }
        }

        val updatedAccountItems = updatedList.filterIsInstance<AccountItem>()
        val areAllAccountsChecked = updatedAccountItems.all { it.isChecked }
        val areAllAccountsUnchecked = updatedAccountItems.all { it.isChecked.not() }
        updatedList = when {
            areAllAccountsChecked -> updatedList.map { if (it is HeaderItem) it.copy(checkboxState = CHECKED) else it }
            areAllAccountsUnchecked ->
                updatedList.map { if (it is HeaderItem) it.copy(checkboxState = UNCHECKED) else it }
            else -> updatedList.map { if (it is HeaderItem) it.copy(checkboxState = PARTIAL_CHECKED) else it }
        }
        return previousState.copy(
            listItems = updatedList,
            isContinueButtonEnabled = areAllAccountsUnchecked.not()
        )
    }

    fun getAllSelectedAccountAddressList(preview: WebExportAccountSelectionPreview): List<String> {
        return preview.listItems.mapNotNull { item ->
            if (item is AccountItem) item.address.takeIf { item.isChecked } else null
        }
    }

    private fun getActiveNodeIsTestnetErrorEvent(): Event<Unit>? {
        return if (getIsActiveNodeTestnetUseCase.invoke()) Event(Unit) else null
    }
}
