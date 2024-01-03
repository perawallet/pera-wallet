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

package com.algorand.android.modules.dapp.transak.ui.browser

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.databinding.FragmentTransakBrowserBinding
import com.algorand.android.discover.common.ui.model.PeraWebViewClient
import com.algorand.android.discover.common.ui.model.WebViewError
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.customviews.toolbar.buttoncontainer.model.IconButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.dapp.transak.ui.browser.model.TransakBrowserPreview
import com.algorand.android.modules.perawebview.ui.BasePeraWebViewFragment
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class TransakBrowserFragment :
    BasePeraWebViewFragment(R.layout.fragment_transak_browser) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleColor = R.color.text_main,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack,
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration
    )

    override lateinit var binding: FragmentTransakBrowserBinding

    override val basePeraWebViewViewModel: TransakBrowserViewModel by viewModels()

    override fun bindWebView(view: View?) {
        view?.let { binding = FragmentTransakBrowserBinding.bind(it) }
    }

    private val transakBrowserPreviewCollector: suspend (TransakBrowserPreview) -> Unit = { preview ->
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
        }
    }

    private val transakBrowserControlsCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run {
            checkWebViewControls()
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
        customizeToolbar()
        initUi()
    }

    private fun customizeToolbar() {
        getAppToolbar()?.apply {
            setEndButtons(
                buttons = listOf(
                    IconButton(R.drawable.ic_reload, onClick = ::onReloadPage)
                )
            )
        }
    }

    private fun onReloadPage() {
        binding.webView.reload()
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun initUi() {
        with(binding) {
            tryAgainButton.setOnClickListener { basePeraWebViewViewModel.reloadPage() }
            webView.webViewClient = PeraWebViewClient(peraWebViewClientListener)
            bottomDappNavigation.apply {
                homeNavButton.setOnClickListener {
                    basePeraWebViewViewModel.onHomeNavButtonClicked()
                }
                nextNavButton.isEnabled = false
                nextNavButton.setOnClickListener {
                    basePeraWebViewViewModel.onNextNavButtonClicked()
                }
                previousNavButton.isEnabled = false
                previousNavButton.setOnClickListener {
                    basePeraWebViewViewModel.onPreviousNavButtonClicked()
                }
                favoritesNavButton.hide()
            }
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            basePeraWebViewViewModel.transakBrowserPreviewFlow,
            transakBrowserPreviewCollector,
        )
        viewLifecycleOwner.collectOnLifecycle(
            basePeraWebViewViewModel.transakBrowserPreviewFlow.map { it.pageUrlChangedEvent },
            transakBrowserControlsCollector,
        )
    }

    private fun updateUi(preview: TransakBrowserPreview) {
        binding.loadingProgressBar.loadingProgressBar.isVisible = preview.isLoading
        getAppToolbar()?.changeTitle(preview.title)
        getAppToolbar()?.changeSubtitle(preview.toolbarSubtitle)
        basePeraWebViewViewModel.getLastError()?.let {
            handleLoadingError(it)
        }
        checkWebViewControls()
    }

    private fun handleLoadingError(error: WebViewError) {
        with(binding) {
            webView.hide()
            basePeraWebViewViewModel.saveLastError(error)
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

    private fun loadUrl(preview: TransakBrowserPreview) {
        binding.webView.loadUrl(preview.url)
    }

    private fun checkWebViewControls() {
        with(binding) {
            bottomDappNavigation.previousNavButton.isEnabled = webView.canGoBack()
            bottomDappNavigation.nextNavButton.isEnabled = webView.canGoForward()
        }
    }
}
