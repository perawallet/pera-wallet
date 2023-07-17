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

package com.algorand.android.modules.onboarding.pairledger.accountselection.ui.usecase

import com.algorand.android.R
import com.algorand.android.mapper.AccountDisplayNameMapper
import com.algorand.android.mapper.AccountInformationMapper
import com.algorand.android.mapper.LedgerAccountSelectionAccountItemMapper
import com.algorand.android.mapper.LedgerAccountSelectionInstructionItemMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.models.AccountsResponse
import com.algorand.android.modules.accounticon.ui.mapper.AccountIconDrawablePreviewMapper
import com.algorand.android.modules.baseledgeraccountselection.accountselection.ui.model.SearchType
import com.algorand.android.modules.onboarding.pairledger.accountselection.ui.mapper.RegisterLedgerAccountSelectionPreviewMapper
import com.algorand.android.modules.onboarding.pairledger.accountselection.ui.model.RegisterLedgerAccountSelectionPreview
import com.algorand.android.repository.AccountRepository
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.AssetFetchAndCacheUseCase
import com.algorand.android.usecase.LedgerAccountSelectionUseCase
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.extensions.addFirst
import com.algorand.android.utils.toShortenedAddress
import com.algorand.android.utils.toShortenedAddress
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.onStart
import javax.inject.Inject

