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

package com.algorand.android.discover.dapp.ui

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.databinding.FragmentDiscoverDappBinding
import com.algorand.android.discover.common.ui.BaseDiscoverFragment
import com.algorand.android.discover.common.ui.model.PeraWebViewClient
import com.algorand.android.discover.common.ui.model.WebViewError
import com.algorand.android.discover.dapp.ui.model.DiscoverDappPreview
import com.algorand.android.discover.utils.JAVASCRIPT_PERACONNECT
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.setNavigationResult
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class DiscoverDappFragment :
    BaseDiscoverFragment(R.layout.fragment_discover_dapp) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override lateinit var binding: FragmentDiscoverDappBinding

    override val discoverViewModel: DiscoverDappViewModel by viewModels()

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        isBottomBarNeeded = false
    )

    private val discoverDappPreviewCollector: suspend (DiscoverDappPreview) -> Unit = { preview ->
        with(preview) {
            updateUi(this)
            loadingErrorEvent?.consume()?.run {
                handleLoadingError(this)
            }
            reloadPageEvent?.consume()?.run {
                loadUrl(preview)
            }
            webViewGoBackEvent?.consume()?.run {
                with(binding) {
                    if (webView.canGoBack()) {
                        webView.goBack()
                    }
                }
            }
            webViewGoForwardEvent?.consume()?.run {
                with(binding) {
                    if (webView.canGoForward()) {
                        webView.goForward()
                    }
                }
            }
            favoritingEvent?.consume()?.run {
                setNavigationResult(ADD_FAVORITE_RESULT_KEY, this)
            }
        }
    }

    private val discoverDappControlsCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run {
            checkWebViewControls()
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setNavigationResult(ADD_FAVORITE_RESULT_KEY, null)
        initObservers()
        initUi()
    }

    override fun onReportActionFailed() {
        nav(
            DiscoverDappFragmentDirections.actionDiscoverDappFragmentToSingleButtonBottomSheetNavigation(
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
        view?.let { binding = FragmentDiscoverDappBinding.bind(it) }
    }

    private fun loadUrl(preview: DiscoverDappPreview) {
        binding.webView.loadUrl(preview.dappUrl)
    }

    private fun handleLoadingError(error: WebViewError) {
        with(binding) {
            webView.hide()
            discoverViewModel.saveLastError(error)
            errorScreenState.show()
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
    private fun initUi() {
        with(binding) {
            tryAgainButton.setOnClickListener { discoverViewModel.reloadPage() }
            webView.webViewClient = PeraWebViewClient(peraWebViewClientListener)
            bottomDappNavigation.apply {
                homeNavButton.setOnClickListener {
                    discoverViewModel.onHomeNavButtonClicked()
                }
                nextNavButton.isEnabled = false
                nextNavButton.setOnClickListener {
                    discoverViewModel.onNextNavButtonClicked()
                }
                previousNavButton.isEnabled = false
                previousNavButton.setOnClickListener {
                    discoverViewModel.onPreviousNavButtonClicked()
                }
                bottomDappNavigation.favoritesNavButton.setOnClickListener {
                    discoverViewModel.onFavoritesNavButtonClicked()
                }
            }
        }
    }

    private fun updateUi(preview: DiscoverDappPreview) {
        getAppToolbar()?.changeTitle(preview.dappTitle)
        getAppToolbar()?.changeSubtitle(preview.dappUrl)
        with(binding) {
            loadingProgressBar.isVisible = preview.isLoading
            if (preview.isFavorite) {
                bottomDappNavigation.favoritesNavButton.setImageResource(R.drawable.ic_star_full)
            } else {
                bottomDappNavigation.favoritesNavButton.setImageResource(R.drawable.ic_star_empty)
            }
        }
        discoverViewModel.getLastError()?.let {
            handleLoadingError(it)
        } ?: run {
            binding.webView.show()
            binding.errorScreenState.hide()
        }
        checkWebViewControls()
        handlePeraConnectJavascript()
    }

    private fun checkWebViewControls() {
        with(binding) {
            bottomDappNavigation.previousNavButton.isEnabled = webView.canGoBack()
            bottomDappNavigation.nextNavButton.isEnabled = webView.canGoForward()
        }
    }

    private fun handlePeraConnectJavascript() {
        binding.webView.evaluateJavascript(JAVASCRIPT_PERACONNECT, null)
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            discoverViewModel.discoverDappPreviewFlow,
            discoverDappPreviewCollector
        )
        viewLifecycleOwner.collectOnLifecycle(
            discoverViewModel.discoverDappPreviewFlow.map { it.pageUrlChangedEvent },
            discoverDappControlsCollector
        )
    }

    companion object {
        const val ADD_FAVORITE_RESULT_KEY = "add_favorite_result"
    }
}
