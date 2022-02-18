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

/**
 * A generic class that holds a value with its loading status.
 * @param <T>
</T> */
sealed class DataResource<T> {

    data class Success<T>(val data: T) : DataResource<T>()

    sealed class Error<T>(
        open val exception: Throwable? = null,
        open val code: Int? = null,
        open val data: T? = null
    ) : DataResource<T>() {

        data class Api<T>(override val exception: Throwable, override val code: Int?) : Error<T>(exception, code)
        data class Local<T>(override val exception: Throwable) : Error<T>(exception)
    }

    class Loading<T> : DataResource<T>()

    suspend fun useSuspended(
        onSuccess: (suspend (T) -> Unit)? = null,
        onFailed: (suspend (Error<T>) -> Unit)? = null,
        onLoading: (suspend () -> Unit)? = null,
    ) {
        when (this) {
            is Success -> onSuccess?.invoke(data)
            is Error<T> -> onFailed?.invoke(this)
            is Loading -> onLoading?.invoke()
        }
    }
}
