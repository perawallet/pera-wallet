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

import android.os.Build
import com.algorand.android.BuildConfig
import com.algorand.android.models.Node
import javax.inject.Singleton
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import okhttp3.Interceptor
import okhttp3.Response

@Singleton
class MobileHeaderInterceptor(
    private val packageName: String = BuildConfig.APPLICATION_ID,
    private val appVersion: String = BuildConfig.VERSION_NAME,
    private vararg val otherHeaders: Pair<String, String>,
    private val appName: String? = null,
    private val clientType: String = DEFAULT_CLIENT_TYPE,
    private val osVersion: String = Build.VERSION.SDK_INT.toString(),
    private val deviceModel: String = Build.MODEL
) : Interceptor {

    private val defaultAppName = packageName.split('.')
        .run { elementAtOrNull(THIRD_ITEM_INDEX) ?: elementAtOrNull(SECOND_ITEM_INDEX).orEmpty() }
        .capitalize()

    var currentActiveNode: Node? = null

    override fun intercept(chain: Interceptor.Chain): Response {
        val request = chain.request()

        val requestBuilder = request.newBuilder()

        currentActiveNode?.let { currentActiveNode ->
            if (request.header(ALGORAND_NETWORK_KEY) == null) {
                requestBuilder.addHeader(ALGORAND_NETWORK_KEY, currentActiveNode.networkSlug)
            }

            val baseUrl = currentActiveNode.mobileAlgorandAddress.toHttpUrlOrNull()
            if (baseUrl != null) {
                val newUrl = chain.request().url.newBuilder()
                    .scheme(baseUrl.scheme)
                    .host(baseUrl.toUrl().toURI().host)
                    .port(baseUrl.port)
                    .build()

                requestBuilder.url(newUrl)
            }
        }

        requestBuilder.addHeader(KEY_APP_NAME, appName ?: defaultAppName)
            .addHeader(KEY_CLIENT_TYPE, clientType)
            .addHeader(KEY_DEVICE_OS_VERSION, osVersion)
            .addHeader(KEY_APP_PACKAGE_NAME, packageName)
            .addHeader(KEY_APP_VERSION, appVersion)
            .addHeader(KEY_DEVICE_MODEL, deviceModel)
            .apply {
                otherHeaders.forEach { header ->
                    addHeader(header.first, header.second)
                }
            }
        return chain.proceed(requestBuilder.build())
    }

    companion object {
        const val ALGORAND_NETWORK_KEY = "algorand-network"
        private const val KEY_APP_NAME = "App-Name"
        private const val KEY_CLIENT_TYPE = "Client-Type"
        private const val KEY_DEVICE_OS_VERSION = "Device-OS-Version"
        private const val KEY_APP_PACKAGE_NAME = "App-Package-Name"
        private const val KEY_APP_VERSION = "App-Version"
        private const val KEY_DEVICE_MODEL = "Device-Model"
        private const val DEFAULT_CLIENT_TYPE = "android"
        private const val SECOND_ITEM_INDEX = 1
        private const val THIRD_ITEM_INDEX = 2
    }
}
