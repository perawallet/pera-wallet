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

package com.algorand.android.modules.basesingleaccountselection.ui.usecase

import com.algorand.android.core.AccountManager
import com.algorand.android.models.Account
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.accounticon.ui.model.AccountIconDrawablePreview
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.accounts.domain.usecase.GetAccountValueUseCase
import com.algorand.android.modules.basesingleaccountselection.ui.mapper.SingleAccountSelectionListItemMapper
import com.algorand.android.modules.basesingleaccountselection.ui.model.SingleAccountSelectionListItem
import com.algorand.android.modules.currency.domain.usecase.CurrencyUseCase
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.AccountSortPreferenceUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.GetSortedLocalAccountsUseCase
import com.algorand.android.utils.AccountDisplayName
import com.algorand.android.utils.formatAsCurrency
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map

@SuppressWarnings("LongParameterList")
open class BaseSingleAccountSelectionUsePreviewCase constructor(
    private val singleAccountSelectionListItemMapper: SingleAccountSelectionListItemMapper,
    private val getSortedLocalAccountsUseCase: GetSortedLocalAccountsUseCase,
    private val accountDisplayNameUseCase: AccountDisplayNameUseCase,
    private val getAccountValueUseCase: GetAccountValueUseCase,
    private val parityUseCase: ParityUseCase,
    private val currencyUseCase: CurrencyUseCase,
    private val accountManager: AccountManager,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val accountSortPreferenceUseCase: AccountSortPreferenceUseCase,
    private val createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase
) {

    protected fun getSortedCachedAccountDetailFlow(): Flow<List<AccountDetail>> {
        return accountDetailUseCase.getAccountDetailCacheFlow().map { accountsDetails ->
            val safeAccountDetails = accountsDetails.values.mapNotNull { it.data }
            val accountNameAndValueMap = safeAccountDetails.associate { accountDetail ->
                val accountValue = getAccountValueUseCase.getAccountValue(accountDetail)
                val accountDisplayName = accountDisplayNameUseCase.invoke(accountDetail.account.address)
                accountDisplayName to accountValue.primaryAccountValue
            }

            val accountSortPreference = accountSortPreferenceUseCase.getAccountSortPreference()
            val sortedAccountNameAndValueMap = accountSortPreference.sort(accountNameAndValueMap)
            sortedAccountNameAndValueMap.mapNotNull { (accountDisplayName, _) ->
                val accountAddress = accountDisplayName.getRawAccountAddress()
                safeAccountDetails.firstOrNull { it.account.address == accountAddress }
            }
        }
    }

    protected fun createAccountItemListFromAccountDetail(
        accountDetail: AccountDetail
    ): SingleAccountSelectionListItem.AccountItem {
        val selectedCurrencySymbol = parityUseCase.getPrimaryCurrencySymbolOrName()
        val secondaryCurrencySymbol = parityUseCase.getSecondaryCurrencySymbol()
        val isPrimaryCurrencyAlgo = currencyUseCase.isPrimaryCurrencyAlgo()
        val accountDisplayName = accountDisplayNameUseCase.invoke(accountDetail.account.address)
        val accountValue = getAccountValueUseCase.getAccountValue(accountDetail)
        val accountFormattedPrimaryValue = accountValue.primaryAccountValue.formatAsCurrency(
            symbol = selectedCurrencySymbol,
            isCompact = true,
            isFiat = !isPrimaryCurrencyAlgo
        )
        val accountFormattedSecondaryValue = accountValue.secondaryAccountValue.formatAsCurrency(
            symbol = secondaryCurrencySymbol,
            isCompact = true,
            isFiat = !isPrimaryCurrencyAlgo
        )
        return createAccountItem(
            accountDisplayName = accountDisplayName,
            accountIconDrawablePreview = createAccountIconDrawableUseCase.invoke(accountDetail.account.address),
            accountFormattedPrimaryValue = accountFormattedPrimaryValue,
            accountFormattedSecondaryValue = accountFormattedSecondaryValue
        )
    }

    protected fun createAccountItem(
        accountDisplayName: AccountDisplayName,
        accountIconDrawablePreview: AccountIconDrawablePreview,
        accountFormattedPrimaryValue: String?,
        accountFormattedSecondaryValue: String?
    ): SingleAccountSelectionListItem.AccountItem {
        return singleAccountSelectionListItemMapper.mapToAccountItem(
            accountDisplayName = accountDisplayName,
            accountIconDrawablePreview = accountIconDrawablePreview,
            accountFormattedPrimaryValue = accountFormattedPrimaryValue,
            accountFormattedSecondaryValue = accountFormattedSecondaryValue
        )
    }

    protected fun createTitleItem(textResId: Int): SingleAccountSelectionListItem.TitleItem {
        return singleAccountSelectionListItemMapper.mapToTitleItem(textResId)
    }

    protected fun createDescriptionItem(
        descriptionAnnotatedString: AnnotatedString
    ): SingleAccountSelectionListItem.DescriptionItem {
        return singleAccountSelectionListItemMapper.mapToDescriptionItem(descriptionAnnotatedString)
    }

    protected fun getAccountsFlow(): StateFlow<List<Account>> {
        return accountManager.accounts
    }

    protected fun getSortedAccountAddresses(): List<String> {
        return getSortedLocalAccountsUseCase.getSortedLocalAccounts().map { it.address }
    }
}
