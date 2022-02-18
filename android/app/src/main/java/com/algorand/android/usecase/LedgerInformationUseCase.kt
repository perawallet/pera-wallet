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

import com.algorand.android.R
import com.algorand.android.core.BaseUseCase
import com.algorand.android.mapper.LedgerInformationAccountItemMapper
import com.algorand.android.mapper.LedgerInformationAssetItemMapper
import com.algorand.android.mapper.LedgerInformationCanSignByItemMapper
import com.algorand.android.mapper.LedgerInformationTitleItemMapper
import com.algorand.android.models.Account
import com.algorand.android.models.AccountBalance
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.models.CurrencyValue
import com.algorand.android.models.LedgerInformationListItem
import com.algorand.android.utils.formatAsCurrency
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class LedgerInformationUseCase @Inject constructor(
    private val accountTotalBalanceUseCase: AccountTotalBalanceUseCase,
    private val algoPriceUseCase: AlgoPriceUseCase,
    private val accountAssetAmountUseCase: AccountAssetAmountUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val accountAlgoAmountUseCase: AccountAlgoAmountUseCase,
    private val ledgerInformationTitleItemMapper: LedgerInformationTitleItemMapper,
    private val ledgerInformationAccountItemMapper: LedgerInformationAccountItemMapper,
    private val ledgerInformationAssetItemMapper: LedgerInformationAssetItemMapper,
    private val ledgerInformationCanSignByItemMapper: LedgerInformationCanSignByItemMapper
) : BaseUseCase() {

    suspend fun getLedgerInformationListItem(
        selectedLedgerAccount: AccountSelectionListItem.AccountItem,
        rekeyedAccountSelectionListItem: List<AccountSelectionListItem.AccountItem>?,
        authLedgerAccount: AccountSelectionListItem.AccountItem?
    ): List<LedgerInformationListItem> {
        val algoPriceCache = algoPriceUseCase.getCachedAlgoPrice()?.data
        val accountDetail = AccountDetail(selectedLedgerAccount.account, selectedLedgerAccount.accountInformation)
        return prepareLedgerInformationListItem(
            algoPriceCache,
            accountDetail,
            selectedLedgerAccount,
            rekeyedAccountSelectionListItem,
            authLedgerAccount
        )
    }

    private suspend fun prepareLedgerInformationListItem(
        algoPriceCache: CurrencyValue?,
        accountDetail: AccountDetail,
        selectedLedgerAccount: AccountSelectionListItem.AccountItem,
        rekeyedAccountSelectionListItem: List<AccountSelectionListItem.AccountItem>?,
        authLedgerAccount: AccountSelectionListItem.AccountItem?
    ): List<LedgerInformationListItem> {
        return withContext(Dispatchers.Default) {
            return@withContext mutableListOf<LedgerInformationListItem>().apply {
                val selectedCurrencySymbol = algoPriceCache?.symbol ?: algoPriceUseCase.getSelectedCurrencySymbol()
                val accountBalance = accountTotalBalanceUseCase.getAccountBalance(accountDetail)
                val portfolioValue = getPortfolioValue(accountBalance, selectedCurrencySymbol)
                addAll(createLedgerAccountItem(accountDetail, portfolioValue))
                addAll(createAssetItems(accountDetail))
                addAll(createCanSignByItems(authLedgerAccount))
                addAll(createCanSignableAccounts(selectedLedgerAccount, rekeyedAccountSelectionListItem))
            }
        }
    }

    private fun createLedgerAccountItem(
        accountDetail: AccountDetail,
        portfolioValue: String
    ): List<LedgerInformationListItem> {
        return mutableListOf<LedgerInformationListItem>().apply {
            add(ledgerInformationTitleItemMapper.mapTo(R.string.ledger_account))
            add(ledgerInformationAccountItemMapper.mapTo(accountDetail, portfolioValue))
        }
    }

    private fun createAssetItems(accountDetail: AccountDetail): List<LedgerInformationListItem> {
        return mutableListOf<LedgerInformationListItem>().apply {
            val algoAssetData = accountAlgoAmountUseCase.getAccountAlgoAmount(accountDetail)
            add(ledgerInformationTitleItemMapper.mapTo(R.string.assets))
            add(ledgerInformationAssetItemMapper.mapTo(algoAssetData))
            if (accountDetail.accountInformation.assetHoldingList.isNotEmpty()) {
                accountDetail.accountInformation.assetHoldingList.forEach {
                    val assetQueryItem = simpleAssetDetailUseCase.getCachedAssetDetail(it.assetId)?.data
                        ?: return@forEach
                    val accountAssetData = accountAssetAmountUseCase.getAssetAmount(it, assetQueryItem)
                    add(ledgerInformationAssetItemMapper.mapTo(accountAssetData))
                }
            }
        }
    }

    private fun createCanSignByItems(
        authLedgerAccount: AccountSelectionListItem.AccountItem?
    ): List<LedgerInformationListItem> {
        return mutableListOf<LedgerInformationListItem>().apply {
            authLedgerAccount?.run {
                add(ledgerInformationTitleItemMapper.mapTo(R.string.can_be_signed_by))
                add(ledgerInformationCanSignByItemMapper.mapTo(this))
            }
        }
    }

    private fun createCanSignableAccounts(
        selectedLedgerAccount: AccountSelectionListItem.AccountItem,
        rekeyedAccountSelectionListItem: List<AccountSelectionListItem.AccountItem>?
    ): List<LedgerInformationListItem> {
        return mutableListOf<LedgerInformationListItem>().apply {
            if (selectedLedgerAccount.account.type != Account.Type.REKEYED_AUTH) {
                rekeyedAccountSelectionListItem?.takeIf { it.isNotEmpty() }?.run {
                    add(ledgerInformationTitleItemMapper.mapTo(R.string.can_sign_for_these))
                    forEach { add(ledgerInformationCanSignByItemMapper.mapTo(it)) }
                }
            }
        }
    }

    private fun getPortfolioValue(
        accountBalance: AccountBalance,
        symbol: String
    ): String {
        val totalHoldings = with(accountBalance) { algoHoldingsInSelectedCurrency.add(assetHoldingsInSelectedCurrency) }
        return totalHoldings.formatAsCurrency(symbol)
    }
}
