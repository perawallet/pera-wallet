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

package com.algorand.android.utils.validator

import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.Result
import com.algorand.android.ui.send.transferamount.AssetTransferAmountFragmentDirections
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.calculateMinimumBalance
import com.algorand.android.utils.exceptions.AnnotatedException
import com.algorand.android.utils.exceptions.NavigationException
import com.algorand.android.utils.exceptions.WarningException
import com.algorand.android.utils.shouldKeepMinimumAlgoBalance
import java.math.BigInteger
import javax.inject.Inject

class AmountTransactionValidator @Inject constructor(
    private val accountCacheManager: AccountCacheManager
) {

    @Suppress("ReturnCount")
    fun validateAssetAmount(amount: BigInteger, fromAccountPublicKey: String, assetId: Long): Result<BigInteger> {
        val selectedAsset = accountCacheManager.getAssetInformation(fromAccountPublicKey, assetId)
            ?: return Result.Error(Exception())
        val accountCacheData = accountCacheManager.getCacheData(fromAccountPublicKey)
            ?: return Result.Error(Exception())
        val assetBalance = selectedAsset.amount ?: BigInteger.ZERO

        if (isAccountBalanceViolated(selectedAsset.amount, amount)) {
            return Result.Error(AnnotatedException(R.string.transaction_amount_cannot))
        }

        if (checkIfAccountRekeyedAndTransactionMax(selectedAsset, amount, fromAccountPublicKey)) {
            val direction = AssetTransferAmountFragmentDirections
                .actionAssetTransferAmountFragmentToRekeyedMaximumBalanceWarningBottomSheet(fromAccountPublicKey)
            return Result.Error(NavigationException(direction))
        }

        if (shouldKeepMinimumAlgoBalance(selectedAsset, accountCacheData, amount, assetBalance)) {
            val direction = AssetTransferAmountFragmentDirections
                .actionAssetTransferAmountFragmentToTransactionMaximumBalanceWarningBottomSheet(fromAccountPublicKey)
            return Result.Error(NavigationException(direction))
        }

        if (selectedAsset.isAlgo() && assetBalance == amount) {
            val shouldForceUserRemoveAssets = shouldForceUserRemoveAssets(fromAccountPublicKey, amount)
            if (shouldForceUserRemoveAssets is Result.Error) {
                return Result.Error(shouldForceUserRemoveAssets.exception)
            }
        }

        return calculateMinimumBalance(amount, accountCacheData, selectedAsset)
    }

    private fun shouldForceUserRemoveAssets(fromAccountPublicKey: String, amount: BigInteger): Result<Unit> {
        val accountCacheData = accountCacheManager.getCacheData(fromAccountPublicKey)
            ?: return Result.Error(Exception())
        val shouldForceUserRemoveAssets = with(accountCacheData) {
            getMinBalance().toBigInteger() == amount &&
                (accountInformation.isThereAnyDifferentAsset() || accountInformation.isThereAnOptedInApp())
        }
        if (shouldForceUserRemoveAssets) {
            return Result.Error(WarningException(R.string.warning, AnnotatedString(R.string.in_order_to_delete)))
        }
        return Result.Success(Unit)
    }

    private fun isAccountBalanceViolated(assetBalance: BigInteger?, amount: BigInteger): Boolean {
        return amount > (assetBalance ?: BigInteger.ZERO)
    }

    private fun checkIfAccountRekeyedAndTransactionMax(
        assetInformation: AssetInformation,
        amount: BigInteger,
        fromAccountPublicKey: String
    ): Boolean {
        return assetInformation.isAlgo() &&
            amount == assetInformation.amount &&
            accountCacheManager.accountCacheMap.value[fromAccountPublicKey]?.isRekeyedToAnotherAccount() == true
    }
}
