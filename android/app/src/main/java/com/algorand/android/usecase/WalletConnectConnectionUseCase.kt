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

package com.algorand.android.usecase

import com.algorand.android.customviews.accountandassetitem.mapper.AccountItemConfigurationMapper
import com.algorand.android.mapper.AccountSelectionMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.AccountSelection
import com.algorand.android.modules.accounts.domain.usecase.GetAccountValueUseCase
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.AccountSortPreferenceUseCase
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.GetSortedAccountsByPreferenceUseCase
import javax.inject.Inject

class WalletConnectConnectionUseCase @Inject constructor(
    private val accountSelectionMapper: AccountSelectionMapper,
    private val getSortedAccountsByPreferenceUseCase: GetSortedAccountsByPreferenceUseCase,
    private val accountItemConfigurationMapper: AccountItemConfigurationMapper,
    private val getAccountValueUseCase: GetAccountValueUseCase,
    private val accountSortPreferenceUseCase: AccountSortPreferenceUseCase
) {

    suspend fun getNormalAccounts(): List<AccountSelection> {
        val sortedAccountListItems = getSortedAccountsByPreferenceUseCase
            .getFilteredSortedAccountListItemsByAccountType(
                sortingPreferences = accountSortPreferenceUseCase.getAccountSortPreference(),
                excludedAccountTypes = listOf(Account.Type.WATCH),
                onLoadedAccountConfiguration = {
                    val accountValue = getAccountValueUseCase.getAccountValue(this)
                    accountItemConfigurationMapper.mapTo(
                        accountName = account.name,
                        accountAddress = account.address,
                        accountType = account.type,
                        accountIconResource = AccountIconResource.getAccountIconResourceByAccountType(account.type),
                        accountPrimaryValue = accountValue.primaryAccountValue,
                        accountAssetCount = this.accountInformation.getOptedInAssetsCount()
                    )
                },
                onFailedAccountConfiguration = {
                    this?.run {
                        accountItemConfigurationMapper.mapTo(
                            accountName = name,
                            accountAddress = address,
                            accountType = type,
                            accountIconResource = AccountIconResource.getAccountIconResourceByAccountType(type),
                            showWarningIcon = true
                        )
                    }
                }
            )
        return sortedAccountListItems.map { accountListItem ->
            accountSelectionMapper.mapToAccountSelection(
                accountDisplayName = accountListItem.itemConfiguration.accountDisplayName,
                accountIconResource = accountListItem.itemConfiguration.accountIconResource,
                accountAddress = accountListItem.itemConfiguration.accountAddress,
                accountAssetCount = accountListItem.itemConfiguration.accountAssetCount
            )
        }
    }
}
