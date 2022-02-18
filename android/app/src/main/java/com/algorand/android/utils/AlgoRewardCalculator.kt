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

package com.algorand.android.utils

import java.math.BigDecimal
import java.math.BigInteger
import java.math.RoundingMode.FLOOR
import javax.inject.Inject

class AlgoRewardCalculator @Inject constructor() {

    fun calculateReward(
        totalMoney: BigInteger,
        rewardRate: BigInteger?,
        rewardResidue: BigInteger,
        balanceWithoutRewards: BigInteger,
        earnedRewards: Long
    ): BigDecimal {

        // In TestNet, we do not receive `rewardRate` therefore to keep the user balance up to date
        //  we should pass the reward rate as zero
        if (rewardRate == null) {
            return BigDecimal.ZERO
        }

        if (totalMoney == BigInteger.ZERO) {
            return BigDecimal.ZERO
        }

        val nextRewardAmount = balanceWithoutRewards.toBigDecimal()
            .divide(ALGO_TO_MICRO_ALGO)
            .movePointLeft(ALGO_DECIMALS)
            .setScale(ALGO_DECIMALS, FLOOR)
        val rewardMultiplier = rewardRate.toBigDecimal().add(rewardResidue.toBigDecimal())
        val pendingRewardTotalMoneyRatio = totalMoney.toBigDecimal().divide(ALGO_TO_MICRO_ALGO, FLOOR)

        return nextRewardAmount
            .setScale(ALGO_DECIMALS, FLOOR)
            .multiply(rewardMultiplier)
            .divide(pendingRewardTotalMoneyRatio, FLOOR)
            .add(earnedRewards.toBigDecimal().movePointLeft(ALGO_DECIMALS))
    }

    companion object {
        val ALGO_TO_MICRO_ALGO: BigDecimal = BigDecimal.valueOf(1000000)
    }
}
