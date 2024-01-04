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

package com.algorand.android.modules.sorting.accountsorting.domain.usecase

import com.algorand.android.customviews.accountandassetitem.model.BaseItemConfiguration
import com.algorand.android.mapper.BaseAccountAndAssetListItemMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.models.BaseAccountAndAssetListItem
import com.algorand.android.modules.accountstatehelper.domain.usecase.AccountStateHelperUseCase
import com.algorand.android.modules.sorting.accountsorting.domain.model.AccountSortingType
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.GetSortedLocalAccountsUseCase
import com.algorand.android.utils.extensions.hasAsset
import javax.inject.Inject

class GetSortedAccountsByPreferenceUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val getSortedLocalAccountsUseCase: GetSortedLocalAccountsUseCase,
    private val baseAccountAndAssetListItemMapper: BaseAccountAndAssetListItemMapper,
    private val accountStateHelperUseCase: AccountStateHelperUseCase
) {

    fun getSortedAccountListItems(
        sortingPreferences: AccountSortingType,
        excludedAccountTypes: List<Account.Type>? = null,
        onLoadedAccountConfiguration: AccountDetail.() -> BaseItemConfiguration.AccountItemConfiguration,
        onFailedAccountConfiguration: Account?.() -> BaseItemConfiguration.AccountItemConfiguration?
    ): List<BaseAccountAndAssetListItem.AccountListItem> {
        val localAccounts = getSortedLocalAccountsUseCase.getSortedLocalAccounts()
        val accountListItems = localAccounts.mapIndexedNotNull { index, account ->
            val isAccountTypeValid = isAccountTypeValid(excludedAccountTypes, account.type)
            if (isAccountTypeValid) {
                val accountDetail = accountDetailUseCase.getCachedAccountDetail(account.address)?.data
                val accountItemConfiguration = configureListItem(
                    accountDetail = accountDetail,
                    account = localAccounts.getOrNull(index),
                    onLoadedAccountConfiguration = onLoadedAccountConfiguration,
                    onFailedAccountConfiguration = onFailedAccountConfiguration
                ) ?: return@mapIndexedNotNull null
                baseAccountAndAssetListItemMapper.mapToAccountListItem(accountItemConfiguration)
            } else {
                null
            }
        }
        return sortingPreferences.sort(accountListItems)
    }

    fun getFilteredSortedAccountListItemsByAssetIds(
        sortingPreferences: AccountSortingType,
        accountFilterAssetId: Long?,
        excludedAccountTypes: List<Account.Type>? = null,
        onLoadedAccountConfiguration: AccountDetail.() -> BaseItemConfiguration.AccountItemConfiguration,
        onFailedAccountConfiguration: Account?.() -> BaseItemConfiguration.AccountItemConfiguration?
    ): List<BaseAccountAndAssetListItem.AccountListItem> {
        val localAccounts = getSortedLocalAccountsUseCase.getSortedLocalAccounts()
        val accountListItems = localAccounts.mapIndexedNotNull { index, account ->
            val isAccountTypeValid = isAccountTypeValid(excludedAccountTypes, account.type)
            if (isAccountTypeValid) {
                val accountDetail = accountDetailUseCase.getCachedAccountDetail(account.address)?.data
                val isAssetIdValid = isAssetIdValid(accountDetail, accountFilterAssetId)
                if (isAssetIdValid) {
                    val accountItemConfiguration = configureListItem(
                        accountDetail = accountDetail,
                        account = localAccounts.getOrNull(index),
                        onLoadedAccountConfiguration = onLoadedAccountConfiguration,
                        onFailedAccountConfiguration = onFailedAccountConfiguration
                    ) ?: return@mapIndexedNotNull null
                    baseAccountAndAssetListItemMapper.mapToAccountListItem(accountItemConfiguration)
                } else {
                    null
                }
            } else {
                null
            }
        }
        return sortingPreferences.sort(accountListItems)
    }

    // TODO: Filter account which is eligible to signing transaction by their account types
    fun getFilteredSortedAccountListItemsWhichCanSignTransaction(
        sortingPreferences: AccountSortingType,
        excludedAccountTypes: List<Account.Type>? = null,
        onLoadedAccountConfiguration: AccountDetail.() -> BaseItemConfiguration.AccountItemConfiguration,
        onFailedAccountConfiguration: Account?.() -> BaseItemConfiguration.AccountItemConfiguration?
    ): List<BaseAccountAndAssetListItem.AccountListItem> {
        val localAccounts = getSortedLocalAccountsUseCase.getSortedLocalAccounts()
        val accountListItems = localAccounts.mapIndexedNotNull { index, account ->
            val isAccountTypeValid = isAccountTypeValid(excludedAccountTypes, account.type)
            if (isAccountTypeValid && accountStateHelperUseCase.hasAccountAuthority(account.address)) {
                val accountDetail = accountDetailUseCase.getCachedAccountDetail(account.address)?.data
                val accountItemConfiguration = configureListItem(
                    accountDetail = accountDetail,
                    account = localAccounts.getOrNull(index),
                    onLoadedAccountConfiguration = onLoadedAccountConfiguration,
                    onFailedAccountConfiguration = onFailedAccountConfiguration
                ) ?: return@mapIndexedNotNull null
                baseAccountAndAssetListItemMapper.mapToAccountListItem(accountItemConfiguration)
            } else {
                null
            }
        }
        return sortingPreferences.sort(accountListItems)
    }

    fun getFilteredSortedAccountListItemsByAssetIdsWhichCanSignTransaction(
        sortingPreferences: AccountSortingType,
        accountFilterAssetId: Long?,
        excludedAccountTypes: List<Account.Type>? = null,
        onLoadedAccountConfiguration: AccountDetail.() -> BaseItemConfiguration.AccountItemConfiguration,
        onFailedAccountConfiguration: Account?.() -> BaseItemConfiguration.AccountItemConfiguration?
    ): List<BaseAccountAndAssetListItem.AccountListItem> {
        val localAccounts = getSortedLocalAccountsUseCase.getSortedLocalAccounts()
        val accountListItems = localAccounts.mapIndexedNotNull { index, account ->
            val isAccountTypeValid = isAccountTypeValid(excludedAccountTypes, account.type)
            if (isAccountTypeValid && accountStateHelperUseCase.hasAccountAuthority(account.address)) {
                val accountDetail = accountDetailUseCase.getCachedAccountDetail(account.address)?.data
                val assetIdValid = isAssetIdValid(accountDetail, accountFilterAssetId)
                if (assetIdValid) {
                    val accountItemConfiguration = configureListItem(
                        accountDetail = accountDetail,
                        account = localAccounts.getOrNull(index),
                        onLoadedAccountConfiguration = onLoadedAccountConfiguration,
                        onFailedAccountConfiguration = onFailedAccountConfiguration
                    ) ?: return@mapIndexedNotNull null
                    baseAccountAndAssetListItemMapper.mapToAccountListItem(accountItemConfiguration)
                } else {
                    null
                }
            } else {
                null
            }
        }
        return sortingPreferences.sort(accountListItems)
    }

    fun getFilteredSortedAccountListWhichNotBackedUp(
        sortingPreferences: AccountSortingType,
        accountFilterAssetId: Long?,
        excludedAccountTypes: List<Account.Type>? = null,
        onLoadedAccountConfiguration: AccountDetail.() -> BaseItemConfiguration.AccountItemConfiguration,
        onFailedAccountConfiguration: Account?.() -> BaseItemConfiguration.AccountItemConfiguration?
    ): List<BaseAccountAndAssetListItem.AccountListItem> {
        val localAccounts = getSortedLocalAccountsUseCase.getSortedLocalAccounts()
        val accountListItems = localAccounts.mapIndexedNotNull { index, account ->
            val isAccountTypeValid = isAccountTypeValid(excludedAccountTypes, account.type)
            if (
                isAccountTypeValid &&
                accountStateHelperUseCase.hasAccountAuthority(account.address) &&
                !account.isBackedUp
            ) {
                val accountDetail = accountDetailUseCase.getCachedAccountDetail(account.address)?.data
                val assetIdValid = isAssetIdValid(accountDetail, accountFilterAssetId)
                if (assetIdValid) {
                    val accountItemConfiguration = configureListItem(
                        accountDetail = accountDetail,
                        account = localAccounts.getOrNull(index),
                        onLoadedAccountConfiguration = onLoadedAccountConfiguration,
                        onFailedAccountConfiguration = onFailedAccountConfiguration
                    ) ?: return@mapIndexedNotNull null
                    baseAccountAndAssetListItemMapper.mapToAccountListItem(accountItemConfiguration)
                } else {
                    null
                }
            } else {
                null
            }
        }
        return sortingPreferences.sort(accountListItems)
    }

    private fun isAssetIdValid(accountDetail: AccountDetail?, filteredAssetId: Long?): Boolean {
        return filteredAssetId == null || filteredAssetId == ALGO_ID || accountDetail?.hasAsset(filteredAssetId) == true
    }

    private fun isAccountTypeValid(excludedAccountTypes: List<Account.Type>?, accountType: Account.Type?): Boolean {
        // This means, there is no filter
        if (excludedAccountTypes.isNullOrEmpty()) return true
        return accountType !in excludedAccountTypes
    }

    private fun configureListItem(
        accountDetail: AccountDetail?,
        account: Account?,
        onLoadedAccountConfiguration: AccountDetail.() -> BaseItemConfiguration.AccountItemConfiguration,
        onFailedAccountConfiguration: Account?.() -> BaseItemConfiguration.AccountItemConfiguration?
    ): BaseItemConfiguration.AccountItemConfiguration? {
        return if (accountDetail != null) {
            onLoadedAccountConfiguration(accountDetail)
        } else {
            onFailedAccountConfiguration.invoke((account))
        }
    }
}
