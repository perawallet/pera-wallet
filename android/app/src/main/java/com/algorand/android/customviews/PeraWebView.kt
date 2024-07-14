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

package com.algorand.android.customviews

import android.annotation.SuppressLint
import android.content.Context
import android.util.AttributeSet
import android.webkit.CookieManager
import android.webkit.WebView
import com.algorand.android.BuildConfig
import com.algorand.android.R

class PeraWebView : WebView {
    constructor(context: Context) : super(context) {
        initView(context)
    }

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        initView(context)
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun initView(context: Context) {
        CookieManager.getInstance().removeAllCookies(null)
        CookieManager.getInstance().flush()
        this.settings.javaScriptEnabled = true
        this.settings.domStorageEnabled = true
        this.settings.javaScriptCanOpenWindowsAutomatically = true
        this.settings.allowFileAccess = false
        this.settings.userAgentString = "$USER_AGENT_PREFIX${BuildConfig.VERSION_NAME} ${settings.userAgentString}"
        this.setRendererPriorityPolicy(RENDERER_PRIORITY_IMPORTANT, false)
        this.setBackgroundColor(context.getColor(R.color.background))
    }

    companion object {
        private const val USER_AGENT_PREFIX = "pera_android_"
    }
}
