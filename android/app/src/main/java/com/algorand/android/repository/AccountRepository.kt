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

import com.algorand.android.cache.AccountLocalCache
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AccountInformationResponsePayload
import com.algorand.android.models.PendingTransactionsResponse
import com.algorand.android.models.Result
import com.algorand.android.network.AlgodApi
import com.algorand.android.network.IndexerApi
import com.algorand.android.network.safeApiCall
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import com.algorand.android.utils.CacheResult
import java.math.BigInteger
import java.net.HttpURLConnection
import javax.inject.Inject
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map

class AccountRepository @Inject constructor(
    private val algodApi: AlgodApi,
    private val indexerApi: IndexerApi,
    private val accountLocalCache: AccountLocalCache,
    private val assetDetailUseCase: SimpleAssetDetailUseCase // TODO Change here after merging this branch
) {

    suspend fun getAccountInformation(
        publicKey: String,
        includeClosedAccounts: Boolean = false
    ): Result<AccountInformationResponsePayload> = safeApiCall {
        requestAccountInformation(publicKey, includeClosedAccounts)
    }

    private suspend fun requestAccountInformation(
        publicKey: String,
        includeClosedAccounts: Boolean
    ): Result<AccountInformationResponsePayload> {
        with(indexerApi.getAccountInformation(publicKey, includeClosedAccounts)) {
            val accountInformation = body()?.accountInformation
            return if (isSuccessful && accountInformation != null) {
                Result.Success(accountInformation)
            } else {
                Result.Error(Exception(), code())
            }
        }
    }

    suspend fun getPendingTransactions(publicKey: String): Result<PendingTransactionsResponse> =
        safeApiCall { requestGetPendingTransactions(publicKey) }

    private suspend fun requestGetPendingTransactions(publicKey: String): Result<PendingTransactionsResponse> {
        with(algodApi.getPendingTransactions(publicKey)) {
            return if (isSuccessful && body() != null) {
                Result.Success(body() as PendingTransactionsResponse)
            } else {
                Result.Error(Exception(errorBody()?.charStream()?.readText()))
            }
        }
    }

    suspend fun getRekeyedAccounts(rekeyAdminAddress: String): Result<List<AccountInformationResponsePayload>> =
        safeApiCall { requestGetRekeyedAccounts(rekeyAdminAddress) }

    private suspend fun requestGetRekeyedAccounts(rekeyAdminAddress: String): Result<List<AccountInformationResponsePayload>> {
        with(indexerApi.getRekeyedAccounts(rekeyAdminAddress)) {
            val accountInformationList = body()?.accountInformationList
            return if (isSuccessful && accountInformationList != null) {
                Result.Success(accountInformationList)
            } else {
                Result.Error(Exception())
            }
        }
    }

    fun getAccountDetailCacheFlow(): StateFlow<HashMap<String, CacheResult<AccountDetail>>> {
        return accountLocalCache.cacheMapFlow
    }

    suspend fun cacheAccountDetail(accountDetail: CacheResult.Success<AccountDetail>) {
        accountLocalCache.put(accountDetail)
    }

    suspend fun cacheAccountDetail(mapKey: String, accountDetail: CacheResult.Error<AccountDetail>) {
        accountLocalCache.put(mapKey, accountDetail)
    }

    suspend fun cacheAccountDetail(accountDetailList: List<CacheResult.Success<AccountDetail>>) {
        accountLocalCache.put(accountDetailList)
    }

    suspend fun cacheAllAccountDetails(accountDetailKeyValuePairList: List<Pair<String, CacheResult<AccountDetail>>>) {
        accountLocalCache.putAll(accountDetailKeyValuePairList)
    }

    fun getCachedAccountDetail(publicKey: String): CacheResult<AccountDetail>? {
        return accountLocalCache.getOrNull(publicKey)
    }

    suspend fun clearAccountDetailCache() {
        accountLocalCache.clear()
    }

    suspend fun removeCachedAccount(publicKey: String) {
        accountLocalCache.remove(publicKey)
    }

    fun getAccountBalanceFlow(publicKey: String): Flow<BigInteger?> {
        // TODO Move this logic into UseCase
        return accountLocalCache.cacheMapFlow
            .map {
                val accountInformation = it[publicKey]?.data?.accountInformation
                val algoAmount = accountInformation?.amount ?: BigInteger.ZERO
                val otherAssetsAmount = accountInformation?.assetHoldingList?.sumOf { it.amount } ?: BigInteger.ZERO
                algoAmount.add(otherAssetsAmount)
            }
    }

    companion object {
        const val ACCOUNT_NOT_FOUND_ERROR_CODE = HttpURLConnection.HTTP_NOT_FOUND
    }
}
