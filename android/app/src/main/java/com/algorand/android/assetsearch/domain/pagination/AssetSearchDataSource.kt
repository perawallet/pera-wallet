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

import com.algorand.android.assetsearch.domain.model.AssetDetailDTO
import com.algorand.android.assetsearch.domain.model.AssetSearchQuery
import com.algorand.android.assetsearch.domain.repository.AssetSearchRepository
import com.algorand.android.models.Pagination
import com.algorand.android.models.Result
import com.algorand.android.utils.PeraPagingSource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class AssetSearchDataSource(
    private val assetSearchRepository: AssetSearchRepository,
    private val currentQuery: AssetSearchQuery?
) : PeraPagingSource<String, AssetDetailDTO>() {

    override val logTag: String = AssetSearchDataSource::class.java.simpleName

    override suspend fun loadMore(loadUrl: String): LoadResult<String, AssetDetailDTO> {
        return withContext(Dispatchers.IO) {
            try {
                parseResult(getAssetsByUrl(loadUrl))
            } catch (exception: Exception) {
                LoadResult.Error<String, AssetDetailDTO>(exception)
            }
        }
    }

    override suspend fun initializeData(): LoadResult<String, AssetDetailDTO> {
        return parseResult(searchAssets())
    }

    private suspend fun getAssetsByUrl(currentUrlToFetch: String): Result<Pagination<AssetDetailDTO>> {
        return assetSearchRepository.getAssetsByUrl(currentUrlToFetch)
    }

    private suspend fun searchAssets(): Result<Pagination<AssetDetailDTO>> {
        val (queryText, queryType) = currentQuery ?: DEFAULT_ASSET_QUERY
        val hasCollectibles = currentQuery?.hasCollectibles
        return assetSearchRepository.searchAsset(
            queryText = queryText,
            queryType = queryType,
            hasCollectible = hasCollectibles
        )
    }

    private fun parseResult(result: Result<Pagination<AssetDetailDTO>>): LoadResult<String, AssetDetailDTO> {
        return when (result) {
            is Result.Success -> {
                LoadResult.Page(data = result.data.results, prevKey = null, nextKey = result.data.next)
            }
            is Result.Error -> LoadResult.Error<String, AssetDetailDTO>(result.exception)
        }
    }

    companion object {
        val DEFAULT_ASSET_QUERY = AssetSearchQuery.createDefaultQuery()
    }
}
