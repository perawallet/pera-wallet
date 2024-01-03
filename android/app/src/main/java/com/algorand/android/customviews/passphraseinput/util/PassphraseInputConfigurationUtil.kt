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

package com.algorand.android.customviews.passphraseinput.util

import com.algorand.android.customviews.passphraseinput.model.PassphraseInputConfiguration
import com.algorand.android.customviews.passphraseinput.model.PassphraseInputGroupConfiguration
import com.algorand.android.utils.PassphraseKeywordUtils
import javax.inject.Inject

class PassphraseInputConfigurationUtil @Inject constructor() {

    fun validatePassphraseInputConfiguration(
        passphraseInputConfiguration: PassphraseInputConfiguration
    ): PassphraseInputConfiguration {
        val isValid = with(passphraseInputConfiguration) {
            PassphraseKeywordUtils.isWordInKeywords(input) || input.isBlank()
        }
        return if (isValid) {
            passphraseInputConfiguration.toValid()
        } else {
            passphraseInputConfiguration.toInvalid()
        }
    }

    fun updateFocusedItemByOrder(
        focusedItemOrder: Int?,
        passphraseInputConfigurationList: List<PassphraseInputConfiguration>?
    ): List<PassphraseInputConfiguration> {
        return passphraseInputConfigurationList?.map {
            if (it.order == focusedItemOrder) {
                validatePassphraseInputConfiguration(it.toFocused())
            } else {
                it.toUnfocused()
            }
        }.orEmpty()
    }

    fun findFocusedItem(
        passphraseInputConfigurationList: List<PassphraseInputConfiguration>?
    ): PassphraseInputConfiguration? {
        return passphraseInputConfigurationList?.firstOrNull { passphraseInputConfiguration ->
            passphraseInputConfiguration is PassphraseInputConfiguration.Valid.Focused ||
                passphraseInputConfiguration is PassphraseInputConfiguration.Invalid.Focused
        }
    }

    fun areAllFieldsValid(passphrasesMap: List<PassphraseInputConfiguration>): Boolean {
        return passphrasesMap.all {
            it is PassphraseInputConfiguration.Valid && it.input.isNotBlank()
        }
    }

    fun getOrderedInput(configuration: PassphraseInputGroupConfiguration): String {
        return configuration.passphraseInputConfigurationList
            .sortedBy { it.order }
            .joinToString(separator = " ", transform = { it.input })
    }
}
