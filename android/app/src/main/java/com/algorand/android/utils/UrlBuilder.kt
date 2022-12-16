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

package com.algorand.android.utils

abstract class UrlBuilder {

    abstract val baseUrl: StringBuilder

    protected fun addQuery(query: Query, queryValue: String) {
        if (!baseUrl.endsWith(QUERY_SYMBOL)) {
            baseUrl.append(QUERY_DIVIDER)
        }
        baseUrl.append(query.key).append(QUERY_KEY_VALUE_SEPARATOR).append(queryValue)
    }

    protected fun addUrlSlug(slug: UrlSlug, slugValue: String) {
        val (urlRoot, queries) = baseUrl.split(QUERY_SYMBOL, limit = URL_SPLIT_PIECES)
        baseUrl.clear()
        baseUrl.append(urlRoot)
        baseUrl.append(slug.key).append(SLUG_DIVIDER).append(slugValue).append(SLUG_DIVIDER)
        baseUrl.append(QUERY_SYMBOL).append(queries)
    }

    fun build(): String {
        return baseUrl.apply {
            removeSuffix(QUERY_DIVIDER)
            removeSuffix(QUERY_SYMBOL)
        }.toString()
    }

    enum class Query(val key: String) {

        // Prism
        WIDTH("width"),
        HEIGHT("height"),
        QUALITY("quality"),
        IMAGE_URL("image_url"),

        // Discover
        THEME("theme"),
        VERSION("version"),
        PLATFORM("platform"),
        CURRENCY("currency"),
        LOCALE("locale"),
        POOL_ID("poolId"),
    }

    enum class UrlSlug(val key: String) {

        // Discover
        TOKEN_DETAIL("token-detail"),
    }

    companion object {
        const val QUERY_SYMBOL = "?"
        const val QUERY_DIVIDER = "&"
        const val QUERY_KEY_VALUE_SEPARATOR = "="

        private const val SLUG_DIVIDER = "/"

        // We split the url in two to separate URL slugs and queries
        private const val URL_SPLIT_PIECES = 2
    }
}
