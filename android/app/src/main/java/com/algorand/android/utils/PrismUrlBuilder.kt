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

class PrismUrlBuilder private constructor(url: String) {

    private val baseUrl: StringBuilder = StringBuilder(url.trim()).append(QUERY_SYMBOL)

    fun addWidth(width: Int): PrismUrlBuilder {
        addQuery(Query.WIDTH, width.toString())
        return this
    }

    fun addHeight(height: Int): PrismUrlBuilder {
        addQuery(Query.HEIGHT, height.toString())
        return this
    }

    fun addQuality(quality: Int): PrismUrlBuilder {
        addQuery(Query.QUALITY, quality.toString())
        return this
    }

    fun addImageUrl(imageUrl: String): PrismUrlBuilder {
        addQuery(Query.IMAGE_URL, imageUrl)
        baseUrl.append(QUERY_SYMBOL)
        return this
    }

    fun build(): String {
        return baseUrl.apply {
            removeSuffix(QUERY_DIVIDER)
            removeSuffix(QUERY_SYMBOL)
        }.toString()
    }

    private fun addQuery(query: Query, queryValue: String) {
        if (!baseUrl.endsWith(QUERY_SYMBOL)) {
            baseUrl.append(QUERY_DIVIDER)
        }
        baseUrl.append(query.key).append(QUERY_KEY_VALUE_SEPARATOR).append(queryValue)
    }

    private enum class Query(val key: String) {
        WIDTH("width"),
        HEIGHT("height"),
        QUALITY("quality"),
        IMAGE_URL("image_url")
    }

    companion object {

        const val DEFAULT_IMAGE_QUALITY = 70
        private const val QUERY_SYMBOL = "?"
        private const val QUERY_DIVIDER = "&"
        private const val QUERY_KEY_VALUE_SEPARATOR = "="

        fun create(url: String): PrismUrlBuilder {
            return PrismUrlBuilder(url)
        }
    }
}
