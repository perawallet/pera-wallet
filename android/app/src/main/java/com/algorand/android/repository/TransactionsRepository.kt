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

package com.algorand.android.repository

import com.algorand.android.models.AssetInformation
import com.algorand.android.models.NextBlockResponse
import com.algorand.android.models.Result
import com.algorand.android.models.SendTransactionResponse
import com.algorand.android.models.TrackTransactionRequest
import com.algorand.android.models.Transaction
import com.algorand.android.models.TransactionParams
import com.algorand.android.models.TransactionsResponse
import com.algorand.android.network.AlgodApi
import com.algorand.android.network.IndexerApi
import com.algorand.android.network.MobileAlgorandApi
import com.algorand.android.network.getMessageAsResultError
import com.algorand.android.network.request
import com.algorand.android.network.safeApiCall
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import javax.inject.Inject
import javax.inject.Singleton
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody
import retrofit2.HttpException

@Singleton
class TransactionsRepository @Inject constructor(
    private val mobileAlgorandApi: MobileAlgorandApi,
    private val algodApi: AlgodApi,
    private val indexerApi: IndexerApi,
    private val hipoApiErrorHandler: RetrofitErrorHandler
) {

    suspend fun getTransactionParams(): Result<TransactionParams> =
        safeApiCall { requestGetTransactionParams() }

    private suspend fun requestGetTransactionParams(): Result<TransactionParams> {
        with(algodApi.getTransactionParams()) {
            return if (isSuccessful && body() != null) {
                Result.Success(body() as TransactionParams)
            } else {
                Result.Error(Exception())
            }
        }
    }

    suspend fun getWaitForBlock(waitedBlockNumber: Long): Result<NextBlockResponse> =
        safeApiCall { requestGetWaitForBlock(waitedBlockNumber) }

    private suspend fun requestGetWaitForBlock(waitedBlockNumber: Long): Result<NextBlockResponse> {
        with(algodApi.getWaitForBlock(waitedBlockNumber)) {
            return if (isSuccessful && body() != null) {
                Result.Success(body() as NextBlockResponse)
            } else {
                Result.Error(Exception())
            }
        }
    }

    suspend fun sendSignedTransaction(transactionData: ByteArray): Result<SendTransactionResponse> =
        safeApiCall { postSignedTransaction(transactionData) }

    private suspend fun postSignedTransaction(transactionData: ByteArray): Result<SendTransactionResponse> {
        val rawTransactionData = transactionData.toRequestBody("application/x-binary".toMediaTypeOrNull())
        with(algodApi.sendSignedTransaction(rawTransactionData)) {
            return if (isSuccessful && body() != null) {
                Result.Success(body() as SendTransactionResponse)
            } else {
                Result.Error(Exception(errorBody()?.charStream()?.readText()))
            }
        }
    }

    suspend fun postTrackTransaction(trackTransactionRequest: TrackTransactionRequest): Result<Unit> =
        safeApiCall { requestPostTrackTransaction(trackTransactionRequest) }

    private suspend fun requestPostTrackTransaction(trackTransactionRequest: TrackTransactionRequest) = request(
        doRequest = {
            mobileAlgorandApi.trackTransaction(trackTransactionRequest)
        },
        onFailed = { errorResponse ->
            hipoApiErrorHandler.getMessageAsResultError(errorResponse)
        }
    )

    suspend fun getTransactionDetail(transactionId: String): Result<Transaction> =
        safeApiCall { requestGetTransactionDetail(transactionId) }

    private suspend fun requestGetTransactionDetail(transactionId: String): Result<Transaction> {
        with(indexerApi.getTransactionDetail(transactionId)) {
            val queriedTransaction = body()?.transactionList?.firstOrNull()
            return if (isSuccessful && queriedTransaction != null) {
                Result.Success(queriedTransaction)
            } else {
                Result.Error(Exception(errorBody()?.charStream()?.readText()))
            }
        }
    }

    suspend fun getTransactionHistory(
        assetId: Long? = null,
        publicKey: String,
        fromDate: String? = null,
        toDate: String? = null,
        nextToken: String? = null,
        limit: Int? = DEFAULT_TRANSACTION_COUNT,
        txnType: String? = null
    ): Result<TransactionsResponse> =
        safeApiCall { requestGetTransactionHistory(assetId, publicKey, fromDate, toDate, nextToken, limit, txnType) }

    private suspend fun requestGetTransactionHistory(
        assetId: Long? = null,
        publicKey: String,
        fromDate: String? = null,
        toDate: String? = null,
        nextToken: String? = null,
        limit: Int?,
        txnType: String? = null
    ): Result<TransactionsResponse> {
        val safeAssetId = if (assetId == AssetInformation.ALGORAND_ID) null else assetId
        with(indexerApi.getTransactions(publicKey, safeAssetId, fromDate, toDate, nextToken, limit, txnType)) {
            return if (isSuccessful && body() != null) {
                Result.Success(body() as TransactionsResponse)
            } else {
                Result.Error(HttpException(this))
            }
        }
    }

    companion object {
        const val DEFAULT_TRANSACTION_COUNT = 15
    }
}
