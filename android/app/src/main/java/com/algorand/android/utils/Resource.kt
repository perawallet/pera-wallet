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

import android.content.Context
import androidx.annotation.StringRes
import androidx.navigation.NavDirections
import com.algorand.android.models.AnnotatedString

/**
 * A generic class that holds a value with its loading status.
 * @param <T>
</T> */
sealed class Resource<out T> {
    data class Success<T>(val data: T?) : Resource<T>()
    sealed class Error : Resource<Nothing>() {
        data class Annotated(val annotatedString: AnnotatedString) : Error()
        data class Api(val exception: Throwable) : Error()
        data class Warning(@StringRes val titleRes: Int, val annotatedString: AnnotatedString) : Error()
        data class Navigation(val navDirections: NavDirections) : Error()
        data class Local(val message: String) : Error()
        data class GlobalWarning(@StringRes val titleRes: Int? = null, val annotatedString: AnnotatedString) : Error()

        fun parse(context: Context): CharSequence? {
            return when (this) {
                is Annotated -> context.getXmlStyledString(annotatedString)
                is Api -> exception.message.orEmpty()
                is Local -> message
                is GlobalWarning -> context.getXmlStyledString(annotatedString)
                else -> null
            }
        }
    }

    object Loading : Resource<Nothing>()
    object OnLoadingFinished : Resource<Nothing>()

    fun use(
        onSuccess: ((T) -> Unit)? = null,
        onFailed: ((Error) -> Unit)? = null,
        onLoading: (() -> Unit)? = null,
        onLoadingFinished: (() -> Unit)? = null
    ) {
        when (this) {
            is Success -> {
                onLoadingFinished?.invoke()
                if (data != null) {
                    onSuccess?.invoke(data)
                }
            }
            is Error -> {
                onLoadingFinished?.invoke()
                onFailed?.invoke(this)
            }
            is Loading -> {
                onLoading?.invoke()
            }
            is OnLoadingFinished -> {
                onLoadingFinished?.invoke()
            }
        }
    }
}
