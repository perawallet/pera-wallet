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

package com.algorand.android.network

import com.algorand.android.models.BlockResponse
import com.algorand.android.models.NextBlockResponse
import com.algorand.android.models.PendingTransactionsResponse
import com.algorand.android.models.SendTransactionResponse
import com.algorand.android.models.TotalAlgoSupply
import com.algorand.android.models.TransactionParams
import okhttp3.RequestBody
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Headers
import retrofit2.http.POST
import retrofit2.http.Path

interface AlgodApi {

    @GET("v2/transactions/params")
    suspend fun getTransactionParams(): Response<TransactionParams>

    @Headers("Content-Type: application/x-binary")
    @POST("v2/transactions")
    suspend fun sendSignedTransaction(@Body rawTransactionData: RequestBody): Response<SendTransactionResponse>

    @GET("v2/status/wait-for-block-after/{waitedBlockNumber}")
    suspend fun getWaitForBlock(@Path("waitedBlockNumber") waitedBlockNumber: Long): Response<NextBlockResponse>

    @GET("v2/accounts/{public_key}/transactions/pending")
    suspend fun getPendingTransactions(@Path("public_key") publicKey: String): Response<PendingTransactionsResponse>

    @GET("v2/ledger/supply")
    suspend fun getTotalAmountOfAlgoInSystem(): Response<TotalAlgoSupply>

    @GET("/v2/blocks/{block_id}")
    suspend fun getBlockById(@Path("block_id") blockId: Long): Response<BlockResponse>
}
