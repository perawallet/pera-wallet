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

package com.algorand.android.modules.swap.balancepercentage.ui.usecase

import android.content.res.Resources
import com.algorand.android.R
import com.algorand.android.mapper.PeraChipItemMapper
import com.algorand.android.models.PeraFloatChipItem
import com.algorand.android.modules.swap.balancepercentage.ui.mapper.BalancePercentagePreviewMapper
import com.algorand.android.modules.swap.balancepercentage.ui.model.BalancePercentagePreview
import com.algorand.android.utils.Event
import com.algorand.android.utils.toFloatOrDefault
import javax.inject.Inject

class BalancePercentagePreviewUseCase @Inject constructor(
    private val balancePercentagePreviewMapper: BalancePercentagePreviewMapper,
    private val peraChipItemMapper: PeraChipItemMapper
) {

    fun getBalancePercentagePreview(resources: Resources): BalancePercentagePreview {
        return balancePercentagePreviewMapper.mapToBalancePercentagePreview(
            chipOptionList = getBalancePercentageOptionList(resources),
            returnResultEvent = null,
            errorString = null
        )
    }

    fun getPercentageUpdatedPreview(
        resources: Resources,
        inputValue: String,
        previousPreview: BalancePercentagePreview
    ): BalancePercentagePreview {
        if (inputValue.isBlank()) return previousPreview.copy(errorString = null)
        val inputAsFloat = inputValue.toFloatOrNull() ?: return previousPreview
        val errorString = if (!isInputValid(inputAsFloat)) {
            resources.getString(
                R.string.balance_percentage_must_be_between,
                MINIMUM_BALANCE_PERCENTAGE.toInt(),
                MAXIMUM_BALANCE_PERCENTAGE.toInt()
            )
        } else {
            null
        }
        return previousPreview.copy(errorString = errorString)
    }

    fun getDoneClickUpdatedPreview(
        inputValue: String,
        previousState: BalancePercentagePreview
    ): BalancePercentagePreview {
        if (inputValue.isBlank()) return previousState
        val inputAsFloat = inputValue.toFloatOrDefault()
        return if (!isInputValid(inputAsFloat)) {
            previousState
        } else {
            previousState.copy(returnResultEvent = Event(inputAsFloat))
        }
    }

    private fun getBalancePercentageOptionList(resources: Resources): MutableList<PeraFloatChipItem> {
        return mutableListOf<PeraFloatChipItem>().apply {
            add(
                peraChipItemMapper.mapToPeraChipItem(
                    labelText = resources.getString(R.string.twenty_five_percent),
                    value = TWENTY_FIVE
                )
            )
            add(
                peraChipItemMapper.mapToPeraChipItem(
                    labelText = resources.getString(R.string.fifty_percent),
                    value = FIFTY
                )
            )
            add(
                peraChipItemMapper.mapToPeraChipItem(
                    labelText = resources.getString(R.string.seventy_five_percent),
                    value = SEVENTY_FIVE
                )
            )
            add(
                peraChipItemMapper.mapToPeraChipItem(
                    labelText = resources.getString(R.string.max_all_caps),
                    value = MAX_PERCENTAGE
                )
            )
        }
    }

    private fun isInputValid(value: Float): Boolean {
        return value in MINIMUM_BALANCE_PERCENTAGE..MAXIMUM_BALANCE_PERCENTAGE
    }

    companion object {
        private const val TWENTY_FIVE: Float = 25f
        private const val FIFTY: Float = 50f
        private const val SEVENTY_FIVE: Float = 75f
        private const val MAX_PERCENTAGE: Float = 100f
        private const val MAXIMUM_BALANCE_PERCENTAGE: Float = 100.0f
        private const val MINIMUM_BALANCE_PERCENTAGE: Float = 1.0f
    }
}
