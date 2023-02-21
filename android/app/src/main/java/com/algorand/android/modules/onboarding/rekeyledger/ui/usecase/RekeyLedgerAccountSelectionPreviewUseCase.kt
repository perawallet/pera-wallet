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

package com.algorand.android.modules.onboarding.rekeyledger.ui.usecase

import com.algorand.android.R
import com.algorand.android.mapper.LedgerAccountSelectionAccountItemMapper
import com.algorand.android.mapper.LedgerAccountSelectionInstructionItemMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.modules.onboarding.rekeyledger.ui.mapper.RekeyLedgerAccountSelectionPreviewMapper
import com.algorand.android.modules.onboarding.rekeyledger.ui.model.RekeyLedgerAccountSelectionPreview
import com.algorand.android.ui.ledgeraccountselection.SearchType
import com.algorand.android.usecase.AssetFetchAndCacheUseCase
import com.algorand.android.usecase.LedgerAccountSelectionUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.AccountCacheManager
import javax.inject.Inject
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.onStart

class RekeyLedgerAccountSelectionPreviewUseCase @Inject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val rekeyLedgerAccountSelectionPreviewMapper: RekeyLedgerAccountSelectionPreviewMapper,
    private val ledgerAccountSelectionInstructionItemMapper: LedgerAccountSelectionInstructionItemMapper,
    private val ledgerAccountSelectionAccountItemMapper: LedgerAccountSelectionAccountItemMapper,
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
        bluetoothName: String?
    ) = flow {
        val ledgerAccounts = mutableListOf<AccountSelectionListItem>().apply {
            val instructionItem = ledgerAccountSelectionInstructionItemMapper.mapTo(
                accountSize = ledgerAccountsInformation.size,
                searchType = SearchType.REGISTER
            )
            add(instructionItem)
            ledgerAccountsInformation.forEachIndexed { index, ledgerAccountInformation ->
                // Cache ledger accounts assets
                cacheLedgerAccountAssets(accountInformation = ledgerAccountInformation)
                val authAccountDetail = Account.Detail.Ledger(
                    bluetoothAddress = bluetoothAddress,
                    bluetoothName = bluetoothName,
                    positionInLedger = index
                )
                val authAccountSelectionListItem = ledgerAccountSelectionAccountItemMapper.mapTo(
                    accountInformation = ledgerAccountInformation,
                    accountDetail = authAccountDetail,
                    accountCacheManager = accountCacheManager,
                    selectorDrawableRes = R.drawable.radio_selector
                )
                add(authAccountSelectionListItem)
            }
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
}
