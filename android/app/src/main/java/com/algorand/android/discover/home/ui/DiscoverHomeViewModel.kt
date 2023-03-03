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

package com.algorand.android.discover.home.ui

import androidx.lifecycle.viewModelScope
import androidx.paging.cachedIn
import com.algorand.android.assetsearch.domain.pagination.AssetSearchPagerBuilder
import com.algorand.android.discover.common.ui.BaseDiscoverViewModel
import com.algorand.android.discover.common.ui.model.DappFavoriteElement
import com.algorand.android.discover.home.domain.model.TokenDetailInfo
import com.algorand.android.discover.home.ui.mapper.DiscoverDappFavoritesMapper
import com.algorand.android.discover.home.ui.model.DiscoverHomePreview
import com.algorand.android.discover.home.ui.usecase.DiscoverHomePreviewUseCase
import com.algorand.android.discover.utils.getAddToFavoriteFunction
import com.algorand.android.modules.currency.domain.usecase.CurrencyUseCase
import com.algorand.android.modules.tracking.discover.home.DiscoverHomeEventTracker
import com.algorand.android.utils.preference.ThemePreference
import com.google.gson.Gson
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch

@HiltViewModel
class DiscoverHomeViewModel @Inject constructor(
    private val discoverHomePreviewUseCase: DiscoverHomePreviewUseCase,
    private val discoverHomeEventTracker: DiscoverHomeEventTracker,
    private val discoverDappFavoritesMapper: DiscoverDappFavoritesMapper,
    private val currencyUseCase: CurrencyUseCase,
    private val gson: Gson
) : BaseDiscoverViewModel() {

    private val assetSearchPagerBuilder = AssetSearchPagerBuilder.create()

    private val queryTextFlow = MutableStateFlow("")

    private val searchPaginationFlow = discoverHomePreviewUseCase.getSearchPaginationFlow(
        searchPagerBuilder = assetSearchPagerBuilder,
        scope = viewModelScope,
        queryText = queryTextFlow.value
    ).cachedIn(viewModelScope)

    val assetSearchPaginationFlow
        get() = searchPaginationFlow

    private val _discoverHomePreviewFlow = MutableStateFlow(
        discoverHomePreviewUseCase.getInitialStatePreview()
    )
    val discoverHomePreviewFlow: StateFlow<DiscoverHomePreview>
        get() = _discoverHomePreviewFlow

    init {
        initQueryTextFlow()
    }

    private fun initQueryTextFlow() {
        queryTextFlow
            .debounce(QUERY_DEBOUNCE)
            .onEach { discoverHomePreviewUseCase.searchAsset(it) }
            .distinctUntilChanged()
            .launchIn(viewModelScope)
    }

    private fun logQueryEvent(assetId: Long) {
        viewModelScope.launch(Dispatchers.IO) {
            discoverHomeEventTracker.logQueryEvent(
                query = queryTextFlow.value,
                assetId = assetId
            )
        }
    }

    fun navigateToAssetDetail(assetId: Long) {
        logQueryEvent(assetId)
        pushTokenDetailScreen(gson.toJson(TokenDetailInfo(tokenId = assetId.toString(), poolId = null)))
    }

    fun pushTokenDetailScreen(data: String) {
        viewModelScope.launch {
            _discoverHomePreviewFlow
                .emit(discoverHomePreviewUseCase.pushTokenDetailScreen(data, _discoverHomePreviewFlow.value))
        }
    }

    fun pushDappViewerScreen(data: String) {
        viewModelScope.launch {
            _discoverHomePreviewFlow
                .emit(discoverHomePreviewUseCase.pushDappViewerScreen(data, _discoverHomePreviewFlow.value))
        }
    }

    fun pushNewScreen(data: String) {
        viewModelScope.launch {
            _discoverHomePreviewFlow
                .emit(discoverHomePreviewUseCase.pushNewScreen(data, _discoverHomePreviewFlow.value))
        }
    }

    fun onQueryTextChange(query: String) {
        viewModelScope.launch {
            queryTextFlow.emit(query)
        }
    }

    fun requestSearchVisible(isVisible: Boolean) {
        viewModelScope.launch {
            _discoverHomePreviewFlow
                .emit(discoverHomePreviewUseCase.requestSearchVisible(isVisible, _discoverHomePreviewFlow.value))
        }
    }

    fun requestLoadHomepage() {
        clearLastError()
        viewModelScope.launch {
            _discoverHomePreviewFlow
                .emit(discoverHomePreviewUseCase.requestLoadHomepage(_discoverHomePreviewFlow.value))
        }
    }

    fun updateSearchScreenLoadState(
        isListEmpty: Boolean,
        isCurrentStateError: Boolean,
        isLoading: Boolean
    ) {
        viewModelScope.launch {
            _discoverHomePreviewFlow.emit(
                discoverHomePreviewUseCase.updateSearchScreenLoadState(
                    isListEmpty,
                    isCurrentStateError,
                    isLoading,
                    _discoverHomePreviewFlow.value
                )
            )
        }
    }

    fun getPrimaryCurrencyId(): String {
        return currencyUseCase.getPrimaryCurrencyId()
    }

    fun onFavoritesUpdate(favorite: DappFavoriteElement) {
        getWebView()?.let { webView ->
            webView.evaluateJavascript(
                getAddToFavoriteFunction(discoverDappFavoritesMapper.mapFromDappFavoriteElement(favorite), gson),
                null
            )
            saveWebView(webView)
        }
    }

    override fun onPageRequestedShouldOverrideUrlLoading(url: String): Boolean {
        viewModelScope.launch {
            _discoverHomePreviewFlow
                .emit(
                    discoverHomePreviewUseCase
                    .onPageRequestedShouldOverrideUrlLoading(_discoverHomePreviewFlow.value)
                )
        }
        return false
    }

    override fun onPageFinished(title: String?, url: String?) {
        viewModelScope.launch {
            _discoverHomePreviewFlow
                .emit(discoverHomePreviewUseCase.onPageFinished(_discoverHomePreviewFlow.value))
        }
    }

    override fun onError() {
        viewModelScope.launch {
            _discoverHomePreviewFlow
                .emit(discoverHomePreviewUseCase.onError(_discoverHomePreviewFlow.value))
        }
    }

    override fun onHttpError() {
        viewModelScope.launch {
            _discoverHomePreviewFlow
                .emit(discoverHomePreviewUseCase.onHttpError(_discoverHomePreviewFlow.value))
        }
    }

    override fun getDiscoverThemePreference(): ThemePreference {
        return discoverHomePreviewFlow.value.themePreference
    }

    companion object {
        private const val QUERY_DEBOUNCE = 400L
    }
}
