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

import com.algorand.android.models.AccountInformationResponse
import com.algorand.android.models.AccountsResponse
import com.algorand.android.models.AssetResponse
import com.algorand.android.models.TransactionsResponse
import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query

interface IndexerApi {

    @GET("v2/accounts/{public_key}")
    suspend fun getAccountInformation(
        @Path("public_key") publicKey: String,
        @Query("include-all") includeClosedAccounts: Boolean = false
    ): Response<AccountInformationResponse>

    @GET("v2/accounts/{public_key}/transactions")
    suspend fun getTransactions(
        @Path("public_key") publicKey: String,
        @Query("asset-id") assetId: Long?,
        @Query("after-time") afterTime: String?,
        @Query("before-time") beforeTime: String?,
        @Query("next") nextToken: String?,
        @Query("limit") limit: Int?,
        @Query("tx-type") transactionType: String?
    ): Response<TransactionsResponse>

    @GET("v2/accounts")
    suspend fun getRekeyedAccounts(
        @Query("auth-addr") rekeyAdminAddress: String
    ): Response<AccountsResponse>

    @GET("v2/assets/{assetId}")
    suspend fun getAssetDescription(@Path("assetId") assetId: Long): Response<AssetResponse>

    @GET("v2/transactions")
    suspend fun getTransactionDetail(@Query("txid") transactionId: String): Response<TransactionsResponse>
}
