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

package com.algorand.android.models

import com.algorand.android.R
import com.algorand.android.utils.Resource
import java.io.IOException

/**
 * A generic class that holds a value with its loading status.
 * @param <T>
 */
sealed class Result<out T : Any> {

    data class Success<out T : Any>(val data: T) : Result<T>()
    data class Error(val exception: Exception, val code: Int? = null) : Result<Nothing>() {
        fun getAsResourceError(): Resource.Error {
            return when (exception) {
                is ExceptionErrorParser -> exception.getAsResourceError()
                is IOException -> {
                    Resource.Error.Annotated(AnnotatedString(R.string.the_internet_connection))
                }
                else -> Resource.Error.Api(exception)
            }
        }
    }

    suspend fun use(onSuccess: (suspend (T) -> Unit)? = null, onFailed: (suspend (Exception, Int?) -> Unit)? = null) {
        when (this) {
            is Success -> onSuccess?.invoke(data)
            is Error -> onFailed?.invoke(exception, code)
        }
    }

    suspend fun <R : Any> map(transform: suspend (T) -> R): Result<R> {
        return when (this) {
            is Success -> Success(transform(data))
            is Error -> Error(exception, code)
        }
    }

    override fun toString(): String {
        return when (this) {
            is Success<*> -> "Success[data=$data]"
            is Error -> "Error[exception=$exception]"
        }
    }
}
