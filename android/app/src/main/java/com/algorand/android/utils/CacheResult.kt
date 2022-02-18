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

sealed class CacheResult<T> {
    abstract val data: T?
    abstract val creationTimestamp: Long?

    data class Success<T> private constructor(
        override val data: T,
        override val creationTimestamp: Long
    ) : CacheResult<T>() {

        companion object {
            fun <T> create(data: T): Success<T> {
                return Success(data, System.currentTimeMillis())
            }
        }
    }

    data class Error<T> private constructor(
        val exception: Throwable?,
        val code: Int? = null,
        override val data: T? = null,
        override val creationTimestamp: Long? = null
    ) : CacheResult<T>() {

        companion object {
            fun <T> create(exception: Throwable?, code: Int? = null, previousData: CacheResult<T>? = null): Error<T> {
                return Error(exception, code, previousData?.data, previousData?.creationTimestamp)
            }
        }
    }

    suspend fun useSuspended(
        onSuccess: (suspend (CacheResult<T>) -> Unit)? = null,
        onFailed: (suspend (Error<T>) -> Unit)? = null,
    ) {
        when (this) {
            is Success -> onSuccess?.invoke(this)
            is Error -> onFailed?.invoke(this)
        }
    }
}
