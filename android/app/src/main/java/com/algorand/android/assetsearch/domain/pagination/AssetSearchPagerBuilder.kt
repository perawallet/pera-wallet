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

import androidx.paging.PagingConfig
import com.algorand.android.assetsearch.domain.model.AssetSearchQuery
import com.algorand.android.assetsearch.domain.repository.AssetSearchRepository

class AssetSearchPagerBuilder private constructor() {

    private var searchResultLimit = DEFAULT_SEARCH_RESULT_LIMIT
    private var prefetchDistance = DEFAULT_PREFETCH_DISTANCE

    fun build(assetSearchRepository: AssetSearchRepository, defaultQuery: AssetSearchQuery?): AssetSearchPager {
        return AssetSearchPager.create(createPagingConfig(), assetSearchRepository, defaultQuery)
    }

    fun setResultLimit(resultLimit: Int): AssetSearchPagerBuilder {
        searchResultLimit = resultLimit
        return this
    }

    fun setPrefetchDistance(distance: Int): AssetSearchPagerBuilder {
        prefetchDistance = distance
        return this
    }

    private fun createPagingConfig(): PagingConfig {
        return PagingConfig(
            pageSize = searchResultLimit,
            prefetchDistance = prefetchDistance,
            enablePlaceholders = false
        )
    }

    companion object {
        private const val DEFAULT_SEARCH_RESULT_LIMIT = 50
        private const val DEFAULT_PREFETCH_DISTANCE = 25

        fun create() = AssetSearchPagerBuilder()
    }
}
