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

package com.algorand.android.modules.swap.minimumbalancecalculation.domain

import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.modules.swap.utils.getAccountMinBalanceToSwap
import com.algorand.android.usecase.GetAccountMinimumBalanceUseCase
import com.algorand.android.usecase.GetBaseOwnedAssetDataUseCase
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.exception.MinimumBalanceException
import java.math.BigInteger
import javax.inject.Inject

class CheckIfAccountHasMinimumBalanceUseCase @Inject constructor(
    private val getBaseOwnedAssetDataUseCase: GetBaseOwnedAssetDataUseCase,
    private val getAccountMinimumBalanceUseCase: GetAccountMinimumBalanceUseCase
) {

    fun checkIfAccountHasMinimumBalance(accountAddress: String): DataResource<Unit> {
        val minimumBalance = getAccountMinimumBalanceUseCase.getAccountMinimumBalance(accountAddress)
        val accountAlgoBalance = getAccountAlgoBalance(accountAddress)
        return if (accountAlgoBalance <= minimumBalance) {
            DataResource.Error.Local(MinimumBalanceException())
        } else {
            DataResource.Success(Unit)
        }
    }

    fun checkIfAccountHasMinimumBalanceToSwap(accountAddress: String): DataResource<Unit> {
        val minimumBalance = getAccountMinimumBalanceUseCase.getAccountMinimumBalance(accountAddress)
        val minimumBalanceToSwap = getAccountMinBalanceToSwap(minimumBalance)
        val accountAlgoBalance = getAccountAlgoBalance(accountAddress)
        return if (accountAlgoBalance <= minimumBalanceToSwap) {
            DataResource.Error.Local(MinimumBalanceException())
        } else {
            DataResource.Success(Unit)
        }
    }

    // TODO Use existing usecase to get account algo balance
    private fun getAccountAlgoBalance(accountAddress: String): BigInteger {
        val accountAlgoAssetData = getBaseOwnedAssetDataUseCase.getBaseOwnedAssetData(ALGO_ID, accountAddress)
        return accountAlgoAssetData?.amount ?: BigInteger.ZERO
    }
}
