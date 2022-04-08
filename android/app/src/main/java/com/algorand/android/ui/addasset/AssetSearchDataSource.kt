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

package com.algorand.android.ui.addasset

import androidx.paging.PagingSource
import com.algorand.android.models.AssetQueryType
import com.algorand.android.models.BaseAssetDetail
import com.algorand.android.models.Result
import com.algorand.android.usecase.SimpleAssetDetailUseCase
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class AssetSearchDataSource(
    private val simpleAssetDetailUseCase: SimpleAssetDetailUseCase,
    private val currentQuery: Pair<String, AssetQueryType>,
    private val onAssetsLoaded: suspend (List<BaseAssetDetail>) -> Unit
) : PagingSource<String, BaseAssetDetail>() {

    override suspend fun load(params: LoadParams<String>): LoadResult<String, BaseAssetDetail> {
        return withContext(Dispatchers.IO) {
            try {
                val nextUrl = params.key
                val response = if (nextUrl == null) {
                    val (queryText, queryType) = currentQuery
                    simpleAssetDetailUseCase.searchAssets(queryText, queryType)
                } else {
                    simpleAssetDetailUseCase.getAssetsByUrl(nextUrl)
                }
                when (response) {
                    is Result.Success -> {
                        onAssetsLoaded(response.data.results)
                        LoadResult.Page(data = response.data.results, prevKey = null, nextKey = response.data.next)
                    }
                    is Result.Error -> {
                        LoadResult.Error<String, BaseAssetDetail>(response.exception)
                    }
                }
            } catch (exception: Exception) {
                LoadResult.Error<String, BaseAssetDetail>(exception)
            }
        }
    }
}
