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

package com.algorand.android.modules.accountasset.data.repository

import com.algorand.android.models.AssetInformation.Companion.ALGO_ID
import com.algorand.android.models.Result
import com.algorand.android.modules.accountasset.data.mapper.AccountAssetDetailMapper
import com.algorand.android.modules.accountasset.data.mapper.AssetDetailMapper
import com.algorand.android.modules.accountasset.data.model.AccountAssetDetailResponse
import com.algorand.android.modules.accountasset.data.model.AccountDetailWithoutAssetsResponse
import com.algorand.android.modules.accountasset.domain.model.AccountAssetDetail
import com.algorand.android.modules.accountasset.domain.repository.AccountAssetRepository
import com.algorand.android.network.AlgodApi
import com.algorand.android.network.safeApiCall
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.withContext
import retrofit2.Response
import java.io.IOException
import javax.inject.Inject

class AccountAssetRepositoryImpl @Inject constructor(
    private val algodApi: AlgodApi,
    private val accountAssetDetailMapper: AccountAssetDetailMapper,
    private val assetDetailMapper: AssetDetailMapper
) : AccountAssetRepository {

    override suspend fun getAccountAssetDetail(address: String, assetId: Long): Result<AccountAssetDetail> {
        return safeApiCall {
            if (assetId == ALGO_ID) {
                getAssetDetailForAlgo(address)
            } else {
                getAssetDetail(address, assetId)
            }
        }
    }

    private suspend fun getAssetDetailForAlgo(address: String): Result<AccountAssetDetail> {
        return safeApiCall {
            val result = algodApi.getAccountDetailWithoutAssets(address)
            if (result.isSuccessful && result.body() != null) {
                val accountDetail = accountAssetDetailMapper.map(result.body()!!, assetDetail = null)
                if (accountDetail == null) Result.Error(IllegalArgumentException()) else Result.Success(accountDetail)
            } else {
                Result.Error(IOException())
            }
        }
    }

    @OptIn(ExperimentalCoroutinesApi::class)
    private suspend fun getAssetDetail(address: String, assetId: Long): Result<AccountAssetDetail> {
        return safeApiCall {
            withContext(Dispatchers.IO) {
                val getAccountDetailDeferred = async { algodApi.getAccountDetailWithoutAssets(address) }
                val getAssetDetailDeferred = async { algodApi.getAccountAssetDetail(address, assetId) }
                awaitAll(getAccountDetailDeferred, getAssetDetailDeferred)
                mapAccountAndAssetDetailResponse(
                    getAccountDetailDeferred.getCompleted(),
                    getAssetDetailDeferred.getCompleted()
                )
            }
        }
    }

    private fun mapAccountAndAssetDetailResponse(
        accountDetailResponse: Response<AccountDetailWithoutAssetsResponse>,
        assetDetailResponse: Response<AccountAssetDetailResponse>
    ): Result<AccountAssetDetail> {
        val isAccountDetailResponseSuccessful = with(accountDetailResponse) { isSuccessful || body() == null }
        val isAssetDetailResponseSuccessful = with(assetDetailResponse) { isSuccessful || body() == null }
        if (!isAccountDetailResponseSuccessful || !isAssetDetailResponseSuccessful) {
            return Result.Error(IOException())
        }
        val assetDetail = assetDetailMapper.map(assetDetailResponse.body())
        val accountDetail = accountAssetDetailMapper.map(accountDetailResponse.body()!!, assetDetail)
        return if (accountDetail == null) Result.Error(IllegalArgumentException()) else Result.Success(accountDetail)
    }
}
