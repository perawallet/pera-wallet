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

package com.algorand.android.modules.perawebview.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.annotation.LayoutRes
import androidx.viewbinding.ViewBinding
import com.algorand.android.customviews.PeraWebView
import com.algorand.android.discover.common.ui.model.PeraWebViewClient
import com.algorand.android.modules.basewebview.ui.BaseWebViewFragment
import com.algorand.android.utils.sendMailRequestUrl

abstract class BasePeraWebViewFragment(
    @LayoutRes private val layoutResId: Int,
) : BaseWebViewFragment(layoutResId) {

    abstract val binding: ViewBinding

    abstract fun bindWebView(view: View?)

    abstract val basePeraWebViewViewModel: BasePeraWebViewViewModel

    protected val peraWebViewClientListener = object : PeraWebViewClient.PeraWebViewClientListener {
        override fun onWalletConnectUrlDetected(url: String) {
            handleWalletConnectUrl(url)
        }

        override fun onEmailRequested(url: String) {
            handleMailRequestUrl(url)
        }

        override fun onPageRequestedShouldOverrideUrlLoading(url: String): Boolean {
            return basePeraWebViewViewModel.onPageRequestedShouldOverrideUrlLoading(url)
        }

        override fun onPageStarted() {
            basePeraWebViewViewModel.onPageStarted()
        }

        override fun onPageFinished(title: String?, url: String?) {
            basePeraWebViewViewModel.onPageFinished(title, url)
        }

        override fun onError() {
            basePeraWebViewViewModel.onError()
        }

        override fun onHttpError() {
            basePeraWebViewViewModel.onHttpError()
        }

        override fun onPageUrlChanged() {
            basePeraWebViewViewModel.onPageUrlChanged()
        }

        override fun onRenderProcessGone() {
            basePeraWebViewViewModel.destroyWebView()
        }
    }

    open fun onSendMailRequestFailed() {}

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val view = super.onCreateView(inflater, container, savedInstanceState)
        basePeraWebViewViewModel.getWebView()?.let { previousWebView ->
            // If we have a previously saved WebView, it is reloaded, bound and theming set
            reloadWebView(view, previousWebView)
            bindWebView(view)
        } ?: bindWebView(view)
        getWebView(binding.root)?.let { basePeraWebViewViewModel.saveWebView(it) }
        return view
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

    protected fun handleMailRequestUrl(url: String) {
        context?.sendMailRequestUrl(url, ::onSendMailRequestFailed)
    }

    override fun onDestroyView() {
        super.onDestroyView()
        getWebView(binding.root)?.let { basePeraWebViewViewModel.saveWebView(it) }
    }

    protected fun getWebView(parent: View): PeraWebView? {
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
}
