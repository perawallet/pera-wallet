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

package com.algorand.android.utils.fonts

import android.content.Context
import android.content.res.Resources
import com.algorand.android.utils.fonts.FontStyleIdentifier.BOLD
import com.algorand.android.utils.fonts.FontStyleIdentifier.ITALIC
import com.algorand.android.utils.fonts.FontStyleIdentifier.MEDIUM
import com.algorand.android.utils.fonts.FontStyleIdentifier.REGULAR

sealed class PeraFontResource {

    protected abstract val parentFontName: String

    abstract fun getFontStyleIdentifiers(): List<FontStyleIdentifier>

    private fun getFontName(): String {
        return StringBuilder(parentFontName).apply {
            getFontStyleIdentifiers().forEach { fontStyleIdentifier ->
                append(IDENTIFIER_SPLITTER)
                append(fontStyleIdentifier.identifierName)
            }
        }.toString()
    }

    fun getFont(context: Context): Int {
        return context.resources.getIdentifier(getFontName(), FONT_RESOURCE_TYPE, context.packageName)
    }

    fun getFont(resources: Resources, packageName: String): Int {
        return resources.getIdentifier(getFontName(), FONT_RESOURCE_TYPE, packageName)
    }

    sealed class DmMono : PeraFontResource() {

        override val parentFontName: String
            get() = PARENT_FONT_NAME

        object Medium : DmMono() {
            override fun getFontStyleIdentifiers() = listOf(MEDIUM)
        }

        object Regular : DmMono() {
            override fun getFontStyleIdentifiers() = listOf(REGULAR)
        }

        companion object {
            private const val PARENT_FONT_NAME = "dmmono"
        }
    }

    sealed class DmSans : PeraFontResource() {

        override val parentFontName: String
            get() = PARENT_FONT_NAME

        object Bold : DmSans() {
            override fun getFontStyleIdentifiers() = listOf(BOLD)
        }

        object BoldItalic : DmSans() {
            override fun getFontStyleIdentifiers() = listOf(BOLD, ITALIC)
        }

        object Medium : DmSans() {
            override fun getFontStyleIdentifiers() = listOf(MEDIUM)
        }

        object MediumItalic : DmSans() {
            override fun getFontStyleIdentifiers() = listOf(MEDIUM, ITALIC)
        }

        object Regular : DmSans() {
            override fun getFontStyleIdentifiers() = listOf(REGULAR)
        }

        companion object {
            private const val PARENT_FONT_NAME = "dmsans"
        }
    }

    companion object {
        private const val FONT_RESOURCE_TYPE = "font"
        private const val IDENTIFIER_SPLITTER = "_"
    }
}
