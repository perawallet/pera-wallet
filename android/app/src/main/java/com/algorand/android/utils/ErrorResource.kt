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
import com.algorand.android.models.AnnotatedString

sealed class ErrorResource {

    abstract fun parseError(context: Context): String

    abstract fun parseTitle(context: Context): String?

    sealed class LocalErrorResource : ErrorResource() {

        data class Local(@StringRes val errorResId: Int, @StringRes val title: Int? = null) : LocalErrorResource() {

            override fun parseError(context: Context): String {
                return context.getString(errorResId)
            }

            override fun parseTitle(context: Context): String? {
                return context.getString(title ?: return null)
            }
        }

        // TODO Combine with Local error resource
        class Defined(
            val description: AnnotatedString,
            val title: AnnotatedString? = null
        ) : LocalErrorResource() {
            override fun parseError(context: Context): String {
                return context.getXmlStyledString(description).toString()
            }

            override fun parseTitle(context: Context): String? {
                return context.getXmlStyledString(title ?: return null).toString()
            }
        }
    }

    data class Api(val message: String) : ErrorResource() {
        override fun parseError(context: Context): String {
            return message
        }

        override fun parseTitle(context: Context): String? = null
    }
}
