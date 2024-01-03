/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.network

import okhttp3.Interceptor
import okhttp3.Protocol
import okhttp3.Request
import okhttp3.Response
import okhttp3.ResponseBody.Companion.toResponseBody

abstract class PeraInterceptor : Interceptor {

    abstract fun safeIntercept(chain: Interceptor.Chain): Response

    override fun intercept(chain: Interceptor.Chain): Response {
        return try {
            safeIntercept(chain)
        } catch (exception: Exception) {
            createDefaultResponse(chain.request(), exception)
        }
    }

    private fun createDefaultResponse(request: Request, exception: Exception): Response {
        return Response.Builder()
            .request(request)
            .protocol(Protocol.HTTP_1_1)
            .code(HTTP_STATUS_99_CODE)
            .message(HTTP_STATUS_99_MESSAGE)
            .body(exception.toString().toResponseBody(null))
            .build()
    }

    companion object {
        // TODO: Handle different error types with different error codes
        private const val HTTP_STATUS_99_CODE = 99
        private const val HTTP_STATUS_99_MESSAGE = "API request is failed on the client"
    }
}
