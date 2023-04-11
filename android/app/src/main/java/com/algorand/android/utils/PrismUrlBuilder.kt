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

class PrismUrlBuilder private constructor(url: String) : BaseUrlBuilder(url.trim()) {

    enum class PrismQuery(override val key: String) : UrlQueryParam {
        WIDTH("width"),
        HEIGHT("height"),
        QUALITY("quality"),
        IMAGE_URL("image_url"),
    }

    fun addWidth(width: Int): PrismUrlBuilder {
        addQuery(PrismQuery.WIDTH, width.toString())
        return this
    }

    fun addHeight(height: Int): PrismUrlBuilder {
        addQuery(PrismQuery.HEIGHT, height.toString())
        return this
    }

    fun addQuality(quality: Int): PrismUrlBuilder {
        addQuery(PrismQuery.QUALITY, quality.toString())
        return this
    }

    fun addImageUrl(imageUrl: String): PrismUrlBuilder {
        addQuery(PrismQuery.IMAGE_URL, imageUrl)
        return this
    }

    companion object {

        const val DEFAULT_IMAGE_SIZE = 1024
        const val DEFAULT_IMAGE_QUALITY = 70

        fun create(url: String): PrismUrlBuilder {
            return PrismUrlBuilder(url)
        }
    }
}
