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

package com.algorand.android.modules.webimport.result.ui.usecase

import com.algorand.android.R
import com.algorand.android.customviews.accountasseticonnameitem.mapper.AccountAssetIconNameConfigurationMapper
import com.algorand.android.models.AccountDetail
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.webimport.result.ui.mapper.BaseImportResultListItemMapper
import com.algorand.android.modules.webimport.result.ui.mapper.WebImportResultPreviewMapper
import com.algorand.android.modules.webimport.result.ui.model.BaseAccountResultListItem
import com.algorand.android.modules.webimport.result.ui.model.WebImportResultPreview
import com.algorand.android.usecase.AccountDetailUseCase
import javax.inject.Inject

class WebImportResultPreviewUseCase @Inject constructor(
    private val webImportResultPreviewMapper: WebImportResultPreviewMapper,
    private val baseImportResultListItemMapper: BaseImportResultListItemMapper,
    private val accountAssetIconNameConfigurationMapper: AccountAssetIconNameConfigurationMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase
) {

    fun getInitialPreview(
        importedAccountList: List<String>,
        unimportedAccountList: List<String>
    ): WebImportResultPreview {
        val isImportSuccessful = importedAccountList.isNotEmpty() || unimportedAccountList.isNotEmpty()
        val listItems = mutableListOf<BaseAccountResultListItem>().apply {
            add(getImageItem(isImportSuccessful))
            add(getTitleItem(isImportSuccessful))
            add(getDescriptionItem(isImportSuccessful, importedAccountList.size))
            if (isImportSuccessful && unimportedAccountList.isNotEmpty()) {
                add(getWarningBoxItem(unimportedAccountList.size))
            }
            importedAccountList.mapNotNull { key ->
                accountDetailUseCase.getCachedAccountDetail(key)
            }.forEach { cacheResult ->
                cacheResult.data?.let { accountDetail ->
                    add(getAccountItem(accountDetail = accountDetail))
                }
            }
        }
        return webImportResultPreviewMapper.mapToWebImportResultPreview(
            listItems = listItems,
            buttonTextRes = if (isImportSuccessful) {
                R.string.explore_pera_mobile
            } else {
                R.string.go_to_home
            }
        )
    }

    private fun getImageItem(isImportSuccessful: Boolean): BaseAccountResultListItem.ImageItem {
        return baseImportResultListItemMapper.mapToImageItem(
            drawableResId = if (isImportSuccessful) R.drawable.ic_check else R.drawable.ic_close,
            width = R.dimen.info_header_icon_size,
            height = R.dimen.info_header_icon_size,
            drawableTintResId = if (isImportSuccessful) R.color.positive else R.color.negative
        )
    }

    private fun getTitleItem(isImportSuccessful: Boolean): BaseAccountResultListItem.TextItem {
        return baseImportResultListItemMapper.mapToTextItem(
            textResId = if (isImportSuccessful) R.string.accounts_imported else R.string.something_went_wrong,
            textAppearanceResId = R.style.TextAppearance_Title_Sans_Medium
        )
    }

    private fun getDescriptionItem(
        isImportSuccessful: Boolean,
        accountsNumber: Int
    ): BaseAccountResultListItem.TextItem {
        return baseImportResultListItemMapper.mapToTextItem(
            textResId = if (isImportSuccessful) {
                R.plurals.n_accounts_were_imported_from_pera_web
            } else {
                R.string.your_accounts_could_not_be_imported
            },
            textIntParam = if (isImportSuccessful) accountsNumber else null,
            textAppearanceResId = R.style.TextAppearance_Footnote_Description
        )
    }

    private fun getWarningBoxItem(accountsNumber: Int): BaseAccountResultListItem.WarningBoxItem {
        return baseImportResultListItemMapper.mapToWarningBoxItem(
            titleResId = R.string.unimported_accounts,
            descriptionResId = R.plurals.n_accounts_were_not_imported_because,
            iconResId = R.drawable.ic_info,
            textIntParam = accountsNumber,
            titleTextAppearanceResId = R.style.TextAppearance_Footnote_Sans_Medium,
            descriptionTextAppearanceResId = R.style.TextAppearance_Footnote_Sans,
            iconColorResId = R.color.positive,
            backgroundColorResId = R.color.positive_lighter,
            textColorResId = R.color.positive
        )
    }

    private fun getAccountItem(
        accountDetail: AccountDetail
    ): BaseAccountResultListItem.AccountItem {
        return baseImportResultListItemMapper.mapToAccountItem(
            accountAssetIconNameConfiguration = accountAssetIconNameConfigurationMapper.mapTo(
                accountAddress = accountDetail.account.address,
                accountName = accountDetail.account.name,
                accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(accountDetail.account.address)
            ),
            accountAddress = accountDetail.account.address
        )
    }
}
