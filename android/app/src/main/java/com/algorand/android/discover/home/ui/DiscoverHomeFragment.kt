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

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import android.widget.SearchView.OnQueryTextListener
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.paging.CombinedLoadStates
import androidx.paging.LoadState
import androidx.paging.PagingData
import com.algorand.android.R
import com.algorand.android.databinding.FragmentDiscoverHomeBinding
import com.algorand.android.discover.common.ui.BaseDiscoverFragment
import com.algorand.android.discover.common.ui.model.DappFavoriteElement
import com.algorand.android.discover.common.ui.model.PeraWebChromeClient
import com.algorand.android.discover.common.ui.model.PeraWebViewClient
import com.algorand.android.discover.common.ui.model.WebViewError
import com.algorand.android.discover.dapp.ui.DiscoverDappFragment.Companion.ADD_FAVORITE_RESULT_KEY
import com.algorand.android.discover.home.domain.PeraMobileWebInterface
import com.algorand.android.discover.home.domain.PeraMobileWebInterface.Companion.WEB_INTERFACE_NAME
import com.algorand.android.discover.home.domain.model.TokenDetailInfo
import com.algorand.android.discover.home.ui.adapter.DiscoverAssetSearchAdapter
import com.algorand.android.discover.home.ui.model.DiscoverAssetItem
import com.algorand.android.discover.home.ui.model.DiscoverHomePreview
import com.algorand.android.discover.utils.getDiscoverAuthHeader
import com.algorand.android.discover.utils.getDiscoverCustomUrl
import com.algorand.android.discover.utils.getDiscoverHomeUrl
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.browser.openExternalBrowserApp
import com.algorand.android.utils.delegation.bottomnavfragment.BottomNavBarFragmentDelegation
import com.algorand.android.utils.delegation.bottomnavfragment.BottomNavBarFragmentDelegationImpl
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.listenToNavigationResult
import com.algorand.android.utils.preference.ThemePreference
import com.algorand.android.utils.scrollToTop
import dagger.hilt.android.AndroidEntryPoint
import java.util.Locale

