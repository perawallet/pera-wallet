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

package com.algorand.android.network

import com.algorand.android.models.Node
import javax.inject.Singleton
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import okhttp3.Interceptor
import okhttp3.Response

@Singleton
class IndexerInterceptor : Interceptor {

    var currentActiveNode: Node? = null

    override fun intercept(chain: Interceptor.Chain): Response {
        val request = chain.request()

        val requestBuilder = request.newBuilder()

        currentActiveNode?.let { currentActiveNode ->
            requestBuilder.addHeader(NODE_TOKEN_HEADER_KEY, currentActiveNode.indexerApiKey)

            val baseUrl = currentActiveNode.indexerAddress.toHttpUrlOrNull()

            if (baseUrl != null) {
                val newUrl = chain.request().url.newBuilder()
                    .scheme(baseUrl.scheme)
                    .host(baseUrl.toUrl().toURI().host)
                    .port(baseUrl.port)
                    .build()

                requestBuilder
                    .url(newUrl)
                    .build()
            }
        }
        return chain.proceed(requestBuilder.build())
    }

    companion object {
        private const val NODE_TOKEN_HEADER_KEY = "X-Indexer-API-Token"
    }
}
