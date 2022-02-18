/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.usecase

import com.algorand.android.core.BaseUseCase
import com.algorand.android.mapper.AccountInformationMapper
import com.algorand.android.mapper.LedgerAccountSelectionAccountItemMapper
import com.algorand.android.mapper.LedgerAccountSelectionInstructionItemMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.repository.AccountRepository
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.Resource
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.flow

class LedgerAccountSelectionUseCase @Inject constructor(
    private val assetFetchAndCacheUseCase: AssetFetchAndCacheUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val accountCacheManager: AccountCacheManager,
    private val accountRepository: AccountRepository,
    private val ledgerAccountSelectionInstructionItemMapper: LedgerAccountSelectionInstructionItemMapper,
    private val ledgerAccountSelectionAccountItemMapper: LedgerAccountSelectionAccountItemMapper,
    private val accountInformationMapper: AccountInformationMapper
) : BaseUseCase() {

    fun getAuthAccountOf(
        accountSelectionListItem: AccountSelectionListItem.AccountItem,
        accountSelectionAccountList: List<AccountSelectionListItem.AccountItem>?
    ): AccountSelectionListItem.AccountItem? {
        return accountSelectionAccountList?.run {
            if (accountSelectionListItem.accountInformation.isRekeyed()) {
                val rekeyAdminAddress = accountSelectionListItem.accountInformation.rekeyAdminAddress
                firstOrNull { rekeyAdminAddress == it.account.address }
            } else {
                null
            }
        }
    }

    fun getRekeyedAccountOf(
        accountSelectionListItem: AccountSelectionListItem.AccountItem,
        accountSelectionAccountList: List<AccountSelectionListItem.AccountItem>?
    ): Array<AccountSelectionListItem.AccountItem>? {
        val accountAddress = accountSelectionListItem.account.address
        return accountSelectionAccountList?.filter {
            it.account.address != accountAddress && it.accountInformation.rekeyAdminAddress == accountAddress
        }?.toTypedArray()
    }

    suspend fun getAccountSelectionListItems(
        ledgerAccountsInformation: Array<AccountInformation>,
        bluetoothAddress: String,
        bluetoothName: String?,
        coroutineScope: CoroutineScope
    ) = flow<Resource<List<AccountSelectionListItem>>> {
        emit(Resource.Loading)
        mutableListOf<AccountSelectionListItem>().apply {

            val instructionItem = ledgerAccountSelectionInstructionItemMapper.mapTo(ledgerAccountsInformation.size)
            add(instructionItem)

            ledgerAccountsInformation.forEachIndexed { index, ledgerAccountInformation ->

                // Cache ledger accounts assets
                cacheLedgerAccountAssets(ledgerAccountInformation, coroutineScope)

                val authAccountDetail = Account.Detail.Ledger(bluetoothAddress, bluetoothName, index)
                val authAccountSelectionListItem = ledgerAccountSelectionAccountItemMapper.mapTo(
                    accountInformation = ledgerAccountInformation,
                    accountDetail = authAccountDetail,
                    accountCacheManager = accountCacheManager
                )
                add(authAccountSelectionListItem)
                val rekeyedAccountSelectionListItems = getRekeyedAccountsOfAuthAccount(
                    ledgerAccountInformation.address, authAccountDetail, coroutineScope
                )
                addAll(rekeyedAccountSelectionListItems)
            }
            emit(Resource.Success(this))
        }
    }

    private suspend fun getRekeyedAccountsOfAuthAccount(
        rekeyAdminAddress: String,
        ledgerDetail: Account.Detail.Ledger,
        coroutineScope: CoroutineScope
    ): List<AccountSelectionListItem.AccountItem> {
        val deferredAccountSelectionListItems = mutableListOf<AccountSelectionListItem.AccountItem>()
        accountRepository.getRekeyedAccounts(rekeyAdminAddress).use(
            onSuccess = { rekeyedAccountsList ->
                val rekeyedAccounts = rekeyedAccountsList
                    .filterNot { it.address == rekeyAdminAddress }
                    .map { accountInformationMapper.mapToAccountInformation(it) }
                    .map { accountInformation ->

                        // Cache rekeyed accounts assets
                        cacheLedgerAccountAssets(accountInformation, coroutineScope)

                        val detail = Account.Detail.RekeyedAuth.create(null, mapOf(rekeyAdminAddress to ledgerDetail))
                        ledgerAccountSelectionAccountItemMapper.mapTo(
                            accountInformation = accountInformation,
                            accountDetail = detail,
                            accountCacheManager = accountCacheManager
                        )
                    }
                deferredAccountSelectionListItems.addAll(rekeyedAccounts)
            }
        )
        return deferredAccountSelectionListItems
    }

    private suspend fun cacheLedgerAccountAssets(
        accountInformation: AccountInformation,
        coroutineScope: CoroutineScope
    ) {
        val assetIds = accountInformation.assetHoldingList.map { it.assetId }.toSet()
        val filteredAssetList = simpleAssetDetailUseCase.getChunkedAndFilteredAssetList(assetIds)
        assetFetchAndCacheUseCase.processFilteredAssetIdList(filteredAssetList, coroutineScope)
    }
}
