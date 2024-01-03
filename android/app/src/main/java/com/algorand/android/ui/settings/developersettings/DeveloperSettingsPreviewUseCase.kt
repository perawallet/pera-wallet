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

package com.algorand.android.ui.settings.developersettings

import com.algorand.android.customviews.accountandassetitem.mapper.AccountItemConfigurationMapper
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.accounts.domain.usecase.GetAccountValueUseCase
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.AccountSortPreferenceUseCase
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.GetSortedAccountsByPreferenceUseCase
import com.algorand.android.usecase.GetIsActiveNodeTestnetUseCase
import javax.inject.Inject

class DeveloperSettingsPreviewUseCase @Inject constructor(
    private val getSortedAccountsByPreferenceUseCase: GetSortedAccountsByPreferenceUseCase,
    private val accountSortPreferenceUseCase: AccountSortPreferenceUseCase,
    private val getAccountValueUseCase: GetAccountValueUseCase,
    private val accountItemConfigurationMapper: AccountItemConfigurationMapper,
    private val getAccountDisplayNameUseCase: AccountDisplayNameUseCase,
    private val getIsActiveNodeTestnetUseCase: GetIsActiveNodeTestnetUseCase
) {

    suspend fun getFirstAccountAddress(): String? {
        val sortedAccountListItem = getSortedAccountsByPreferenceUseCase.getSortedAccountListItems(
            sortingPreferences = accountSortPreferenceUseCase.getAccountSortPreference(),
            onLoadedAccountConfiguration = {
                val accountValue = getAccountValueUseCase.getAccountValue(this)
                accountItemConfigurationMapper.mapTo(
                    accountAddress = account.address,
                    accountDisplayName = getAccountDisplayNameUseCase.invoke(account.address),
                    accountType = account.type,
                    accountPrimaryValue = accountValue.primaryAccountValue
                )
            },
            onFailedAccountConfiguration = {
                this?.run {
                    accountItemConfigurationMapper.mapTo(
                        accountAddress = address,
                        accountDisplayName = getAccountDisplayNameUseCase.invoke(address),
                        accountType = type
                    )
                }
            }
        )
        return sortedAccountListItem.firstOrNull()?.itemConfiguration?.accountAddress
    }

    fun isConnectedToTestnet(): Boolean {
        return getIsActiveNodeTestnetUseCase.invoke()
    }
}
