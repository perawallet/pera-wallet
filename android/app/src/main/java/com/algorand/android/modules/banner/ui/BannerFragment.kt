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

package com.algorand.android.modules.banner.ui

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.databinding.FragmentBannerBinding
import com.algorand.android.discover.common.ui.model.PeraWebViewClient
import com.algorand.android.discover.common.ui.model.WebViewError
import com.algorand.android.discover.utils.JAVASCRIPT_PERACONNECT
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.banner.ui.model.BannerPreview
import com.algorand.android.modules.perawebview.ui.BasePeraWebViewFragment
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class BannerFragment : BasePeraWebViewFragment(R.layout.fragment_banner) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        isBottomBarNeeded = false
    )

    override lateinit var binding: FragmentBannerBinding

    private val args: BannerFragmentArgs by navArgs()

    override val basePeraWebViewViewModel: BannerViewModel by viewModels()

    private val peraWebViewPreviewCollector: suspend (BannerPreview) -> Unit = { preview ->
        updateUiWithWebViewPreview(preview)
    }

    private val peraWebViewControlsCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run {
            checkWebViewControls()
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    override fun bindWebView(view: View?) {
        view?.let { binding = FragmentBannerBinding.bind(it) }
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun initUi() {
        getAppToolbar()?.changeSubtitle(args.bannerUrl)
        with(binding) {
            tryAgainButton.setOnClickListener { basePeraWebViewViewModel.reloadPage() }
            webView.apply {
                webViewClient = PeraWebViewClient(peraWebViewClientListener)
                setBackgroundColor(ContextCompat.getColor(context, R.color.white))
            }
            bottomNavigation.apply {
                nextNavButton.isEnabled = false
                previousNavButton.isEnabled = false
                homeNavButton.setOnClickListener { basePeraWebViewViewModel.onHomeNavButtonClicked() }
                nextNavButton.setOnClickListener { basePeraWebViewViewModel.onNextNavButtonClicked() }
                previousNavButton.setOnClickListener { basePeraWebViewViewModel.onPreviousNavButtonClicked() }
            }
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            flow = basePeraWebViewViewModel.bannerPreviewFlow,
            collection = peraWebViewPreviewCollector
        )
        viewLifecycleOwner.collectOnLifecycle(
            flow = basePeraWebViewViewModel.bannerPreviewFlow.map { it.pageUrlChangedEvent },
            collection = peraWebViewControlsCollector
        )
    }

    private fun reloadPage() {
        binding.webView.loadUrl(args.bannerUrl)
    }

    private fun updateUiWithWebViewPreview(basePeraWebViewPreview: BannerPreview) {
        with(basePeraWebViewPreview) {
            binding.loadingProgressBar.root.isVisible = isLoading
            basePeraWebViewViewModel.getLastError()?.let { handleLoadingError(it) }
            checkWebViewControls()
            handlePeraConnectJavascript()
            loadingErrorEvent?.consume()?.run { handleLoadingError(this) }
            reloadPageEvent?.consume()?.run { reloadPage() }
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
        }
    }

    private fun checkWebViewControls() {
        with(binding) {
            bottomNavigation.previousNavButton.isEnabled = webView.canGoBack()
            bottomNavigation.nextNavButton.isEnabled = webView.canGoForward()
        }
    }

    private fun handlePeraConnectJavascript() {
        binding.webView.evaluateJavascript(JAVASCRIPT_PERACONNECT, null)
    }

    private fun handleLoadingError(error: WebViewError) {
        with(binding) {
            webView.hide()
            basePeraWebViewViewModel.saveLastError(error)
            errorScreenState.show()
            when (error) {
                WebViewError.HTTP_ERROR -> {
                    errorTitleTextView.text = getString(R.string.well_this_is_unexpected)
                    errorDescriptionTextView.text = getString(R.string.we_encountered_an_unexpected)
                }
                WebViewError.NO_CONNECTION -> {
                    errorTitleTextView.text = getString(R.string.no_internet_connection)
                    errorDescriptionTextView.text = getString(R.string.you_dont_seem_to_be_connected)
                }
            }
        }
    }

    private fun removeErrorState() {
        with(binding) {
            webView.show()
            errorScreenState.hide()
        }
    }
}
