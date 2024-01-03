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
import com.algorand.android.models.LedgerInformationListItem
import com.algorand.android.modules.accounticon.ui.mapper.AccountIconDrawablePreviewMapper
import com.algorand.android.modules.accounts.domain.usecase.AccountDisplayNameUseCase
import com.algorand.android.modules.currency.domain.usecase.CurrencyUseCase
import com.algorand.android.modules.parity.domain.usecase.ParityUseCase
import com.algorand.android.utils.extensions.getAssetHoldingList
import com.algorand.android.utils.formatAsCurrency
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

@Suppress("LongParameterList")
class LedgerInformationUseCase @Inject constructor(
    private val accountTotalBalanceUseCase: AccountTotalBalanceUseCase,
    private val parityUseCase: ParityUseCase,
    private val accountAssetAmountUseCase: AccountAssetAmountUseCase,
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val accountAlgoAmountUseCase: AccountAlgoAmountUseCase,
    private val ledgerInformationTitleItemMapper: LedgerInformationTitleItemMapper,
    private val ledgerInformationAccountItemMapper: LedgerInformationAccountItemMapper,
    private val ledgerInformationAssetItemMapper: LedgerInformationAssetItemMapper,
    private val ledgerInformationCanSignByItemMapper: LedgerInformationCanSignByItemMapper,
    private val currencyUseCase: CurrencyUseCase,
    private val getAccountDisplayNameUseCase: AccountDisplayNameUseCase,
    private val accountIconDrawablePreviewMapper: AccountIconDrawablePreviewMapper
) : BaseUseCase() {

    suspend fun getLedgerInformationListItem(
        selectedLedgerAccount: AccountSelectionListItem.AccountItem,
        rekeyedAccountSelectionListItem: List<AccountSelectionListItem.AccountItem>?,
        authLedgerAccount: AccountSelectionListItem.AccountItem?
    ): List<LedgerInformationListItem> {
        val accountDetail = AccountDetail(selectedLedgerAccount.account, selectedLedgerAccount.accountInformation)
        return prepareLedgerInformationListItem(
            accountDetail = accountDetail,
            selectedLedgerAccount = selectedLedgerAccount,
            rekeyedAccountSelectionListItem = rekeyedAccountSelectionListItem,
            authLedgerAccount = authLedgerAccount
        )
    }

    private suspend fun prepareLedgerInformationListItem(
        accountDetail: AccountDetail,
        selectedLedgerAccount: AccountSelectionListItem.AccountItem,
        rekeyedAccountSelectionListItem: List<AccountSelectionListItem.AccountItem>?,
        authLedgerAccount: AccountSelectionListItem.AccountItem?
    ): List<LedgerInformationListItem> {
        return withContext(Dispatchers.Default) {
            return@withContext mutableListOf<LedgerInformationListItem>().apply {
                val selectedCurrencySymbol = parityUseCase.getPrimaryCurrencySymbolOrName()
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
        val isAccountRekeyed = accountDetail.accountInformation.isRekeyed()
        return mutableListOf<LedgerInformationListItem>().apply {
            add(ledgerInformationTitleItemMapper.mapTo(R.string.account_details))
            add(
                ledgerInformationAccountItemMapper.mapTo(
                    accountAddress = accountDetail.account.address,
                    portfolioValue = portfolioValue,
                    accountDisplayName = getAccountDisplayNameUseCase.invoke(accountDetail.account.address),
                    accountIconDrawablePreview = accountIconDrawablePreviewMapper.mapToAccountIconDrawablePreview(
                        iconTintResId = R.color.wallet_3_icon,
                        iconResId = if (isAccountRekeyed) R.drawable.ic_rekey_shield else R.drawable.ic_ledger,
                        backgroundColorResId = R.color.wallet_3
                    )
                )
            )
        }
    }

    private fun createAssetItems(accountDetail: AccountDetail): List<LedgerInformationListItem> {
        return mutableListOf<LedgerInformationListItem>().apply {
            val algoAssetData = accountAlgoAmountUseCase.getAccountAlgoAmount(accountDetail)
            add(ledgerInformationTitleItemMapper.mapTo(R.string.assets))
            add(ledgerInformationAssetItemMapper.mapTo(algoAssetData))
            if (accountDetail.getAssetHoldingList().isNotEmpty()) {
                accountDetail.getAssetHoldingList().forEach {
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
        val isAccountRekeyed = authLedgerAccount?.accountInformation?.isRekeyed() == true
        return mutableListOf<LedgerInformationListItem>().apply {
            authLedgerAccount?.run {
                add(ledgerInformationTitleItemMapper.mapTo(R.string.can_be_signed_by))
                val ledgerInformationCanSignByItem = ledgerInformationCanSignByItemMapper.mapTo(
                    accountAddress = account.address,
                    accountIconDrawablePreview = accountIconDrawablePreviewMapper.mapToAccountIconDrawablePreview(
                        iconTintResId = R.color.wallet_3_icon,
                        iconResId = if (isAccountRekeyed) R.drawable.ic_rekey_shield else R.drawable.ic_ledger,
                        backgroundColorResId = R.color.wallet_3
                    )
                )
                add(ledgerInformationCanSignByItem)
            }
        }
    }

    private fun createCanSignableAccounts(
        selectedLedgerAccount: AccountSelectionListItem.AccountItem,
        rekeyedAccountSelectionListItem: List<AccountSelectionListItem.AccountItem>?
    ): List<LedgerInformationListItem> {
        return mutableListOf<LedgerInformationListItem>().apply {
            if (selectedLedgerAccount.account.type != Account.Type.REKEYED_AUTH) {
                if (rekeyedAccountSelectionListItem.isNullOrEmpty()) {
                    return emptyList()
                }
                add(ledgerInformationTitleItemMapper.mapTo(R.string.can_sign_for_these))
                rekeyedAccountSelectionListItem.forEach {
                    val isAccountRekeyed = it.accountInformation.isRekeyed()
                    val ledgerInformationCanSignByItem = ledgerInformationCanSignByItemMapper.mapTo(
                        accountAddress = it.account.address,
                        accountIconDrawablePreview = accountIconDrawablePreviewMapper.mapToAccountIconDrawablePreview(
                            iconTintResId = R.color.wallet_3_icon,
                            iconResId = if (isAccountRekeyed) R.drawable.ic_rekey_shield else R.drawable.ic_ledger,
                            backgroundColorResId = R.color.wallet_3
                        )
                    )
                    add(ledgerInformationCanSignByItem)
                }
            }
        }
    }

    private fun getPortfolioValue(
        accountBalance: AccountBalance,
        symbol: String
    ): String {
        val totalHoldings = with(accountBalance) { algoHoldingsInSelectedCurrency.add(assetHoldingsInSelectedCurrency) }
        val isSelectedPrimaryCurrencyFiat = !currencyUseCase.isPrimaryCurrencyAlgo()
        return totalHoldings.formatAsCurrency(symbol, isFiat = isSelectedPrimaryCurrencyFiat)
    }
}
