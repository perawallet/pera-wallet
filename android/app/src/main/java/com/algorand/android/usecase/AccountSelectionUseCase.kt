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

import com.algorand.android.mapper.AccountSelectionMapper
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AccountSelection
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.utils.CacheResult
import javax.inject.Inject

class AccountSelectionUseCase @Inject constructor(
    private val splittedAccountsUseCase: SplittedAccountsUseCase,
    private val accountSelectionMapper: AccountSelectionMapper,
    private val accountAlgoAmountUseCase: AccountAlgoAmountUseCase,
    private val accountTotalBalanceUseCase: AccountTotalBalanceUseCase
) {

    fun getAccountFilteredByAssetId(assetId: Long): List<AccountSelection> {
        val (normalAccounts, _) = splittedAccountsUseCase.getWatchAccountSplittedAccountDetails()
        return filterAccountsByAssetId(assetId, normalAccounts).map { accountDetail ->
            val accountBalance = accountTotalBalanceUseCase.getAccountBalance(accountDetail)
            val accountAssetData = accountAlgoAmountUseCase.getAccountAlgoAmount(accountDetail.account.address)
            accountSelectionMapper.mapToAccountSelection(
                assetId = assetId,
                formattedAccountBalance = accountAssetData.formattedSelectedCurrencyValue,
                accountDetail = accountDetail,
                assetCount = accountBalance.assetCount
            )
        }
    }

    private fun filterAccountsByAssetId(
        assetId: Long,
        accounts: List<CacheResult<AccountDetail>>
    ): List<AccountDetail> {
        return accounts.mapNotNull { cachedAccountDetail ->
            val accountDetail = cachedAccountDetail.data
            val hasAccountFilteredAsset = accountDetail?.accountInformation?.assetHoldingList?.firstOrNull {
                it.assetId == assetId
            } != null
            accountDetail.takeIf { hasAccountFilteredAsset || assetId == ALGORAND_ID }
        }
    }
}
