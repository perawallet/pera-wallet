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

package com.algorand.android.mapper

import com.algorand.android.models.PendingReward
import com.algorand.android.utils.formatAsAlgoRewardString
import java.math.BigDecimal
import javax.inject.Inject

class PendingRewardMapper @Inject constructor() {

    fun mapTo(
        pendingRewardAmount: BigDecimal?,
        formattedPendingRewardAmount: String?,
        pendingRewardRate: Int? = null
    ): PendingReward {
        return PendingReward(
            pendingRewardAmount = pendingRewardAmount,
            formattedPendingRewardAmount = formattedPendingRewardAmount,
            pendingRewardRate = pendingRewardRate
        )
    }

    fun mapToEmptyObject(): PendingReward {
        return PendingReward(
            pendingRewardAmount = BigDecimal.ZERO,
            formattedPendingRewardAmount = BigDecimal.ZERO.formatAsAlgoRewardString()
        )
    }
}
