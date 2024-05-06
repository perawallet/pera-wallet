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

package com.algorand.android.modules.swap.assetswap.ui.usecase

import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.modules.swap.assetswap.data.utils.getSafeAssetIdForRequest
import com.algorand.android.modules.swap.assetswap.domain.usecase.GetPeraFeeUseCase
import com.algorand.android.modules.swap.utils.swapFeePadding
import com.algorand.android.usecase.AccountAssetDataUseCase
import com.algorand.android.usecase.AccountDetailUseCase
import com.algorand.android.utils.ALGO_DECIMALS
import com.algorand.android.utils.DataResource
import com.algorand.android.utils.exceptions.InsufficientAlgoBalance
import com.algorand.android.utils.isLesserThan
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import java.math.BigDecimal
import java.math.BigInteger
import java.math.RoundingMode
import javax.inject.Inject

class GetPercentageCalculatedBalanceForSwapUseCase @Inject constructor(
    private val accountAssetDataUseCase: AccountAssetDataUseCase,
    private val getPeraFeeUseCase: GetPeraFeeUseCase,
    private val accountDetailUseCase: AccountDetailUseCase
) {

    suspend fun getBalanceForSelectedPercentage(
        fromAssetId: Long,
        toAssetId: Long,
        percentage: Float,
        accountAddress: String
    ): Flow<DataResource<BigDecimal>> {
        val isFromAssetAlgo = fromAssetId == ALGO_ID
        val (minRequiredBalance, accountAlgoBalance) = getMinBalanceAndAccountAlgoBalancePair(accountAddress)
        val percentageAsBigDecimal = percentage.toBigDecimal()
        return if (isFromAssetAlgo) {
            getBalancePercentageForAlgo(accountAlgoBalance, minRequiredBalance, percentageAsBigDecimal)
        } else {
            getBalancePercentageForAsset(
                accountAlgoBalance = accountAlgoBalance,
                minRequiredBalance = minRequiredBalance,
                accountAddress = accountAddress,
                fromAssetId = fromAssetId,
                percentage = percentageAsBigDecimal,
                toAssetId = toAssetId
            )
        }
    }

    private suspend fun getBalancePercentageForAlgo(
        accountAlgoBalance: BigInteger,
        minRequiredBalance: BigInteger,
        percentage: BigDecimal
    ): Flow<DataResource<BigDecimal>> = flow {

        val percentageCalculatedAlgoAmount = accountAlgoBalance
            .toBigDecimal()
            .movePointLeft(ALGO_DECIMALS)
            .multiply(percentage)
            .divide(percentageDivider)

        getPeraFeeUseCase.getPeraFee(ALGO_ID, percentageCalculatedAlgoAmount, ALGO_DECIMALS).useSuspended(
            onSuccess = { peraFee ->

                val requiredBalancesDeductedAccountBalance = accountAlgoBalance.toBigDecimal()
                    .movePointLeft(ALGO_DECIMALS)
                    .minus(minRequiredBalance.toBigDecimal().movePointLeft(ALGO_DECIMALS))
                    .minus(swapFeePadding)
                    .minus(peraFee)

                when {
                    requiredBalancesDeductedAccountBalance isLesserThan BigDecimal.ZERO -> {
                        emit(DataResource.Error.Local<BigDecimal>(InsufficientAlgoBalance()))
                    }
                    requiredBalancesDeductedAccountBalance isLesserThan percentageCalculatedAlgoAmount -> {
                        emit(DataResource.Success(requiredBalancesDeductedAccountBalance))
                    }
                    else -> {
                        emit(DataResource.Success(percentageCalculatedAlgoAmount))
                    }
                }
            },
            onFailed = { emit(it) }
        )
    }

    private suspend fun getBalancePercentageForAsset(
        accountAlgoBalance: BigInteger,
        minRequiredBalance: BigInteger,
        accountAddress: String,
        fromAssetId: Long,
        percentage: BigDecimal,
        toAssetId: Long
    ): Flow<DataResource<BigDecimal>> = flow {

        val calculatedAlgoBalance = accountAlgoBalance
            .minus(minRequiredBalance)
            .minus(swapFeePadding.toBigInteger())
            .toBigDecimal()
            .movePointLeft(ALGO_DECIMALS)

        if (calculatedAlgoBalance isLesserThan BigDecimal.ZERO) {
            emit(DataResource.Error.Local<BigDecimal>(InsufficientAlgoBalance()))
        } else {
            val accountAssetData = accountAssetDataUseCase.getAccountOwnedAssetData(accountAddress, includeAlgo = false)
                .firstOrNull { it.id == fromAssetId }

            accountAssetData?.let {
                val assetDecimal = accountAssetData.decimals

                val percentageCalculatedBalance = accountAssetData.amount
                    .toBigDecimal()
                    .movePointLeft(accountAssetData.decimals)
                    .multiply(percentage)
                    .divide(percentageDivider, assetDecimal, RoundingMode.DOWN)

                if (toAssetId == ALGO_ID) {
                    emit(DataResource.Success(percentageCalculatedBalance))
                } else {
                    getPeraFeeUseCase.getPeraFee(fromAssetId, percentageCalculatedBalance, assetDecimal).useSuspended(
                        onSuccess = {
                            val feeDeductedAmount = calculatedAlgoBalance.minus(it)
                            if (feeDeductedAmount isLesserThan BigDecimal.ZERO) {
                                emit(DataResource.Error.Local<BigDecimal>(InsufficientAlgoBalance()))
                            } else {
                                emit(DataResource.Success(percentageCalculatedBalance))
                            }
                        },
                        onFailed = { emit(it) }
                    )
                }
            }
        }
    }

    private suspend fun getPeraFeeDeductedAmount(amount: BigDecimal): DataResource<BigDecimal> {
        var result: DataResource<BigDecimal>? = null
        val safeAssetId = getSafeAssetIdForRequest(ALGO_ID)
        getPeraFeeUseCase.getPeraFee(safeAssetId, amount, ALGO_DECIMALS).useSuspended(
            onSuccess = {
                val feeDeductedAmount = amount.minus(it)
                result = if (feeDeductedAmount isLesserThan BigDecimal.ZERO) {
                    DataResource.Error.Local<BigDecimal>(InsufficientAlgoBalance())
                } else {
                    DataResource.Success(feeDeductedAmount)
                }
            },
            onFailed = { result = it }
        )
        return result ?: DataResource.Error.Local(NullPointerException())
    }

    private fun getMinBalanceAndAccountAlgoBalancePair(accountAddress: String): Pair<BigInteger, BigInteger> {
        val cachedAccountData = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data?.accountInformation
        val minRequiredAlgoBalance = cachedAccountData?.getMinAlgoBalance() ?: BigInteger.ZERO
        val accountAlgoBalance = cachedAccountData?.getBalance(ALGO_ID) ?: BigInteger.ZERO
        return minRequiredAlgoBalance to accountAlgoBalance
    }

    companion object {
        private val percentageDivider = BigDecimal.valueOf(100L)
    }
}
