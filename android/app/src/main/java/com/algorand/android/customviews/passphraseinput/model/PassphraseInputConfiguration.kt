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

package com.algorand.android.customviews.passphraseinput.model

import com.algorand.android.R

sealed class PassphraseInputConfiguration {

    abstract val index: Int
    abstract val order: Int
    abstract var input: String
    abstract val imeOptions: Int

    abstract val textColor: Int
    abstract val indexTextColor: Int
    abstract val underLineColor: Int
    abstract val underLineHeight: Int

    abstract fun toFocused(): PassphraseInputConfiguration
    abstract fun toUnfocused(): PassphraseInputConfiguration
    abstract fun toInvalid(): PassphraseInputConfiguration
    abstract fun toValid(): PassphraseInputConfiguration

    sealed class Valid : PassphraseInputConfiguration() {
        override val textColor: Int = R.color.text_main

        data class Focused(
            override var input: String,
            override val order: Int,
            override val index: Int,
            override val imeOptions: Int
        ) : Valid() {
            override val indexTextColor: Int = R.color.text_main
            override val underLineColor: Int = R.color.text_main
            override val underLineHeight: Int = R.dimen.passphrase_input_bottom_line_focused

            override fun toUnfocused(): PassphraseInputConfiguration {
                return Unfocused(input = input, order = order, index = index, imeOptions = imeOptions)
            }

            override fun toFocused(): PassphraseInputConfiguration {
                return this
            }

            override fun toInvalid(): PassphraseInputConfiguration {
                return Invalid.Focused(input = input, order = order, index = index, imeOptions = imeOptions)
            }

            override fun toValid(): PassphraseInputConfiguration {
                return this
            }
        }

        data class Unfocused(
            override var input: String,
            override val order: Int,
            override val index: Int,
            override val imeOptions: Int
        ) : Valid() {
            override val indexTextColor: Int = R.color.text_gray
            override val underLineColor: Int = R.color.layer_gray
            override val underLineHeight: Int = R.dimen.passphrase_input_bottom_line_unfocused

            override fun toFocused(): PassphraseInputConfiguration {
                return Focused(input = input, order = order, index = index, imeOptions = imeOptions)
            }

            override fun toUnfocused(): PassphraseInputConfiguration {
                return this
            }

            override fun toInvalid(): PassphraseInputConfiguration {
                return Invalid.Unfocused(input = input, order = order, index = index, imeOptions = imeOptions)
            }

            override fun toValid(): PassphraseInputConfiguration {
                return this
            }
        }
    }

    sealed class Invalid : PassphraseInputConfiguration() {
        override val textColor: Int = R.color.negative
        override val underLineColor: Int = R.color.negative
        override val indexTextColor: Int = R.color.negative

        data class Focused(
            override var input: String,
            override val order: Int,
            override val index: Int,
            override val imeOptions: Int
        ) : Invalid() {
            override val underLineHeight: Int = R.dimen.passphrase_input_bottom_line_focused

            override fun toUnfocused(): PassphraseInputConfiguration {
                return Unfocused(input = input, order = order, index = index, imeOptions = imeOptions)
            }

            override fun toFocused(): PassphraseInputConfiguration {
                return this
            }

            override fun toValid(): PassphraseInputConfiguration {
                return Valid.Focused(input = input, order = order, index = index, imeOptions = imeOptions)
            }

            override fun toInvalid(): PassphraseInputConfiguration {
                return this
            }
        }

        data class Unfocused(
            override var input: String,
            override val order: Int,
            override val index: Int,
            override val imeOptions: Int
        ) : Invalid() {
            override val underLineHeight: Int = R.dimen.passphrase_input_bottom_line_unfocused

            override fun toFocused(): PassphraseInputConfiguration {
                return Focused(input = input, order = order, index = index, imeOptions = imeOptions)
            }

            override fun toUnfocused(): PassphraseInputConfiguration {
                return this
            }

            override fun toValid(): PassphraseInputConfiguration {
                return Valid.Unfocused(input = input, order = order, index = index, imeOptions = imeOptions)
            }

            override fun toInvalid(): PassphraseInputConfiguration {
                return this
            }
        }
    }
}
