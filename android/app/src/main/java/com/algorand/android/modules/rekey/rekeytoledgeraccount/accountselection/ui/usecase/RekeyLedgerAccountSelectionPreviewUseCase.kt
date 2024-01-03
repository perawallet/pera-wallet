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

package com.algorand.android.modules.rekey.rekeytoledgeraccount.accountselection.ui.usecase

import com.algorand.android.R
import com.algorand.android.mapper.AccountDisplayNameMapper
import com.algorand.android.mapper.LedgerAccountSelectionAccountItemMapper
import com.algorand.android.mapper.LedgerAccountSelectionInstructionItemMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.modules.accounticon.ui.mapper.AccountIconDrawablePreviewMapper
import com.algorand.android.modules.baseledgeraccountselection.accountselection.ui.model.SearchType
import com.algorand.android.modules.rekey.rekeytoledgeraccount.accountselection.ui.mapper.RekeyLedgerAccountSelectionPreviewMapper
import com.algorand.android.modules.rekey.rekeytoledgeraccount.accountselection.ui.model.RekeyLedgerAccountSelectionPreview
import com.algorand.android.usecase.AssetFetchAndCacheUseCase
import com.algorand.android.usecase.LedgerAccountSelectionUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.extensions.addFirst
import com.algorand.android.utils.toShortenedAddress
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.onStart
import javax.inject.Inject

class RekeyLedgerAccountSelectionPreviewUseCase @Inject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val rekeyLedgerAccountSelectionPreviewMapper: RekeyLedgerAccountSelectionPreviewMapper,
    private val ledgerAccountSelectionInstructionItemMapper: LedgerAccountSelectionInstructionItemMapper,
    private val ledgerAccountSelectionAccountItemMapper: LedgerAccountSelectionAccountItemMapper,
    private val accountDisplayNameMapper: AccountDisplayNameMapper,
    private val accountIconDrawablePreviewMapper: AccountIconDrawablePreviewMapper,
    simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    assetFetchAndCacheUseCase: AssetFetchAndCacheUseCase
) : LedgerAccountSelectionUseCase(
    assetFetchAndCacheUseCase = assetFetchAndCacheUseCase,
    simpleAssetDetailUseCase = simpleAssetDetailUseCase
) {

    fun getUpdatedPreviewAccordingToAccountSelection(
        previousPreview: RekeyLedgerAccountSelectionPreview,
        accountItem: AccountSelectionListItem.AccountItem
    ): RekeyLedgerAccountSelectionPreview {
        val updatedList = previousPreview.accountSelectionListItems.map {
            if (it is AccountSelectionListItem.AccountItem) {
                it.copy(isSelected = it.account.address == accountItem.account.address)
            } else {
                it
            }
        }
        return previousPreview.copy(
            accountSelectionListItems = updatedList,
            isActionButtonEnabled = updatedList.filterIsInstance<AccountSelectionListItem.AccountItem>().any {
                it.isSelected
            }
        )
    }

    suspend fun getRekeyLedgerAccountSelectionPreview(
        ledgerAccountsInformation: Array<AccountInformation>,
        bluetoothAddress: String,
        bluetoothName: String?,
        accountAddress: String
    ) = flow {
        val ledgerAccounts = mutableListOf<AccountSelectionListItem>().apply {
            ledgerAccountsInformation.forEachIndexed { index, ledgerAccountInformation ->

                if (isAccountNotEligibleToRekey(ledgerAccountInformation, accountAddress)) return@forEachIndexed

                // Cache ledger accounts assets
                cacheLedgerAccountAssets(accountInformation = ledgerAccountInformation)
                val authAccountDetail = Account.Detail.Ledger(
                    bluetoothAddress = bluetoothAddress,
                    bluetoothName = bluetoothName,
                    positionInLedger = index
                )
                val accountDisplayName = accountDisplayNameMapper.mapToAccountDisplayName(
                    accountName = ledgerAccountInformation.address.toShortenedAddress(),
                    accountAddress = ledgerAccountInformation.address,
                    nfDomainName = null,
                    type = Account.Type.LEDGER
                )
                // Since we don't have ledger account in our local, we have to create their drawable manually
                val accountIconDrawablePreview = accountIconDrawablePreviewMapper.mapToAccountIconDrawablePreview(
                    backgroundColorResId = R.color.wallet_3,
                    iconTintResId = R.color.wallet_3_icon,
                    iconResId = R.drawable.ic_ledger
                )
                val authAccountSelectionListItem = ledgerAccountSelectionAccountItemMapper.mapTo(
                    accountInformation = ledgerAccountInformation,
                    accountDetail = authAccountDetail,
                    accountCacheManager = accountCacheManager,
                    selectorDrawableRes = R.drawable.selector_found_account_radio,
                    accountDisplayName = accountDisplayName,
                    accountIconDrawablePreview = accountIconDrawablePreview
                )
                add(authAccountSelectionListItem)
            }
            val instructionItem = ledgerAccountSelectionInstructionItemMapper.mapTo(
                accountSize = size,
                searchType = SearchType.REKEY
            )
            addFirst(instructionItem)
        }
        val preview = rekeyLedgerAccountSelectionPreviewMapper.mapToRekeyLedgerAccountSelectionPreview(
            isLoading = false,
            accountSelectionListItems = ledgerAccounts,
            isActionButtonEnabled = ledgerAccounts.filterIsInstance<AccountSelectionListItem.AccountItem>().any {
                it.isSelected
            }
        )
        emit(preview)
    }.onStart {
        val loadingState = rekeyLedgerAccountSelectionPreviewMapper.mapToRekeyLedgerAccountSelectionPreview(
            isLoading = true,
            accountSelectionListItems = emptyList(),
            isActionButtonEnabled = false
        )
        emit(loadingState)
    }.distinctUntilChanged()

    private fun isAccountNotEligibleToRekey(
        ledgerAccountInformation: AccountInformation,
        accountAddress: String
    ): Boolean {
        // To prevent chain rekey, we shouldn't display rekeyed ledger accounts
        val isRekeyed = ledgerAccountInformation.isRekeyed()
        // Don't show the same ledger account in the rekey list
        val isTheSameAccount = accountAddress == ledgerAccountInformation.address
        return isRekeyed || isTheSameAccount
    }
}
