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

import com.algorand.android.BuildConfig
import com.algorand.android.discover.common.ui.model.WebViewTheme
import com.algorand.android.utils.BaseUrlBuilder

class DiscoverUrlBuilder private constructor(
    customBaseUrl: String? = null
) : BaseUrlBuilder(customBaseUrl?.trim() ?: BuildConfig.DISCOVER_URL) {

    enum class DiscoverQuery(override val key: String) : UrlQueryParam {
        THEME("theme"),
        VERSION("version"),
        PLATFORM("platform"),
        CURRENCY("currency"),
        LOCALE("locale"),
        POOL_ID("poolId"),

        TOKEN_DETAIL("token-detail"),
    }

    fun addTheme(themePreference: WebViewTheme): DiscoverUrlBuilder {
        addQuery(DiscoverQuery.THEME, themePreference.key)
        return this
    }

    fun addVersion(version: String): DiscoverUrlBuilder {
        addQuery(DiscoverQuery.VERSION, version)
        return this
    }

    fun addPlatform(): DiscoverUrlBuilder {
        addQuery(DiscoverQuery.PLATFORM, PLATFORM_NAME)
        return this
    }

    fun addCurrency(currency: String): DiscoverUrlBuilder {
        addQuery(DiscoverQuery.CURRENCY, currency)
        return this
    }

    fun addLocale(locale: String): DiscoverUrlBuilder {
        addQuery(DiscoverQuery.LOCALE, locale)
        return this
    }

    fun addTokenDetail(tokenId: String, poolId: String?): DiscoverUrlBuilder {
        addUrlSlug(DiscoverQuery.TOKEN_DETAIL.key)
        addUrlSlug(tokenId)
        poolId?.let {
            addQuery(DiscoverQuery.POOL_ID, it)
        }
        return this
    }

    companion object {
        const val PLATFORM_NAME = "android"
        fun create(customBaseUrl: String? = null): DiscoverUrlBuilder {
            return DiscoverUrlBuilder(customBaseUrl)
        }
    }
}
