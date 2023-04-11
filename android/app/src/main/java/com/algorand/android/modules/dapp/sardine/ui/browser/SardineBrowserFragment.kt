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

package com.algorand.android.modules.dapp.sardine.ui.browser

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.databinding.FragmentSardineBrowserBinding
import com.algorand.android.discover.common.ui.model.PeraWebViewClient
import com.algorand.android.discover.common.ui.model.WebViewError
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.dapp.sardine.ui.browser.model.SardineBrowserPreview
import com.algorand.android.modules.perawebview.ui.BasePeraWebViewFragment
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class SardineBrowserFragment :
    BasePeraWebViewFragment(R.layout.fragment_sardine_browser) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleColor = R.color.text_main,
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack,
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration
    )

    override lateinit var binding: FragmentSardineBrowserBinding

    override val basePeraWebViewViewModel: SardineBrowserViewModel by viewModels()

    override fun bindWebView(view: View?) {
        view?.let { binding = FragmentSardineBrowserBinding.bind(it) }
    }

    private val sardineBrowserPreviewCollector: suspend (SardineBrowserPreview) -> Unit = { preview ->
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

    private val sardineBrowserControlsCollector: suspend (Event<Unit>?) -> Unit = { event ->
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
            basePeraWebViewViewModel.sardineBrowserPreviewFlow,
            sardineBrowserPreviewCollector,
        )
        viewLifecycleOwner.collectOnLifecycle(
            basePeraWebViewViewModel.sardineBrowserPreviewFlow.map { it.pageUrlChangedEvent },
            sardineBrowserControlsCollector,
        )
    }

    private fun updateUi(preview: SardineBrowserPreview) {
        binding.loadingProgressBar.loadingProgressBar.isVisible = preview.isLoading
        getAppToolbar()?.apply {
            changeTitle(preview.title)
            changeSubtitle(preview.toolbarSubtitle)
        }
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

    private fun loadUrl(preview: SardineBrowserPreview) {
        binding.webView.loadUrl(preview.url)
    }

    private fun checkWebViewControls() {
        with(binding) {
            bottomDappNavigation.previousNavButton.isEnabled = webView.canGoBack()
            bottomDappNavigation.nextNavButton.isEnabled = webView.canGoForward()
        }
    }
}
