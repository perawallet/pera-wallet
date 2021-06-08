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

package com.algorand.android.repository

import com.algorand.android.core.AccountManager
import com.algorand.android.models.Account
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.PendingTransactionsResponse
import com.algorand.android.models.Result
import com.algorand.android.models.TransactionsResponse
import com.algorand.android.network.AlgodApi
import com.algorand.android.network.IndexerApi
import com.algorand.android.network.safeApiCall
import com.algorand.android.utils.AccountCacheManager
import javax.inject.Inject
import retrofit2.HttpException

class AccountRepository @Inject constructor(
    private val accountManager: AccountManager,
    private val accountCacheManager: AccountCacheManager,
    private val algodApi: AlgodApi,
    private val indexerApi: IndexerApi
) {

    suspend fun getAuthAccountInformation(account: Account): Result<AccountInformation> =
        safeApiCall { requestGetAuthAccountInformation(account) }

    private suspend fun requestGetAuthAccountInformation(account: Account): Result<AccountInformation> {
        with(indexerApi.getAccountInformation(account.address)) {
            val accountInformation = body()?.accountInformation
            return if (isSuccessful && accountInformation != null) {
                accountInformation.getAllAssetIds().forEach { assetId ->
                    if (accountCacheManager.isThereDescriptionForAsset(assetId).not()) {
                        fetchAssetParams(assetId)
                    }
                }

                accountCacheManager.setAccountBalanceInformation(account, accountInformation)

                Result.Success(accountInformation)
            } else if (code() == ACCOUNT_NOT_FOUND_ERROR_CODE) {
                val emptyAccountInformation = AccountInformation.emptyAccountInformation(account.address)
                accountCacheManager.setAccountBalanceInformation(account, emptyAccountInformation)

                Result.Success(emptyAccountInformation)
            } else {
                Result.Error(Exception())
            }
        }
    }

    private suspend fun fetchAssetParams(assetId: Long) {
        safeApiCall {
            with(indexerApi.getAssetDescription(assetId)) {
                val assetParams = body()?.asset?.assetParams
                return@safeApiCall if (isSuccessful && assetParams != null) {
                    accountCacheManager.setAssetDescription(assetId, assetParams)
                    Result.Success(Unit)
                } else {
                    Result.Error(Exception())
                }
            }
        }
    }

    suspend fun getOtherAccountInformation(publicKey: String): Result<AccountInformation> =
        safeApiCall { requestGetOtherAccountInformation(publicKey) }

    private suspend fun requestGetOtherAccountInformation(publicKey: String): Result<AccountInformation> {
        with(indexerApi.getAccountInformation(publicKey)) {
            val accountInformation = body()?.accountInformation
            return if (isSuccessful && accountInformation != null) {
                accountInformation.getAllAssetIds().forEach { assetId ->
                    if (accountCacheManager.isThereDescriptionForAsset(assetId).not()) {
                        fetchAssetParams(assetId)
                    }
                }
                Result.Success(accountInformation)
            } else if (code() == ACCOUNT_NOT_FOUND_ERROR_CODE) {
                Result.Success(AccountInformation.emptyAccountInformation(publicKey))
            } else {
                Result.Error(Exception())
            }
        }
    }

    suspend fun getTransactions(
        assetId: Long,
        publicKey: String,
        fromDate: String? = null,
        toDate: String? = null,
        nextToken: String? = null,
        limit: Int? = DEFAULT_TRANSACTION_COUNT
    ): Result<TransactionsResponse> =
        safeApiCall { requestGetTransactions(assetId, publicKey, fromDate, toDate, nextToken, limit) }

    private suspend fun requestGetTransactions(
        assetId: Long,
        publicKey: String,
        fromDate: String? = null,
        toDate: String? = null,
        nextToken: String? = null,
        limit: Int?
    ): Result<TransactionsResponse> {
        val safeAssetId = if (assetId == AssetInformation.ALGORAND_ID) null else assetId
        with(indexerApi.getTransactions(publicKey, safeAssetId, fromDate, toDate, nextToken, limit)) {
            return if (isSuccessful && body() != null) {
                Result.Success(body() as TransactionsResponse)
            } else {
                Result.Error(HttpException(this))
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

    suspend fun getRekeyedAccounts(rekeyAdminAddress: String): Result<List<AccountInformation>> =
        safeApiCall { requestGetRekeyedAccounts(rekeyAdminAddress) }

    private suspend fun requestGetRekeyedAccounts(rekeyAdminAddress: String): Result<List<AccountInformation>> {
        with(indexerApi.getRekeyedAccounts(rekeyAdminAddress)) {
            val accountInformationList = body()?.accountInformationList
            return if (isSuccessful && accountInformationList != null) {
                accountInformationList.forEach { accountInformation ->
                    accountInformation.getAllAssetIds()?.forEach { assetId ->
                        if (accountCacheManager.isThereDescriptionForAsset(assetId).not()) {
                            fetchAssetParams(assetId)
                        }
                    }
                }
                Result.Success(accountInformationList)
            } else {
                Result.Error(Exception())
            }
        }
    }

    companion object {
        private const val ACCOUNT_NOT_FOUND_ERROR_CODE = 404
        const val DEFAULT_TRANSACTION_COUNT = 15
    }
}
