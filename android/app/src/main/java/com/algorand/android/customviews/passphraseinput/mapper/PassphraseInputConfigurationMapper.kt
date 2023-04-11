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

package com.algorand.android.customviews.passphraseinput.mapper

import com.algorand.android.customviews.passphraseinput.model.PassphraseInputConfiguration
import javax.inject.Inject

class PassphraseInputConfigurationMapper @Inject constructor() {

    fun mapToValidFocused(
        input: String,
        order: Int,
        index: Int,
        imeOptions: Int
    ): PassphraseInputConfiguration.Valid.Focused {
        return PassphraseInputConfiguration.Valid.Focused(
            input = input,
            order = order,
            index = index,
            imeOptions = imeOptions
        )
    }

    fun mapToValidUnfocused(
        input: String,
        order: Int,
        index: Int,
        imeOptions: Int
    ): PassphraseInputConfiguration.Valid.Unfocused {
        return PassphraseInputConfiguration.Valid.Unfocused(
            input = input,
            order = order,
            index = index,
            imeOptions = imeOptions
        )
    }

    fun mapToInvalidFocused(
        input: String,
        order: Int,
        index: Int,
        imeOptions: Int
    ): PassphraseInputConfiguration.Invalid.Focused {
        return PassphraseInputConfiguration.Invalid.Focused(
            input = input,
            order = order,
            index = index,
            imeOptions = imeOptions
        )
    }

    fun mapToInvalidUnfocused(
        input: String,
        order: Int,
        index: Int,
        imeOptions: Int
    ): PassphraseInputConfiguration.Invalid.Unfocused {
        return PassphraseInputConfiguration.Invalid.Unfocused(
            input = input,
            order = order,
            index = index,
            imeOptions = imeOptions
        )
    }
}
