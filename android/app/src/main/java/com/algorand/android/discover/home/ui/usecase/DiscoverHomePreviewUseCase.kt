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

package com.algorand.android.discover.home.ui.usecase

import android.content.SharedPreferences
import androidx.paging.PagingData
import androidx.paging.map
import com.algorand.android.assetsearch.domain.mapper.AssetSearchQueryMapper
import com.algorand.android.assetsearch.domain.pagination.AssetSearchPagerBuilder
import com.algorand.android.discover.common.ui.model.WebViewError
import com.algorand.android.discover.home.domain.model.DappInfo
import com.algorand.android.discover.home.domain.model.TokenDetailInfo
import com.algorand.android.discover.home.domain.model.UrlElement
import com.algorand.android.discover.home.domain.usecase.DiscoverSearchAssetUseCase
import com.algorand.android.discover.home.ui.mapper.DiscoverAssetItemMapper
import com.algorand.android.discover.home.ui.mapper.DiscoverDappFavoritesMapper
import com.algorand.android.discover.home.ui.model.DiscoverAssetItem
import com.algorand.android.discover.home.ui.model.DiscoverHomePreview
import com.algorand.android.utils.Event
import com.algorand.android.utils.preference.getSavedThemePreference
import com.google.gson.Gson
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class DiscoverHomePreviewUseCase @Inject constructor(
    private val discoverSearchAssetUseCase: DiscoverSearchAssetUseCase,
    private val assetSearchQueryMapper: AssetSearchQueryMapper,
    private val discoverAssetItemMapper: DiscoverAssetItemMapper,
    private val sharedPreferences: SharedPreferences,
    private val discoverDappFavoritesMapper: DiscoverDappFavoritesMapper,
    private val gson: Gson
) {

    fun getSearchPaginationFlow(
        searchPagerBuilder: AssetSearchPagerBuilder,
        scope: CoroutineScope,
        queryText: String
    ): Flow<PagingData<DiscoverAssetItem>> {
        val assetSearchQuery = assetSearchQueryMapper.mapToAssetSearchQuery(
            queryText = queryText,
            hasCollectibles = null,
            availableOnDiscoverMobile = true,
            defaultToTrending = true
        )
        val searchedAssetsFlow = discoverSearchAssetUseCase.createPaginationFlow(
            builder = searchPagerBuilder,
            scope = scope,
            defaultQuery = assetSearchQuery
        )

        return searchedAssetsFlow.map { baseSearchedAssetPagination ->
            baseSearchedAssetPagination.map { discoverSearchedAsset ->
                discoverAssetItemMapper.mapToDiscoverAssetItem(discoverSearchedAsset)
            }
        }
    }

    suspend fun searchAsset(queryText: String) {
        val assetSearchQuery = assetSearchQueryMapper.mapToAssetSearchQuery(
            queryText = queryText,
            hasCollectibles = null,
            availableOnDiscoverMobile = true,
            defaultToTrending = true
        )
        discoverSearchAssetUseCase.searchAsset(assetSearchQuery)
    }

    fun getInitialStatePreview() = DiscoverHomePreview(
        themePreference = sharedPreferences.getSavedThemePreference(),
        isLoading = true,
        tokenDetailScreenRequestEvent = null,
        dappViewerScreenRequestEvent = null,
        urlElementRequestEvent = null,
        reloadPageEvent = Event(Unit)
    )

    fun updateSearchScreenLoadState(
        isListEmpty: Boolean,
        isCurrentStateError: Boolean,
        isLoading: Boolean,
        previousState: DiscoverHomePreview
    ) = previousState.copy(
        isListEmpty = isListEmpty &&
            !isCurrentStateError &&
            !isLoading &&
            previousState.isSearchActivated
    )

    fun requestSearchVisible(
        isVisible: Boolean,
        previousState: DiscoverHomePreview
    ) = previousState.copy(
        isListEmpty = if (isVisible) previousState.isListEmpty else false,
        isSearchActivated = isVisible
    )

    fun requestLoadHomepage(previousState: DiscoverHomePreview) = previousState.copy(
        isLoading = true,
        reloadPageEvent = Event(Unit)
    )

    fun onPageRequestedShouldOverrideUrlLoading(previousState: DiscoverHomePreview) = previousState.copy(
        isLoading = true
    )

    fun onPageFinished(previousState: DiscoverHomePreview) = previousState.copy(
        isLoading = false
    )

    fun onError(previousState: DiscoverHomePreview) = previousState.copy(
        isLoading = false,
        loadingErrorEvent = Event(WebViewError.NO_CONNECTION)
    )

    fun onHttpError(previousState: DiscoverHomePreview) = previousState.copy(
        isLoading = false,
        loadingErrorEvent = Event(WebViewError.HTTP_ERROR)
    )

    fun pushDappViewerScreen(
        data: String,
        previousState: DiscoverHomePreview
    ): DiscoverHomePreview {
        val dappInfo = gson.fromJson(data, DappInfo::class.java)
        return previousState.copy(
            dappViewerScreenRequestEvent = Event(
                Pair(
                    dappInfo,
                    dappInfo.favorites?.map {
                        discoverDappFavoritesMapper.mapToDappFavoriteElement(it)
                    }?.toTypedArray() ?: emptyArray()
                )
            )
        )
    }

    fun pushNewScreen(
        data: String,
        previousState: DiscoverHomePreview
    ) = previousState.copy(
        urlElementRequestEvent = Event(
            gson.fromJson(data, UrlElement::class.java)
        )
    )

    fun pushTokenDetailScreen(
        data: String,
        previousState: DiscoverHomePreview
    ) = previousState.copy(
        tokenDetailScreenRequestEvent = Event(
            gson.fromJson(data, TokenDetailInfo::class.java)
        )
    )
}