@AndroidEntryPoint
class DiscoverHomeFragment : BaseDiscoverFragment(R.layout.fragment_discover_home),
    PeraMobileWebInterface.WebInterfaceListener,
    BottomNavBarFragmentDelegation by BottomNavBarFragmentDelegationImpl() {

    private val toolbarConfiguration = ToolbarConfiguration()

    override val discoverViewModel: DiscoverHomeViewModel by viewModels()

    override lateinit var binding: FragmentDiscoverHomeBinding

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        isBottomBarNeeded = true
    )

    private val discoverHomePreviewCollector: suspend (DiscoverHomePreview) -> Unit = { preview ->
        with(preview) {
            updateUi(preview)
            loadingErrorEvent?.consume()?.run {
                handleLoadingError(this)
            }
            tokenDetailScreenRequestEvent?.consume()?.run {
                navigateToTokenDetailScreen(this)
            }
            dappViewerScreenRequestEvent?.consume()?.run {
                val (dappInfo, favoritesList) = this
                dappInfo.url?.let { url ->
                    navigateToDappUrl(url, dappInfo.name, favoritesList)
                }
            }
            urlElementRequestEvent?.consume()?.run {
                this.url?.let { url ->
                    navigateToSimpleUrlViewer(url)
                }
            }
            loadHomeEvent?.consume()?.run {
                loadDiscoverHomepage(preview.themePreference)
            }
            loadCustomUrlEvent?.consume()?.let { url ->
                loadCustomUrl(url, preview.themePreference)
            }
            scrollToTopEvent?.consume()?.run {
                binding.searchRecyclerView.scrollToTop()
            }
        }
    }

    private val loadStateFlowCollector: suspend (CombinedLoadStates) -> Unit = { combinedLoadStates ->
        val isListEmpty = discoverAssetSearchAdapter.itemCount == 0
        val isCurrentStateError = combinedLoadStates.refresh is LoadState.Error
        val isLoading = combinedLoadStates.refresh is LoadState.Loading
        discoverViewModel.updateSearchScreenLoadState(
            isListEmpty = isListEmpty,
            isCurrentStateError = isCurrentStateError,
            isLoading = isLoading
        )
    }

    private val assetSearchAdapterListener = object : DiscoverAssetSearchAdapter.DiscoverAssetSearchAdapterListener {
        override fun onNavigateToAssetDetail(assetId: Long) {
            discoverViewModel.navigateToAssetDetail(assetId)
        }
    }

    private val searchViewQueryTextListener = object : OnQueryTextListener {
        override fun onQueryTextSubmit(query: String?): Boolean {
            view?.hideKeyboard()
            return false
        }

        override fun onQueryTextChange(query: String?): Boolean {
            query?.let {
                discoverViewModel.onQueryTextChange(it)
                return true
            } ?: return false
        }
    }

    private val discoverAssetSearchAdapter = DiscoverAssetSearchAdapter(assetSearchAdapterListener)

    private val discoverAssetSearchPaginationCollector:
        suspend (PagingData<DiscoverAssetItem>) -> Unit = { pagingData ->
        discoverAssetSearchAdapter.submitData(pagingData)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        registerBottomNavBarFragmentDelegation(this)
        initObservers()
        initUi()
        initSavedStateListener()
    }

    override fun onReportActionFailed() {
        nav(
            DiscoverHomeFragmentDirections.actionDiscoverHomeFragmentToSingleButtonBottomSheetNavigation(
                titleAnnotatedString = getTitleForFailedReport(),
                descriptionAnnotatedString = getDescriptionForFailedReport(),
                buttonStringResId = R.string.got_it,
                drawableResId = R.drawable.ic_flag,
                drawableTintResId = R.color.negative,
                shouldDescriptionHasLinkMovementMethod = true
            )
        )
    }

    override fun bindWebView(view: View?) {
        view?.let { binding = FragmentDiscoverHomeBinding.bind(it) }
    }

    override fun pushTokenDetailScreen(jsonEncodedPayload: String) {
        discoverViewModel.pushTokenDetailScreen(jsonEncodedPayload)
    }

    override fun pushDappViewerScreen(jsonEncodedPayload: String) {
        discoverViewModel.pushDappViewerScreen(jsonEncodedPayload)
    }

    override fun pushNewScreen(jsonEncodedPayload: String) {
        discoverViewModel.pushNewScreen(jsonEncodedPayload)
    }

    override fun getDeviceId() {
        discoverViewModel.getDeviceId()
    }

    override fun openSystemBrowser(jsonEncodedPayload: String) {
        discoverViewModel.getRedirectUrlFromJson(jsonEncodedPayload)?.let {
            context?.openExternalBrowserApp(it)
        }
    }

    private fun initSavedStateListener() {
        listenToNavigationResult<DappFavoriteElement?>(ADD_FAVORITE_RESULT_KEY) { favorite ->
            favorite?.let { discoverViewModel.onFavoritesUpdate(it) }
        }
    }

    private fun initUi() {
        with(binding) {
            searchRecyclerView.adapter = discoverAssetSearchAdapter
            initWebview()
            searchView.setOnQueryTextListener(searchViewQueryTextListener)

            searchIconView.setOnClickListener {
                discoverViewModel.requestSearchVisible(true)
            }

            cancelSearchButton.setOnClickListener {
                discoverViewModel.requestSearchVisible(false)
            }
            tryAgainButton.setOnClickListener { discoverViewModel.requestLoadHomepage() }
        }
    }

    private fun updateUi(preview: DiscoverHomePreview) {
        with(preview) {
            updateSearchView(this)
            updateSearchListState(isListEmpty)
            updateLoadingProgressBar(isLoading)
            updateWebViewVisibility(this)
        }
    }

    private fun updateSearchView(preview: DiscoverHomePreview) {
        with(binding) {
            setSearchEnabled(true)
            if (!preview.isLoading) {
                searchActivatedGroup.isVisible = preview.isSearchActivated
                searchDeactivatedGroup.isVisible = !preview.isSearchActivated
            }
        }
    }

    private fun updateSearchListState(isEmpty: Boolean) {
        with(binding) {
            errorScreenState.isVisible = isEmpty
            if (isEmpty) {
                errorTitleTextView.text = getString(R.string.well_this_is_unexpected)
                errorDescriptionTextView.text = getString(R.string.we_are_not_able_to_find)
            }
        }
    }

    private fun updateWebViewVisibility(preview: DiscoverHomePreview) {
        discoverViewModel.getLastError()?.let {
            handleLoadingError(it)
        } ?: run {
            binding.webView.isVisible = !preview.isSearchActivated
        }
    }

    private fun updateLoadingProgressBar(isLoading: Boolean) {
        binding.loadingProgressBar.isVisible = isLoading
    }

    private fun handleLoadingError(error: WebViewError) {
        with(binding) {
            webView.hide()
            discoverViewModel.saveLastError(error)
            errorScreenState.show()
            setSearchEnabled(false)
            when (error) {
                WebViewError.HTTP_ERROR -> {
                    errorTitleTextView.text = getString(R.string.well_this_is_unexpected)
                    errorDescriptionTextView.text = getString(R.string.we_are_not_able_to_find)
                }
                WebViewError.NO_CONNECTION -> {
                    errorTitleTextView.text = getString(R.string.no_internet_connection)
                    errorDescriptionTextView.text = getString(R.string.you_dont_seem_to_be_connected)
                }
            }
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun initWebview() {
        with(binding) {
            val peraWebInterface = PeraMobileWebInterface.create(this@DiscoverHomeFragment)
            webView.addJavascriptInterface(peraWebInterface, WEB_INTERFACE_NAME)
            webView.webViewClient = PeraWebViewClient(peraWebViewClientListener)
            webView.webChromeClient = PeraWebChromeClient(peraWebViewClientListener)
        }
    }

    private fun loadDiscoverHomepage(themePreference: ThemePreference) {
        val homeUrl = getDiscoverHomeUrl(
            themePreference = getWebViewThemeFromThemePreference(themePreference),
            currency = discoverViewModel.getPrimaryCurrencyId(),
            locale = Locale.getDefault().language
        )
        loadWebViewUrl(homeUrl)
    }

    private fun loadCustomUrl(url: String, themePreference: ThemePreference) {
        val homeUrl = getDiscoverCustomUrl(
            url = url,
            themePreference = getWebViewThemeFromThemePreference(themePreference),
            currency = discoverViewModel.getPrimaryCurrencyId(),
            locale = Locale.getDefault().language
        )
        loadWebViewUrl(homeUrl)
    }

    private fun loadWebViewUrl(url: String) {
        binding.webView.post {
            binding.webView.loadUrl(url, getDiscoverAuthHeader())
        }
    }

    private fun setSearchEnabled(enabled: Boolean) {
        with(binding) {
            searchIconView.isEnabled = enabled
            cancelSearchButton.isEnabled = enabled
            searchView.isEnabled = enabled
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            discoverViewModel.discoverHomePreviewFlow,
            discoverHomePreviewCollector
        )
        viewLifecycleOwner.collectLatestOnLifecycle(
            discoverViewModel.assetSearchPaginationFlow,
            discoverAssetSearchPaginationCollector
        )
        viewLifecycleOwner.collectLatestOnLifecycle(
            discoverAssetSearchAdapter.loadStateFlow,
            loadStateFlowCollector
        )
    }

    private fun navigateToTokenDetailScreen(tokenDetail: TokenDetailInfo) {
        nav(
            DiscoverHomeFragmentDirections.actionDiscoverHomeFragmentToDiscoverDetailNavigation(
                tokenDetail = tokenDetail
            )
        )
    }

    private fun navigateToDappUrl(
        url: String,
        title: String?,
        favorites: Array<DappFavoriteElement>
    ) {
        nav(
            DiscoverHomeFragmentDirections.actionDiscoverHomeFragmentToDiscoverDappFragment(
                dappUrl = url,
                dappTitle = title ?: "",
                favorites = favorites
            )
        )
    }

    private fun navigateToSimpleUrlViewer(url: String) {
        nav(
            DiscoverHomeFragmentDirections.actionDiscoverHomeFragmentToDiscoverUrlViewerFragment(
                url = url
            )
        )
    }
}
