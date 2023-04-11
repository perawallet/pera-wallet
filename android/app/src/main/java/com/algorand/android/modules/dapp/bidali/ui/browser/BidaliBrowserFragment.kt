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

package com.algorand.android.modules.dapp.bidali.ui.browser

import android.annotation.SuppressLint
import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.databinding.FragmentBidaliBrowserBinding
import com.algorand.android.discover.common.ui.model.PeraWebViewClient
import com.algorand.android.discover.common.ui.model.WebViewError
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.dapp.bidali.domain.BidaliWebInterface
import com.algorand.android.modules.dapp.bidali.ui.browser.model.BidaliBrowserPreview
import com.algorand.android.modules.perawebview.ui.BasePeraWebViewFragment
import com.algorand.android.ui.send.confirmation.ui.TransactionConfirmationFragment.Companion.TRANSACTION_CONFIRMATION_KEY
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.useFragmentResultListenerValue
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class BidaliBrowserFragment :
    BasePeraWebViewFragment(R.layout.fragment_bidali_browser),
    BidaliWebInterface.WebInterfaceListener {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.bidali,
        titleColor = R.color.text_main,
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack,
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        isBottomBarNeeded = false,
    )

    override lateinit var binding: FragmentBidaliBrowserBinding

    override val basePeraWebViewViewModel: BidaliBrowserViewModel by viewModels()

    override fun bindWebView(view: View?) {
        view?.let { binding = FragmentBidaliBrowserBinding.bind(it) }
    }

    private val bidaliBrowserPreviewCollector: suspend (BidaliBrowserPreview) -> Unit = { preview ->
        with(preview) {
            updateUi(this)
            loadingErrorEvent?.consume()?.run {
                handleLoadingError(this)
            }
            reloadPageEvent?.consume()?.run {
                loadUrl(preview)
            }
            pageStartedEvent?.consume()?.run {
                handleBidaliJavascript()
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
            onPaymentRequestEvent?.consume()?.run {
                // TODO handle transaction not created successfully
                val transaction = basePeraWebViewViewModel.getTransactionDataFromPaymentRequest(this)
                transaction?.let {
                    nav(
                        BidaliBrowserFragmentDirections.actionBidaliBrowserFragmentToSendAlgoNavigation(it),
                    )
                }
            }
            openUrlRequestEvent?.consume()?.run {
                binding.webView.loadUrl(this.url)
            }
            updatedBalancesJavascript?.run {
                binding.webView.evaluateJavascript(this, null)
            }
        }
    }

    private val bidaliBrowserControlsCollector: suspend (Event<Unit>?) -> Unit = { event ->
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

    override fun onResume() {
        super.onResume()
        useFragmentResultListenerValue<Boolean>(TRANSACTION_CONFIRMATION_KEY) { isConfirmed ->
            if (isConfirmed) {
                sendTransactionSuccessfulResultToWebView()
                updateWebViewBalances()
            } else {
                sendTransactionFailedResultToWebView()
            }
        }
    }

    private fun customizeToolbar() {
        getAppToolbar()?.apply {
            setEndButtons(
                buttons = listOf(
                    IconButton(R.drawable.ic_reload, onClick = ::onReloadPage),
                ),
            )
        }
    }

    private fun onReloadPage() {
        binding.webView.reload()
    }

    override fun onPaymentRequest(data: String) {
        basePeraWebViewViewModel.onPaymentRequest(data)
    }

    override fun openUrl(data: String) {
        basePeraWebViewViewModel.openUrl(data)
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun initUi() {
        with(binding) {
            tryAgainButton.setOnClickListener { basePeraWebViewViewModel.reloadPage() }
            val bidaliWebInterface = BidaliWebInterface.create(this@BidaliBrowserFragment)
            webView.addJavascriptInterface(bidaliWebInterface, BidaliWebInterface.WEB_INTERFACE_NAME)
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
            basePeraWebViewViewModel.bidaliBrowserPreviewFlow,
            bidaliBrowserPreviewCollector,
        )
        viewLifecycleOwner.collectOnLifecycle(
            basePeraWebViewViewModel.bidaliBrowserPreviewFlow.map { it.pageUrlChangedEvent },
            bidaliBrowserControlsCollector,
        )
    }

    private fun updateUi(preview: BidaliBrowserPreview) {
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

    private fun loadUrl(preview: BidaliBrowserPreview) {
        binding.webView.loadUrl(preview.url)
    }

    private fun checkWebViewControls() {
        with(binding) {
            bottomDappNavigation.previousNavButton.isEnabled = webView.canGoBack()
            bottomDappNavigation.nextNavButton.isEnabled = webView.canGoForward()
        }
    }

    private fun handleBidaliJavascript() {
        binding.webView.evaluateJavascript(basePeraWebViewViewModel.generateBidaliJavascript(), null)
    }

    private fun sendTransactionSuccessfulResultToWebView() {
        binding.webView.evaluateJavascript(
            basePeraWebViewViewModel.generateTransactionSuccessfulJavascript(),
            null
        )
    }

    private fun updateWebViewBalances() {
        basePeraWebViewViewModel.generateUpdatedBalancesJavascript()
    }

    private fun sendTransactionFailedResultToWebView() {
        binding.webView.evaluateJavascript(
            basePeraWebViewViewModel.generateTransactionFailedJavascript(),
            null,
        )
    }
}
