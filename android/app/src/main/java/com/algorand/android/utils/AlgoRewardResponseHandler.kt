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

package com.algorand.android.utils

import com.algorand.android.models.AlgoBalanceInformation
import com.algorand.android.models.BaseAlgoRewardWrapper
import com.algorand.android.models.BaseAlgoRewardWrapper.BlockResult
import com.algorand.android.models.BaseAlgoRewardWrapper.TotalAlgoSupplyResult
import com.algorand.android.models.BlockResponse
import com.algorand.android.models.TotalAlgoSupply
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
        rewardCallResponseList: List<BaseAlgoRewardWrapper>,
        onBalanceCalculated: (AlgoBalanceInformation) -> Unit
    ) {
        rewardCallResponseList.forEach { callResult ->
            handleCallResponse(callResult)
        }
        handleEvents(balanceWithoutReward, earnedRewards, onBalanceCalculated)
    }

    private suspend fun handleCallResponse(wrapperResponse: BaseAlgoRewardWrapper) {
        with(wrapperResponse) {
            when (wrapperResponse) {
                is TotalAlgoSupplyResult -> totalAlgoSupply = parseResultData()
                is BlockResult -> blockResponse = parseResultData()
            }
        }
    }

    private fun handleEvents(
        balanceWithoutReward: BigInteger,
        earnedRewards: Long,
        onBalanceCalculated: (AlgoBalanceInformation) -> Unit
    ) {
        if (totalAlgoSupply == null || blockResponse == null) {
            clearValues()
        } else {
            calculateReward(balanceWithoutReward, earnedRewards, onBalanceCalculated)
        }
    }

    private fun calculateReward(
        balanceWithoutReward: BigInteger,
        earnedRewards: Long,
        onBalanceCalculated: (AlgoBalanceInformation) -> Unit
    ) {
        val rewardRate = blockResponse?.block?.rewardRate ?: return
        val rewardResidue = blockResponse?.block?.rewardResidue ?: return
        val totalMoney = totalAlgoSupply?.totalMoney ?: return
        val algoBalanceInformation = algoRewardCalculator
            .calculateReward(totalMoney, rewardRate, rewardResidue, balanceWithoutReward, earnedRewards)
        onBalanceCalculated(algoBalanceInformation)
    }

    private fun clearValues() {
        totalAlgoSupply = null
        blockResponse = null
    }
}
