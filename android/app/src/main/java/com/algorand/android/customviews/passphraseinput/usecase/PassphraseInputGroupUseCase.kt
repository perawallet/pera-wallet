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

package com.algorand.android.customviews.passphraseinput.usecase

import android.view.inputmethod.EditorInfo.IME_ACTION_DONE
import android.view.inputmethod.EditorInfo.IME_ACTION_NEXT
import com.algorand.android.customviews.passphraseinput.mapper.PassphraseInputConfigurationMapper
import com.algorand.android.customviews.passphraseinput.mapper.PassphraseInputGroupConfigurationMapper
import com.algorand.android.customviews.passphraseinput.model.PassphraseInputConfiguration
import com.algorand.android.customviews.passphraseinput.model.PassphraseInputGroupConfiguration
import com.algorand.android.customviews.passphraseinput.util.PassphraseInputConfigurationUtil
import com.algorand.android.utils.PassphraseViewUtils
import com.algorand.android.utils.extensions.isEven
import javax.inject.Inject

class PassphraseInputGroupUseCase @Inject constructor(
    private val passphraseInputConfigurationMapper: PassphraseInputConfigurationMapper,
    private val passphraseInputGroupConfigurationMapper: PassphraseInputGroupConfigurationMapper,
    private val passphraseInputConfigurationUtil: PassphraseInputConfigurationUtil
) {

    fun createPassphraseInputGroupConfiguration(itemCount: Int): PassphraseInputGroupConfiguration {
        var leftOrder = 0
        var rightOrder = PassphraseViewUtils.calculateMiddleIndexOfPassphrases(itemCount)

        val passphraseInputConfigurationList = List<PassphraseInputConfiguration>(itemCount) { index ->
            val currentOrder = if (index.isEven()) leftOrder++ else rightOrder++
            val imeOptions = if (currentOrder != itemCount - 1) IME_ACTION_NEXT else IME_ACTION_DONE

            passphraseInputConfigurationMapper.mapToValidUnfocused(
                input = "",
                index = index,
                imeOptions = imeOptions,
                order = currentOrder
            )
        }

        return passphraseInputGroupConfigurationMapper.mapToPassphraseInputGroupConfiguration(
            passphraseInputConfigurationList = passphraseInputConfigurationList
        )
    }

    fun recoverPassphraseInputGroupConfiguration(
        configuration: PassphraseInputGroupConfiguration,
        itemList: List<String>
    ): PassphraseInputGroupConfiguration {
        val inputConfigurations = configuration.passphraseInputConfigurationList.sortedBy { it.order }.zip(
            other = itemList
        ) { inputConfiguration, passphrase ->
            passphraseInputConfigurationUtil.validatePassphraseInputConfiguration(
                passphraseInputConfiguration = passphraseInputConfigurationMapper.mapToInvalidUnfocused(
                    input = passphrase,
                    index = inputConfiguration.index,
                    imeOptions = inputConfiguration.imeOptions,
                    order = inputConfiguration.order
                )
            )
        }.sortedBy { it.index }
        return configuration.copy(
            passphraseInputConfigurationList = inputConfigurations,
            focusedPassphraseItem = null,
            unfocusedPassphraseItem = null
        )
    }

    fun updatePreviewAfterFocusChanged(
        configuration: PassphraseInputGroupConfiguration?,
        focusedItemOrder: Int
    ): PassphraseInputGroupConfiguration? {
        val newPassphraseInputConfigurationList = passphraseInputConfigurationUtil.updateFocusedItemByOrder(
            focusedItemOrder = focusedItemOrder,
            passphraseInputConfigurationList = configuration?.passphraseInputConfigurationList
        )
        val focusedItem = passphraseInputConfigurationUtil.findFocusedItem(
            passphraseInputConfigurationList = newPassphraseInputConfigurationList
        ) ?: return null
        val safeUnfocusedItem = if (focusedItem.order == configuration?.focusedPassphraseItem?.order) {
            null
        } else {
            configuration?.focusedPassphraseItem
        }
        return configuration?.copy(
            passphraseInputConfigurationList = newPassphraseInputConfigurationList,
            focusedPassphraseItem = focusedItem,
            unfocusedPassphraseItem = safeUnfocusedItem?.toUnfocused()?.run {
                passphraseInputConfigurationUtil.validatePassphraseInputConfiguration(this)
            }
        )
    }

    fun updatePreviewAfterFocusedInputChanged(
        configuration: PassphraseInputGroupConfiguration?,
        word: String
    ): PassphraseInputGroupConfiguration? {
        val focusedItem = passphraseInputConfigurationUtil.findFocusedItem(
            passphraseInputConfigurationList = configuration?.passphraseInputConfigurationList
        )?.apply {
            input = word
        } ?: return null
        val newPassphraseInputConfigurationList = passphraseInputConfigurationUtil.updateFocusedItemByOrder(
            focusedItemOrder = focusedItem.order,
            passphraseInputConfigurationList = configuration?.passphraseInputConfigurationList
        )
        return configuration?.copy(
            passphraseInputConfigurationList = newPassphraseInputConfigurationList,
            focusedPassphraseItem = focusedItem.run {
                passphraseInputConfigurationUtil.validatePassphraseInputConfiguration(this)
            }
        )
    }
}
