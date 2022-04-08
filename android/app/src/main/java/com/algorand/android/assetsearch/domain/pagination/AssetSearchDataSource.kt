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

package com.algorand.android.assetsearch.domain.pagination

import androidx.paging.PagingSource
import com.algorand.android.assetsearch.domain.model.AssetDetailDTO
import com.algorand.android.assetsearch.domain.model.AssetSearchQuery
import com.algorand.android.assetsearch.domain.repository.AssetSearchRepository
import com.algorand.android.models.Pagination
import com.algorand.android.models.Result
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class AssetSearchDataSource(
    private val assetSearchRepository: AssetSearchRepository,
    private val currentQuery: AssetSearchQuery?
) : PagingSource<String, AssetDetailDTO>() {

    override suspend fun load(params: LoadParams<String>): LoadResult<String, AssetDetailDTO> {
        return withContext(Dispatchers.IO) {
            try {
                val nextUrl = params.key
                val result = if (nextUrl == null) searchAssets() else getAssetsByUrl(nextUrl)
                parseResult(result)
            } catch (exception: Exception) {
                LoadResult.Error<String, AssetDetailDTO>(exception)
            }
        }
    }

    private suspend fun getAssetsByUrl(url: String): Result<Pagination<AssetDetailDTO>> {
        return assetSearchRepository.getAssetsByUrl(url)
    }

    private suspend fun searchAssets(): Result<Pagination<AssetDetailDTO>> {
        val (queryText, queryType) = currentQuery ?: DEFAULT_ASSET_QUERY
        val filterCollectibles = currentQuery?.filterCollectibles ?: false
        return assetSearchRepository.searchAsset(queryText, queryType, filterCollectibles)
    }

    private fun parseResult(result: Result<Pagination<AssetDetailDTO>>): LoadResult<String, AssetDetailDTO> {
        return when (result) {
            is Result.Success -> LoadResult.Page(data = result.data.results, prevKey = null, nextKey = result.data.next)
            is Result.Error -> LoadResult.Error<String, AssetDetailDTO>(result.exception)
        }
    }

    companion object {
        val DEFAULT_ASSET_QUERY = AssetSearchQuery.createDefaultQuery()
    }
}
