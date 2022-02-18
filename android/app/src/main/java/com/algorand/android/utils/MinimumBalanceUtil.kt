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

package com.algorand.android.utils

import com.algorand.android.R
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.Result
import com.algorand.android.utils.exceptions.GlobalException
import java.math.BigInteger

fun calculateMinimumBalance(
    amount: BigInteger,
    accountCacheData: AccountCacheData,
    selectedAsset: AssetInformation
): Result<BigInteger> {
    val calculatedMinBalance = getMinimumCalculatedAmount(amount, accountCacheData, selectedAsset)
    return if (calculatedMinBalance < BigInteger.ZERO) {
        val errorMinBalance = AnnotatedString(
            stringResId = R.string.the_transaction_cannot_be,
            replacementList = listOf("min_balance" to accountCacheData.getMinBalance().formatAsAlgoString())
        )
        Result.Error(
            GlobalException(
                R.string.min_transaction_error,
                errorMinBalance,
                R.string.the_transaction_cannot_be
            )
        )
    } else {
        Result.Success(calculatedMinBalance)
    }
}

private fun getMinimumCalculatedAmount(
    amount: BigInteger,
    selectedAccountCacheData: AccountCacheData,
    selectedAsset: AssetInformation
): BigInteger {
    val assetBalance = selectedAsset.amount ?: BigInteger.ZERO
    val shouldKeepMinimumAlgoBalance = shouldKeepMinimumAlgoBalance(
        selectedAsset,
        selectedAccountCacheData,
        amount,
        assetBalance
    )
    return if (shouldKeepMinimumAlgoBalance) {
        amount - calculateMinBalance(
            selectedAccountCacheData.accountInformation,
            true
        ).toBigInteger() - MIN_FEE.toBigInteger()
    } else {
        amount
    }
}

fun shouldKeepMinimumAlgoBalance(
    selectedAsset: AssetInformation,
    accountCacheData: AccountCacheData,
    amount: BigInteger,
    assetBalance: BigInteger
): Boolean {
    val isThereAnotherAsset = accountCacheData.accountInformation.isThereAnyDifferentAsset()
    val isThereAppOptedIn = accountCacheData.accountInformation.isThereAnOptedInApp()
    val minimumBalance = calculateMinBalance(accountCacheData.accountInformation, true).toBigInteger()
    return selectedAsset.isAlgo() &&
        assetBalance - amount < minimumBalance &&
        (isThereAnotherAsset || isThereAppOptedIn)
}
