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

import com.algorand.android.models.BaseAlgoRewardWrapper
import com.algorand.android.models.BaseAlgoRewardWrapper.BlockResult
import com.algorand.android.models.BaseAlgoRewardWrapper.TotalAlgoSupplyResult
import com.algorand.android.models.BlockResponse
import com.algorand.android.models.TotalAlgoSupply
import java.math.BigDecimal
import java.math.BigInteger
import javax.inject.Inject

class AlgoRewardResponseHandler @Inject constructor(
    private val algoRewardCalculator: AlgoRewardCalculator
) {

    private var totalAlgoSupply: TotalAlgoSupply? = null
    private var blockResponse: BlockResponse? = null

    suspend fun handleRewardCallResponseList(
        balanceWithoutReward: BigInteger,
        earnedRewards: Long,
        rewardCallResponseList: List<BaseAlgoRewardWrapper>
    ): BigDecimal? {
        rewardCallResponseList.forEach { handleCallResponse(it) }
        return handleEvents(balanceWithoutReward, earnedRewards)
    }

    private suspend fun handleCallResponse(wrapperResponse: BaseAlgoRewardWrapper) {
        with(wrapperResponse) {
            when (this) {
                is TotalAlgoSupplyResult -> totalAlgoSupply = parseResultData()
                is BlockResult -> blockResponse = parseResultData()
            }
        }
    }

    private fun handleEvents(balanceWithoutReward: BigInteger, earnedRewards: Long): BigDecimal? {
        return if (totalAlgoSupply == null || blockResponse == null) {
            clearValues()
            null
        } else {
            calculateReward(balanceWithoutReward, earnedRewards)
        }
    }

    private fun calculateReward(
        balanceWithoutReward: BigInteger,
        earnedRewards: Long
    ): BigDecimal? {
        val rewardRate = blockResponse?.block?.rewardRate
        val rewardResidue = blockResponse?.block?.rewardResidue ?: return null
        val totalMoney = totalAlgoSupply?.totalMoney ?: return null

        return algoRewardCalculator.calculateReward(
            totalMoney, rewardRate, rewardResidue, balanceWithoutReward, earnedRewards
        )
    }

    private fun clearValues() {
        totalAlgoSupply = null
        blockResponse = null
    }
}
