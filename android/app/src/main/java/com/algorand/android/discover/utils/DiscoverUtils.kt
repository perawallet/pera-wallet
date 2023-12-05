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

package com.algorand.android.discover.utils

import android.util.Base64
import com.algorand.android.BuildConfig
import com.algorand.android.discover.common.ui.model.WebViewTheme

private const val WEBVIEW_AUTH_USERNAME = BuildConfig.DISCOVER_WEBVIEW_USERNAME
private const val WEBVIEW_AUTH_SEPARATOR = ":"
private const val WEBVIEW_AUTH_PASSWORD = BuildConfig.DISCOVER_WEBVIEW_PASSWORD
private const val WEBVIEW_AUTH_HEADER_NAME = "Authorization"
private const val WEBVIEW_AUTH_HEADER_PREFIX = "Basic "

val regexPatternPeraURL = """^https://([\da-z-]+\.)*(?<!web\.)perawallet\.app((?:/.*)?|(?:\?.*)?|(?:#.*)?)""".toRegex()

fun getDiscoverHomeUrl(
    themePreference: WebViewTheme,
    currency: String,
    locale: String,
): String {
    return DiscoverUrlBuilder.create()
        .addTheme(themePreference)
        .addVersion(BuildConfig.DISCOVER_VERSION)
        .addPlatform()
        .addCurrency(currency)
        .addLocale(locale)
        .build()
}

fun getDiscoverTokenDetailUrl(
    themePreference: WebViewTheme,
    tokenId: String,
    poolId: String?,
    currency: String,
    locale: String,
): String {
    return DiscoverUrlBuilder.create()
        .addTheme(themePreference)
        .addVersion(BuildConfig.DISCOVER_VERSION)
        .addPlatform()
        .addCurrency(currency)
        .addLocale(locale)
        .addTokenDetail(tokenId, poolId)
        .build()
}

fun getDiscoverCustomUrl(
    url: String,
    themePreference: WebViewTheme,
    currency: String,
    locale: String,
): String {
    return DiscoverUrlBuilder.create(url)
        .addTheme(themePreference)
        .addVersion(BuildConfig.DISCOVER_VERSION)
        .addPlatform()
        .addCurrency(currency)
        .addLocale(locale)
        .build()
}

fun getDiscoverAuthHeader(): HashMap<String, String> {
    val headers: HashMap<String, String> = HashMap()
    val basicAuthHeader = Base64.encodeToString(
        (WEBVIEW_AUTH_USERNAME + WEBVIEW_AUTH_SEPARATOR + WEBVIEW_AUTH_PASSWORD).toByteArray(),
        Base64.NO_WRAP,
    )
    headers[WEBVIEW_AUTH_HEADER_NAME] = WEBVIEW_AUTH_HEADER_PREFIX + basicAuthHeader
    return headers
}

fun isValidDiscoverURL(url: String): Boolean {
    return url.matches(regexPatternPeraURL)
}
