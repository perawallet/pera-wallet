/*
 * Copyright 2019 Algorand, Inc.
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

import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.models.Result
import com.algorand.android.utils.Resource
import com.hipo.hipoexceptionsandroid.RetrofitErrorHandler
import java.io.IOException
import retrofit2.Response

/**
 * Wrap a suspending API [call] in try/catch. In case an exception is thrown, a [Result.Error] is
 * created based on the [errorMessage].
 */
suspend fun <T : Any> safeApiCall(call: suspend () -> Result<T>): Result<T> {
    return try {
        call()
    } catch (e: Exception) {
        // An exception was thrown when calling the API so we're converting this to an IOException
        Result.Error(IOException(null, e))
    }
}

suspend fun <T : Any> request(
    onFailed: ((Response<T>) -> Result<T>)? = null,
    doRequest: suspend () -> Response<T>
): Result<T> {
    return safeApiCall {
        with(doRequest()) {
            if (isSuccessful && body() != null) {
                Result.Success(body() as T)
            } else {
                onFailed?.invoke(this) ?: Result.Error(Exception(errorBody().toString()))
            }
        }
    }
}

suspend fun <T : Any> requestWithHipoErrorHandler(
    hipoApiErrorHandler: RetrofitErrorHandler,
    doRequest: suspend () -> Response<T>
): Result<T> {
    return request(
        doRequest = doRequest,
        onFailed = { errorResponse -> hipoApiErrorHandler.getMessageAsResultError(errorResponse) }
    )
}

fun <T> RetrofitErrorHandler.getMessageAsResultError(response: Response<T>): Result.Error {
    return Result.Error(Exception(parse(response).message))
}

fun Result.Error.getAsResourceError(): Resource.Error {
    return when (this.exception) {
        is IOException -> {
            Resource.Error.Annotated(AnnotatedString(R.string.the_internet_connection))
        }
        else -> {
            Resource.Error.Api(this.exception)
        }
    }
}
