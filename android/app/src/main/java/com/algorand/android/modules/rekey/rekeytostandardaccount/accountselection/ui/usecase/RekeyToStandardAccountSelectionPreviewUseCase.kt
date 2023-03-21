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
import com.algorand.android.models.Account.Type.LEDGER
import com.algorand.android.models.Account.Type.REKEYED
import com.algorand.android.models.Account.Type.REKEYED_AUTH
import com.algorand.android.models.Account.Type.STANDARD
import com.algorand.android.models.Account.Type.WATCH
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.ScreenState
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.accounts.domain.usecase.GetAccountValueUseCase
import com.algorand.android.modules.basesingleaccountselection.ui.mapper.SingleAccountSelectionListItemMapper
import com.algorand.android.modules.basesingleaccountselection.ui.usecase.BaseSingleAccountSelectionUsePreviewCase
import com.algorand.android.modules.currency.domain.usecase.CurrencyUseCase
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.modules.rekey.rekeytostandardaccount.accountselection.ui.mapper.RekeyToStandardAccountSelectionPreviewMapper
import com.algorand.android.modules.rekey.rekeytostandardaccount.accountselection.ui.model.RekeyToStandardAccountSelectionPreview
import com.algorand.android.modules.sorting.accountsorting.domain.usecase.AccountSortPreferenceUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.usecase.GetSortedLocalAccountsUseCase
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.map

@SuppressWarnings("LongParameterList")
class RekeyToStandardAccountSelectionPreviewUseCase @Inject constructor(
    private val rekeyToStandardAccountSelectionPreviewMapper: RekeyToStandardAccountSelectionPreviewMapper,
    private val accountDetailUseCase: AccountDetailUseCase,
    getAccountValueUseCase: GetAccountValueUseCase,
    accountSortPreferenceUseCase: AccountSortPreferenceUseCase,
    accountDisplayNameUseCase: AccountDisplayNameUseCase,
    parityUseCase: ParityUseCase,
    currencyUseCase: CurrencyUseCase,
    singleAccountSelectionListItemMapper: SingleAccountSelectionListItemMapper,
    getSortedLocalAccountsUseCase: GetSortedLocalAccountsUseCase,
    accountManager: AccountManager
) : BaseSingleAccountSelectionUsePreviewCase(
    singleAccountSelectionListItemMapper = singleAccountSelectionListItemMapper,
    getSortedLocalAccountsUseCase = getSortedLocalAccountsUseCase,
    accountDisplayNameUseCase = accountDisplayNameUseCase,
    getAccountValueUseCase = getAccountValueUseCase,
    parityUseCase = parityUseCase,
    currencyUseCase = currencyUseCase,
    accountManager = accountManager,
    accountSortPreferenceUseCase = accountSortPreferenceUseCase,
    accountDetailUseCase = accountDetailUseCase
) {

    fun getInitialRekeyToAccountSingleAccountSelectionPreview(): RekeyToStandardAccountSelectionPreview {
        return rekeyToStandardAccountSelectionPreviewMapper.mapToRekeyToStandardAccountSelectionPreview(
            screenState = null,
            singleAccountSelectionListItems = emptyList(),
            isLoading = true
        )
    }

    fun getRekeyToAccountSingleAccountSelectionPreviewFlow(
        accountAddress: String
    ): Flow<RekeyToStandardAccountSelectionPreview> {
        val cachedAccountDetailFlow = getSortedCachedAccountDetailFlow().map { accountsDetails ->
            accountsDetails.mapNotNull { accountDetail ->
                val validAccountDetail = filterAccountDetailsByRequirements(
                    accountAddress = accountAddress,
                    accountDetail = accountDetail
                ) ?: return@mapNotNull null
                createAccountItemListFromAccountDetail(validAccountDetail)
            }
        }
        val localAccountsFlow = getAccountsFlow()

        return combine(cachedAccountDetailFlow, localAccountsFlow) { cachedAccountsDetail, _ ->
            val screenState = if (cachedAccountsDetail.isEmpty()) {
                ScreenState.CustomState(title = R.string.no_account_found)
            } else {
                null
            }
            rekeyToStandardAccountSelectionPreviewMapper.mapToRekeyToStandardAccountSelectionPreview(
                screenState = screenState,
                singleAccountSelectionListItems = cachedAccountsDetail,
                isLoading = false
            )
        }
    }

    private fun filterAccountDetailsByRequirements(
        accountAddress: String,
        accountDetail: AccountDetail
    ): AccountDetail? {
        val account = accountDetail.account
        return when (account.type) {
            STANDARD -> accountDetail
            LEDGER, WATCH, null -> null
            REKEYED, REKEYED_AUTH -> {
                val canAccountSignTransaction = accountDetailUseCase.canAccountSignTransaction(account.address)
                val isSelectedAccount = accountAddress == account.address
                accountDetail.takeIf { isSelectedAccount && canAccountSignTransaction }
            }
        }
    }
}