@SuppressWarnings("LongParameterList")
class RegisterLedgerAccountSelectionPreviewUseCase @Inject constructor(
    private val accountCacheManager: AccountCacheManager,
    private val registerLedgerAccountSelectionPreviewMapper: RegisterLedgerAccountSelectionPreviewMapper,
    private val ledgerAccountSelectionInstructionItemMapper: LedgerAccountSelectionInstructionItemMapper,
    private val ledgerAccountSelectionAccountItemMapper: LedgerAccountSelectionAccountItemMapper,
    private val accountRepository: AccountRepository,
    private val accountInformationMapper: AccountInformationMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountDisplayNameMapper: AccountDisplayNameMapper,
    private val accountIconDrawablePreviewMapper: AccountIconDrawablePreviewMapper,
    assetFetchAndCacheUseCase: AssetFetchAndCacheUseCase,
    simpleAssetDetailUseCase: SimpleAssetDetailUseCase
) : LedgerAccountSelectionUseCase(
    assetFetchAndCacheUseCase = assetFetchAndCacheUseCase,
    simpleAssetDetailUseCase = simpleAssetDetailUseCase
) {

    fun getUpdatedPreviewAccordingToAccountSelection(
        previousPreview: RegisterLedgerAccountSelectionPreview,
        accountItem: AccountSelectionListItem.AccountItem
    ): RegisterLedgerAccountSelectionPreview {
        val updatedList = previousPreview.accountSelectionListItems.map {
            if (it is AccountSelectionListItem.AccountItem && it.account.address == accountItem.account.address) {
                it.copy(isSelected = !it.isSelected)
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

    @SuppressWarnings("LongMethod")
    fun getRegisterLedgerAccountSelectionPreview(
        ledgerAccountsInformation: Array<AccountInformation>,
        bluetoothAddress: String,
        bluetoothName: String?
    ) = flow {
        val ledgerAccountAddress = ledgerAccountsInformation.map { it.address }
        val ledgerAccounts = mutableListOf<AccountSelectionListItem.AccountItem>().apply {
            ledgerAccountsInformation.forEachIndexed { index, ledgerAccountInformation ->
                // Cache ledger accounts assets
                cacheLedgerAccountAssets(accountInformation = ledgerAccountInformation)

                val authAccountDetail = Account.Detail.Ledger(
                    bluetoothAddress = bluetoothAddress,
                    bluetoothName = bluetoothName,
                    positionInLedger = index
                )
                val isRekeyed = ledgerAccountInformation.isRekeyed()
                val accountDisplayName = accountDisplayNameMapper.mapToAccountDisplayName(
                    accountName = ledgerAccountInformation.address.toShortenedAddress(),
                    accountAddress = ledgerAccountInformation.address,
                    nfDomainName = null,
                    type = if (isRekeyed) Account.Type.REKEYED else Account.Type.LEDGER
                )
                // Since we don't have ledger account in our local, we have to create their drawable manually
                val accountIconDrawablePreview = accountIconDrawablePreviewMapper.mapToAccountIconDrawablePreview(
                    backgroundColorResId = AccountIconResource.LEDGER.backgroundColorResId,
                    iconTintResId = AccountIconResource.LEDGER.iconTintResId,
                    iconResId = if (isRekeyed) R.drawable.ic_rekey_shield else AccountIconResource.LEDGER.iconResId
                )
                val authAccountSelectionListItem = ledgerAccountSelectionAccountItemMapper.mapTo(
                    accountInformation = ledgerAccountInformation,
                    accountDetail = authAccountDetail,
                    accountCacheManager = accountCacheManager,
                    selectorDrawableRes = R.drawable.checkbox_selector,
                    accountDisplayName = accountDisplayName,
                    accountIconDrawablePreview = accountIconDrawablePreview
                )
                add(authAccountSelectionListItem)

                val rekeyedAccountSelectionListItems = getRekeyedAccountsOfAuthAccount(
                    rekeyAdminAddress = ledgerAccountInformation.address,
                    ledgerDetail = authAccountDetail
                ).filter { it.account.address !in ledgerAccountAddress }
                addAll(rekeyedAccountSelectionListItems)
            }
        }.toMutableList<AccountSelectionListItem>().apply {
            val instructionItem = ledgerAccountSelectionInstructionItemMapper.mapTo(
                accountSize = size,
                searchType = SearchType.REGISTER
            )
            addFirst(instructionItem)
        }

        val preview = registerLedgerAccountSelectionPreviewMapper.mapToRegisterLedgerAccountSelectionPreview(
            isLoading = false,
            accountSelectionListItems = ledgerAccounts,
            isActionButtonEnabled = ledgerAccounts.filterIsInstance<AccountSelectionListItem.AccountItem>().any {
                it.isSelected
            }
        )
        emit(preview)
    }.onStart {
        val loadingState = registerLedgerAccountSelectionPreviewMapper.mapToRegisterLedgerAccountSelectionPreview(
            isLoading = true,
            accountSelectionListItems = emptyList(),
            isActionButtonEnabled = false
        )
        emit(loadingState)
    }.distinctUntilChanged()

    private suspend fun getRekeyedAccountsOfAuthAccount(
        rekeyAdminAddress: String,
        ledgerDetail: Account.Detail.Ledger
    ): List<AccountSelectionListItem.AccountItem> {
        val deferredAccountSelectionListItems = mutableListOf<AccountSelectionListItem.AccountItem>()
        accountRepository.getRekeyedAccounts(rekeyAdminAddress).use(
            onSuccess = { rekeyedAccountsListResponse ->
                val rekeyedAccounts = createAccountListFromResponse(
                    rekeyedAccountsListResponse = rekeyedAccountsListResponse,
                    rekeyAdminAddress = rekeyAdminAddress,
                    ledgerDetail = ledgerDetail
                )
                deferredAccountSelectionListItems.addAll(rekeyedAccounts)
            }
        )
        return deferredAccountSelectionListItems
    }

    private suspend fun createAccountListFromResponse(
        rekeyedAccountsListResponse: AccountsResponse,
        rekeyAdminAddress: String,
        ledgerDetail: Account.Detail.Ledger
    ): List<AccountSelectionListItem.AccountItem> {
        return rekeyedAccountsListResponse.accountInformationList?.mapNotNull { payload ->
            if (payload.address != rekeyAdminAddress) {
                val accountInformation = accountInformationMapper.mapToAccountInformation(
                    accountInformationPayload = payload,
                    currentRound = rekeyedAccountsListResponse.currentRound
                )
                // Cache rekeyed accounts assets
                cacheLedgerAccountAssets(accountInformation)

                val accountSecretKey = accountDetailUseCase.getCachedAccountSecretKey(payload.address)
                val detail = Account.Detail.RekeyedAuth.create(
                    authDetail = null,
                    rekeyedAuthDetail = mapOf(rekeyAdminAddress to ledgerDetail),
                    secretKey = accountSecretKey
                )
                val accountDisplayName = accountDisplayNameMapper.mapToAccountDisplayName(
                    accountName = accountInformation.address.toShortenedAddress(),
                    accountAddress = accountInformation.address,
                    nfDomainName = null,
                    type = Account.Type.REKEYED
                )
                // Since we don't have rekeyed accounts to ledger in our local, we have to
                // create their drawable manually
                val accountIconDrawablePreview = accountIconDrawablePreviewMapper.mapToAccountIconDrawablePreview(
                    backgroundColorResId = R.color.wallet_3,
                    iconResId = R.drawable.ic_rekey_shield,
                    iconTintResId = R.color.wallet_3_icon
                )
                ledgerAccountSelectionAccountItemMapper.mapTo(
                    accountInformation = accountInformation,
                    accountDetail = detail,
                    accountCacheManager = accountCacheManager,
                    selectorDrawableRes = R.drawable.checkbox_selector,
                    accountDisplayName = accountDisplayName,
                    accountIconDrawablePreview = accountIconDrawablePreview
                )
            } else {
                null
            }
        }.orEmpty()
    }
}
