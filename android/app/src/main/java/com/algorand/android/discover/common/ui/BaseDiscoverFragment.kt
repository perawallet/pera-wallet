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

package com.algorand.android.discover.common.ui

import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.webkit.WebSettings
import androidx.annotation.LayoutRes
import androidx.core.content.ContextCompat
import androidx.viewbinding.ViewBinding
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.customviews.PeraWebView
import com.algorand.android.discover.common.ui.model.PeraWebViewClient
import com.algorand.android.discover.common.ui.model.WebViewTheme
import com.algorand.android.discover.utils.getJavascriptThemeChangeFunctionForTheme
import com.algorand.android.models.AnnotatedString
import com.algorand.android.utils.PERA_VERIFICATION_MAIL_ADDRESS
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.getCustomLongClickableSpan
import com.algorand.android.utils.preference.ThemePreference
import com.algorand.android.utils.sendMailRequestUrl

abstract class BaseDiscoverFragment(
    @LayoutRes private val layoutResId: Int,
) : BaseFragment(layoutResId) {

    abstract val binding: ViewBinding

    abstract val discoverViewModel: BaseDiscoverViewModel

    protected val peraWebViewClientListener = object : PeraWebViewClient.PeraWebViewClientListener {
        override fun onWalletConnectUrlDetected(url: String) {
            handleWalletConnectUrl(url)
        }

        override fun onEmailRequested(url: String) {
            handleMailRequestUrl(url)
        }

        override fun onPageRequested() {
            discoverViewModel.onPageRequested()
        }

        override fun onPageFinished() {
            discoverViewModel.onPageFinished()
        }

        override fun onError() {
            discoverViewModel.onError()
        }

        override fun onHttpError() {
            discoverViewModel.onHttpError()
        }

        override fun onPageUrlChanged() {
            discoverViewModel.onPageUrlChanged()
        }
    }

    abstract fun onReportActionFailed()

    abstract fun bindWebView(view: View?)

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val view = super.onCreateView(inflater, container, savedInstanceState)
        discoverViewModel.getWebView()?.let { previousWebView ->
            // If we have a previously saved WebView, it is reloaded, bound and theming set
            reloadWebView(view, previousWebView)
            bindWebView(view)
            val themePreference = discoverViewModel.getDiscoverThemePreference()
            getWebView(binding.root)?.let { currentWebView ->
                handleWebViewTheme(themePreference, currentWebView)
                currentWebView.evaluateJavascript(
                    getJavascriptThemeChangeFunctionForTheme(getWebViewThemeFromThemePreference(themePreference)),
                    null
                )
            } // Otherwise we just bind the view as we have no previously saved state to show
        } ?: bindWebView(view)
        return view
    }

    override fun onDestroyView() {
        super.onDestroyView()
        getWebView(binding.root)?.let { discoverViewModel.saveWebView(it) }
    }

    protected fun getTitleForFailedReport(): AnnotatedString {
        return AnnotatedString(R.string.report_an_asa)
    }

    protected fun getDescriptionForFailedReport(): AnnotatedString {
        val longClickSpannable = getCustomLongClickableSpan(
            clickableColor = ContextCompat.getColor(binding.root.context, R.color.positive),
            onLongClick = { context?.copyToClipboard(PERA_VERIFICATION_MAIL_ADDRESS) }
        )
        return AnnotatedString(
            stringResId = R.string.you_can_send_us_an,
            customAnnotationList = listOf("verification_mail_click" to longClickSpannable),
            replacementList = listOf("verification_mail" to PERA_VERIFICATION_MAIL_ADDRESS)
        )
    }

    protected fun handleMailRequestUrl(url: String) {
        context?.sendMailRequestUrl(url, ::onReportActionFailed)
    }

    protected fun getWebViewThemeFromThemePreference(themePreference: ThemePreference): WebViewTheme {
        val themeFromSystem = when (
            resources.configuration.uiMode and
                Configuration.UI_MODE_NIGHT_MASK
        ) {
            Configuration.UI_MODE_NIGHT_YES -> WebViewTheme.DARK
            Configuration.UI_MODE_NIGHT_NO -> WebViewTheme.LIGHT
            else -> null
        }
        return WebViewTheme.getByThemePreference(themePreference, themeFromSystem)
    }

    private fun handleWebViewTheme(
        themePreference: ThemePreference,
        webView: PeraWebView
    ) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            when (
                getWebViewThemeFromThemePreference(themePreference)
            ) {
                WebViewTheme.DARK -> webView.settings.forceDark = WebSettings.FORCE_DARK_ON
                WebViewTheme.LIGHT -> webView.settings.forceDark = WebSettings.FORCE_DARK_OFF
            }
        }
    }

    private fun getWebView(parent: View): PeraWebView? {
        if (parent is ViewGroup) {
            for (cx in 0 until parent.childCount) {
                val child = parent.getChildAt(cx)
                if (child is PeraWebView) {
                    return child
                }
            }
        }
        return null
    }

    private fun reloadWebView(parent: View?, webView: PeraWebView) {
        if (parent is ViewGroup) {
            for (cx in 0 until parent.childCount) {
                val child = parent.getChildAt(cx)
                if (child is PeraWebView) {
                    val index = parent.indexOfChild(child)
                    parent.removeView(child)
                    (webView.parent as ViewGroup).removeView(webView)
                    parent.addView(webView, index)
                }
            }
        }
    }
}
