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

import android.net.Uri

@SuppressWarnings("UnnecessaryAbstractClass")
abstract class BaseUrlBuilder constructor(baseUrl: String) {

    private val builder: Uri.Builder = Uri.parse(baseUrl).buildUpon()

    protected fun addQuery(query: UrlQueryParam, value: String) {
        builder.appendQueryParameter(query.key, value)
    }

    protected fun addUrlSlug(slugValue: String) {
        builder.appendPath(slugValue)
    }

    fun build(): String {
        return builder.build().toString()
    }

    interface UrlQueryParam {
        val key: String
    }
}
