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

package com.algorand.android.modules.asb.importbackup.accountrestoreresult.ui.usecase

import com.algorand.android.R
import com.algorand.android.core.AccountManager
import com.algorand.android.mapper.AccountDisplayNameMapper
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.PluralAnnotatedString
import com.algorand.android.modules.asb.importbackup.accountrestoreresult.ui.mapper.AsbAccountRestoreResultPreviewMapper
import com.algorand.android.modules.asb.importbackup.accountrestoreresult.ui.model.AsbAccountRestoreResultPreview
import com.algorand.android.modules.asb.importbackup.accountselection.ui.model.AsbAccountImportResult
import com.algorand.android.modules.baseresult.ui.mapper.ResultListItemMapper
import com.algorand.android.modules.baseresult.ui.model.ResultListItem
import com.algorand.android.modules.baseresult.ui.usecase.BaseResultPreviewUseCase
import com.algorand.android.utils.toShortenedAddress
import javax.inject.Inject

class AsbAccountRestoreResultPreviewUseCase @Inject constructor(
    private val asbAccountRestoreResultPreviewMapper: AsbAccountRestoreResultPreviewMapper,
    private val accountManager: AccountManager,
    private val accountDisplayNameMapper: AccountDisplayNameMapper,
    resultListItemMapper: ResultListItemMapper
) : BaseResultPreviewUseCase(resultListItemMapper) {

    fun getAsbAccountRestoreResultPreview(
        asbAccountImportResult: AsbAccountImportResult
    ): AsbAccountRestoreResultPreview {
        val importedAccountSize = asbAccountImportResult.importedAccountList.size

        val iconItem = createIconItem(
            iconTintColorResId = R.color.link_icon,
            iconResId = R.drawable.ic_check
        )
        val titleItem = createPluralTitleItem(
            titleTextResId = R.plurals.accounts_restored,
            quantity = importedAccountSize
        )
        val descriptionItem = createPluralDescriptionItem(
            pluralAnnotatedString = PluralAnnotatedString(R.plurals.accounts_were_restored, importedAccountSize),
            isClickable = false
        )
        val infoItem = createInfoBoxItemIfNeeded(
            unsupportedAccountCount = asbAccountImportResult.unsupportedAccountList.size,
            existingAccountCount = asbAccountImportResult.existingAccountList.size
        )
        val accountItems = asbAccountImportResult.importedAccountList.map { accountAddress ->
            val account = accountManager.getAccount(accountAddress)
            // Since these accounts are not cached, we have to create [AccountDisplayName] model by using
            // mapper instead of using `AccountDisplayNameUseCase`
            val accountDisplayName = accountDisplayNameMapper.mapToAccountDisplayName(
                accountAddress = accountAddress,
                accountName = account?.name.orEmpty().ifBlank { accountAddress.toShortenedAddress() },
                nfDomainName = null,
                type = account?.type
            )
            createAccountItem(
                accountDisplayName = accountDisplayName,
                accountIconResource = AccountIconResource.getAccountIconResourceByAccountType(
                    accountType = account?.type
                )
            )
        }
        val resultItemList = mutableListOf<ResultListItem>().apply {
            add(iconItem)
            add(titleItem)
            add(descriptionItem)
            if (infoItem != null) add(infoItem)
            addAll(accountItems)
        }
        return asbAccountRestoreResultPreviewMapper.mapToAsbAccountRestoreResultPreview(
            resultListItems = resultItemList
        )
    }

    private fun createInfoBoxItemIfNeeded(
        existingAccountCount: Int,
        unsupportedAccountCount: Int
    ): ResultListItem.InfoBoxItem? {
        val infoDescriptionAnnotatedString = when {
            existingAccountCount > 0 && unsupportedAccountCount > 0 -> {
                PluralAnnotatedString(
                    pluralStringResId = R.plurals.account_was_not_restored,
                    quantity = existingAccountCount + unsupportedAccountCount
                )
            }
            existingAccountCount > 0 -> {
                PluralAnnotatedString(
                    pluralStringResId = R.plurals.account_was_not_restored_because_exist,
                    quantity = existingAccountCount
                )
            }
            unsupportedAccountCount > 0 -> {
                PluralAnnotatedString(
                    pluralStringResId = R.plurals.account_was_not_restored_because_unsupported,
                    quantity = unsupportedAccountCount
                )
            }
            else -> return null
        }
        return createPluralInfoBoxItem(
            infoIconResId = R.drawable.ic_info,
            infoIconTintResId = R.color.positive,
            infoTitleTextResId = R.string.unimported_accounts,
            infoTitleTintResId = R.color.positive,
            infoDescriptionPluralAnnotatedString = infoDescriptionAnnotatedString,
            infoDescriptionTintResId = R.color.positive,
            infoBoxTintColorResId = R.color.positive_lighter
        )
    }
}
