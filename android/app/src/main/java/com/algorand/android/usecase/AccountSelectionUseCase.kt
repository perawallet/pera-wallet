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
import com.algorand.android.models.AccountIconResource
import com.algorand.android.models.AccountSelection
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.accounts.domain.usecase.GetAccountValueUseCase
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.AccountSortPreferenceUseCase
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.GetSortedAccountsByPreferenceUseCase
import com.algorand.android.utils.formatAsCurrency
import javax.inject.Inject

class AccountSelectionUseCase @Inject constructor(
    private val accountSelectionMapper: AccountSelectionMapper,
    private val getSortedAccountsByPreferenceUseCase: GetSortedAccountsByPreferenceUseCase,
    private val accountItemConfigurationMapper: AccountItemConfigurationMapper,
    private val getAccountValueUseCase: GetAccountValueUseCase,
    private val parityUseCase: ParityUseCase,
    private val accountSortPreferenceUseCase: AccountSortPreferenceUseCase,
    private val getAccountDisplayNameUseCase: AccountDisplayNameUseCase
) {

    suspend fun getAccountFilteredByAssetId(assetId: Long): List<AccountSelection> {
        val selectedCurrencySymbol = parityUseCase.getPrimaryCurrencySymbolOrEmpty()
        val sortedAccountListItems = getSortedAccountsByPreferenceUseCase
            .getFilteredSortedAccountListItemsByAssetIds(
                sortingPreferences = accountSortPreferenceUseCase.getAccountSortPreference(),
                accountFilterAssetId = assetId,
                onLoadedAccountConfiguration = {
                    val accountValue = getAccountValueUseCase.getAccountValue(this)
                    accountItemConfigurationMapper.mapTo(
                        accountDisplayName = getAccountDisplayNameUseCase.invoke(account.address),
                        accountAddress = account.address,
                        accountType = account.type,
                        accountIconResource = AccountIconResource.getAccountIconResourceByAccountType(account.type),
                        accountPrimaryValue = accountValue.primaryAccountValue,
                        accountPrimaryValueText = accountValue.primaryAccountValue.formatAsCurrency(
                            symbol = selectedCurrencySymbol,
                            isCompact = true,
                            isFiat = true
                        ),
                        accountAssetCount = this.accountInformation.getOptedInAssetsCount()
                    )
                },
                onFailedAccountConfiguration = {
                    this?.run {
                        accountItemConfigurationMapper.mapTo(
                            accountDisplayName = getAccountDisplayNameUseCase.invoke(address),
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
