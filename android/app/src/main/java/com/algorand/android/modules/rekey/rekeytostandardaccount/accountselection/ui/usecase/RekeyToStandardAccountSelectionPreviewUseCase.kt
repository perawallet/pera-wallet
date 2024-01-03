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

package com.algorand.android.modules.rekey.rekeytostandardaccount.accountselection.ui.usecase

import com.algorand.android.R
import com.algorand.android.core.AccountManager
import com.algorand.android.models.Account
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.ScreenState
import com.algorand.android.modules.accounticon.ui.usecase.CreateAccountIconDrawableUseCase
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.accounts.domain.usecase.GetAccountValueUseCase
import com.algorand.android.modules.accountstatehelper.domain.usecase.AccountStateHelperUseCase
import com.algorand.android.modules.basesingleaccountselection.ui.mapper.SingleAccountSelectionListItemMapper
import com.algorand.android.modules.basesingleaccountselection.ui.model.SingleAccountSelectionListItem
import com.algorand.android.modules.basesingleaccountselection.ui.usecase.BaseSingleAccountSelectionUsePreviewCase
import com.algorand.android.modules.currency.domain.usecase.CurrencyUseCase
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.modules.rekey.rekeytostandardaccount.accountselection.ui.mapper.RekeyToStandardAccountSelectionPreviewMapper
import com.algorand.android.modules.rekey.rekeytostandardaccount.accountselection.ui.model.RekeyToStandardAccountSelectionPreview
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.AccountSortPreferenceUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.GetSortedLocalAccountsUseCase
import javax.inject.Inject
import kotlinx.coroutines.flow.channelFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.map

@SuppressWarnings("LongParameterList")
class RekeyToStandardAccountSelectionPreviewUseCase @Inject constructor(
    private val rekeyToStandardAccountSelectionPreviewMapper: RekeyToStandardAccountSelectionPreviewMapper,
    private val accountStateHelperUseCase: AccountStateHelperUseCase,
    accountDetailUseCase: AccountDetailUseCase,
    getAccountValueUseCase: GetAccountValueUseCase,
    accountSortPreferenceUseCase: AccountSortPreferenceUseCase,
    accountDisplayNameUseCase: AccountDisplayNameUseCase,
    parityUseCase: ParityUseCase,
    currencyUseCase: CurrencyUseCase,
    singleAccountSelectionListItemMapper: SingleAccountSelectionListItemMapper,
    getSortedLocalAccountsUseCase: GetSortedLocalAccountsUseCase,
    accountManager: AccountManager,
    createAccountIconDrawableUseCase: CreateAccountIconDrawableUseCase
) : BaseSingleAccountSelectionUsePreviewCase(
    singleAccountSelectionListItemMapper = singleAccountSelectionListItemMapper,
    getSortedLocalAccountsUseCase = getSortedLocalAccountsUseCase,
    accountDisplayNameUseCase = accountDisplayNameUseCase,
    getAccountValueUseCase = getAccountValueUseCase,
    parityUseCase = parityUseCase,
    currencyUseCase = currencyUseCase,
    accountManager = accountManager,
    accountSortPreferenceUseCase = accountSortPreferenceUseCase,
    accountDetailUseCase = accountDetailUseCase,
    createAccountIconDrawableUseCase = createAccountIconDrawableUseCase
) {

    fun getInitialRekeyToAccountSingleAccountSelectionPreview(): RekeyToStandardAccountSelectionPreview {
        return rekeyToStandardAccountSelectionPreviewMapper.mapToRekeyToStandardAccountSelectionPreview(
            screenState = null,
            singleAccountSelectionListItems = emptyList(),
            isLoading = true
        )
    }

    fun getRekeyToAccountSingleAccountSelectionPreviewFlow(accountAddress: String) = channelFlow {
        getSortedCachedAccountDetailFlow().map { accountsDetails ->
            accountsDetails.mapNotNull { accountDetail ->
                val isAccountEligibleToRekey = isAccountEligibleToRekey(accountDetail, accountAddress)
                if (!isAccountEligibleToRekey) return@mapNotNull null
                createAccountItemListFromAccountDetail(accountDetail)
            }
        }.collectLatest { singleAccountItems ->
            val screenState = if (singleAccountItems.isEmpty()) {
                ScreenState.CustomState(title = R.string.no_account_found)
            } else {
                null
            }
            val titleItem = createTitleItem(textResId = R.string.select_account)
            val descriptionItem = createDescriptionItem(
                descriptionAnnotatedString = AnnotatedString(stringResId = R.string.choose_the_account)
            )
            val singleAccountSelectionListItems = mutableListOf<SingleAccountSelectionListItem>().apply {
                add(titleItem)
                add(descriptionItem)
                addAll(singleAccountItems)
            }
            val preview = rekeyToStandardAccountSelectionPreviewMapper.mapToRekeyToStandardAccountSelectionPreview(
                screenState = screenState,
                singleAccountSelectionListItems = singleAccountSelectionListItems,
                isLoading = false
            )
            send(preview)
        }
    }

    private fun isAccountEligibleToRekey(accountDetail: AccountDetail, accountAddress: String): Boolean {
        return with(accountDetail.account) {
            type == Account.Type.STANDARD &&
                address != accountAddress &&
                accountStateHelperUseCase.hasAccountValidSecretKey(this)
        }
    }
}
