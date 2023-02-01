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

package com.algorand.android.modules.swap.common.data.repository

import com.algorand.android.modules.swap.common.data.local.SwapSlippageToleranceLocalSource
import com.algorand.android.modules.swap.common.domain.repository.SwapSlippageToleranceRepository

class SwapSlippageToleranceRepositoryImpl(
    private val swapSlippageToleranceLocalSource: SwapSlippageToleranceLocalSource
) : SwapSlippageToleranceRepository {

    override suspend fun getSwapSlippageTolerance(defaultTolerance: Float): Float {
        return swapSlippageToleranceLocalSource.getData(defaultTolerance)
    }

    override suspend fun setSwapSlippageTolerance(slippageTolerance: Float) {
        swapSlippageToleranceLocalSource.saveData(slippageTolerance)
    }
}
