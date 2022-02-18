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

import com.algorand.android.mapper.PendingRewardMapper
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.models.BaseAlgoRewardWrapper
import com.algorand.android.models.PendingReward
import com.algorand.android.repository.AlgoRewardRepository
import com.algorand.android.utils.AlgoRewardResponseHandler
import com.algorand.android.utils.formatAsAlgoRewardString
import java.math.BigDecimal
import java.math.BigInteger
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine

class PendingRewardUseCase @Inject constructor(
    private val algoRewardRepository: AlgoRewardRepository,
    private val rewardResponseHandler: AlgoRewardResponseHandler,
    private val blockPollingUseCase: BlockPollingUseCase,
    private val accountDetailUseCase: AccountDetailUseCase,
    private val pendingRewardMapper: PendingRewardMapper
) {

    suspend fun getPendingRewardFlow(
        publicKey: String,
        assetId: Long,
        coroutineScope: CoroutineScope
    ): Flow<PendingReward> {
        return combine(
            blockPollingUseCase.getBlockNumberFlow(),
            accountDetailUseCase.getAccountDetailCacheFlow(publicKey)
        ) { cachedBlockNumber, cachedAccountDetail ->

            if (assetId != ALGORAND_ID) {
                return@combine pendingRewardMapper.mapToEmptyObject()
            }

            val latestBlockNumber = cachedBlockNumber?.data
                ?: return@combine pendingRewardMapper.mapToEmptyObject()

            val accountDetail = cachedAccountDetail?.data!!
            val amountWithoutPendingRewards = accountDetail.accountInformation.amountWithoutPendingRewards
            val earnedRewards = accountDetail.accountInformation.pendingRewards

            val calculatedReward = calculatePendingRewards(
                latestBlockNumber, coroutineScope, amountWithoutPendingRewards, earnedRewards
            )
            pendingRewardMapper.mapTo(calculatedReward, calculatedReward.formatAsAlgoRewardString())
        }
    }

    // TODO: 10.02.2022 Remove this after implementing the loading state
    fun getInitialPendingReward(): PendingReward {
        return pendingRewardMapper.mapToEmptyObject()
    }

    private suspend fun calculatePendingRewards(
        blockNumber: Long,
        coroutineScope: CoroutineScope,
        balanceWithoutReward: BigInteger,
        earnedRewards: Long
    ): BigDecimal? {
        val deferredRewardResultList = with(algoRewardRepository) {
            awaitAll(
                coroutineScope.async { BaseAlgoRewardWrapper.TotalAlgoSupplyResult(getTotalAmountOfAlgoInSystem()) },
                coroutineScope.async { BaseAlgoRewardWrapper.BlockResult(getBlockById(blockNumber)) },
            )
        }
        return rewardResponseHandler.handleRewardCallResponseList(
            balanceWithoutReward = balanceWithoutReward,
            earnedRewards = earnedRewards,
            rewardCallResponseList = deferredRewardResultList
        )
    }
}
