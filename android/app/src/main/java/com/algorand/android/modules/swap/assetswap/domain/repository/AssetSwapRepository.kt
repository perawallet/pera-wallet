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

package com.algorand.android.modules.swap.assetswap.domain.repository

import com.algorand.android.models.Result
import com.algorand.android.modules.swap.assetselection.base.ui.model.SwapType
import com.algorand.android.modules.swap.assetswap.domain.model.SwapQuoteProvider
import com.algorand.android.modules.swap.assetswap.domain.model.dto.PeraFeeDTO
import com.algorand.android.modules.swap.assetswap.domain.model.dto.SwapQuoteDTO
import com.algorand.android.modules.swap.confirmswap.domain.model.SwapQuoteTransactionDTO
import java.math.BigInteger
import kotlinx.coroutines.flow.Flow

interface AssetSwapRepository {

    suspend fun getSwapQuote(
        fromAssetId: Long,
        toAssetId: Long,
        amount: BigInteger,
        swapType: SwapType,
        accountAddress: String,
        deviceId: String,
        slippage: Float?,
        providers: List<SwapQuoteProvider>
    ): Flow<Result<SwapQuoteDTO>>

    suspend fun getPeraFee(
        fromAssetId: Long,
        amount: BigInteger
    ): Flow<Result<PeraFeeDTO>>

    suspend fun createQuoteTransactions(
        quoteId: Long
    ): Flow<Result<List<SwapQuoteTransactionDTO>>>

    companion object {
        const val INJECTION_NAME = "assetSwapRepositoryInjectionName"
    }
}
