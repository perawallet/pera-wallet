/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.models

import com.algorand.android.utils.AlgoRewardCalculator.Companion.ALGO_TO_MICRO_ALGO
import java.math.BigDecimal
import java.math.BigInteger
import java.math.BigInteger.ZERO

data class AlgoBalanceInformation(
    val balanceWithoutPendingRewards: BigInteger,
    val pendingRewards: BigDecimal,
    val totalBalance: BigInteger
) {

    val pendingRewardAsMicroAlgo: Long
        get() = pendingRewards.multiply(ALGO_TO_MICRO_ALGO).toLong()

    companion object {
        fun create(
            balanceWithoutPendingRewards: BigInteger = ZERO,
            pendingRewards: BigDecimal = BigDecimal.ZERO
        ): AlgoBalanceInformation {
            val totalBalance = getTotalBalance(balanceWithoutPendingRewards, pendingRewards)
            return AlgoBalanceInformation(balanceWithoutPendingRewards, pendingRewards, totalBalance)
        }

        private fun getTotalBalance(
            balanceWithoutPendingRewards: BigInteger,
            pendingRewards: BigDecimal,
        ): BigInteger {
            val pendingRewardAsMicroAlgo = pendingRewards.multiply(ALGO_TO_MICRO_ALGO).toBigInteger()
            return balanceWithoutPendingRewards.add(pendingRewardAsMicroAlgo)
        }
    }
}
