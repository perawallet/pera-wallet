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

import androidx.paging.Pager
import androidx.paging.PagingConfig
import androidx.paging.cachedIn
import com.algorand.android.assetsearch.domain.model.AssetSearchDTO
import com.algorand.android.assetsearch.domain.model.AssetSearchQuery
import com.algorand.android.assetsearch.domain.repository.AssetSearchRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.shareIn

class AssetSearchPager private constructor(
    pagingConfig: PagingConfig,
    assetSearchRepository: AssetSearchRepository,
    private val defaultQuery: AssetSearchQuery?
) {

    private val searchPager: Pager<String, AssetSearchDTO>
    private var searchDataSource: AssetSearchDataSource? = null

    private var searchQuery = defaultQuery

    init {
        searchPager = Pager<String, AssetSearchDTO>(pagingConfig) {
            AssetSearchDataSource(assetSearchRepository, searchQuery).also {
                searchDataSource = it
            }
        }
    }

    fun updateQuery(newQuery: AssetSearchQuery) {
        refreshDataSource(newQuery)
    }

    fun invalidateDataSource() {
        refreshDataSource(defaultQuery ?: AssetSearchDataSource.DEFAULT_ASSET_QUERY)
    }

    private fun refreshDataSource(query: AssetSearchQuery) {
        searchQuery = query
        searchDataSource?.invalidate()
    }

    fun toFlow(scope: CoroutineScope) = searchPager.flow.cachedIn(scope).shareIn(scope, SharingStarted.Lazily)

    companion object {
        fun create(
            config: PagingConfig,
            repository: AssetSearchRepository,
            defaultQuery: AssetSearchQuery?
        ): AssetSearchPager {
            return AssetSearchPager(config, repository, defaultQuery)
        }
    }
}
