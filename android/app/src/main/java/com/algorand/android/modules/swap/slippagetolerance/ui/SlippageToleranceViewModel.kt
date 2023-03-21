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

package com.algorand.android.modules.swap.slippagetolerance.ui

import android.content.res.Resources
import androidx.lifecycle.SavedStateHandle
import com.algorand.android.customviews.PeraChipGroup
import com.algorand.android.modules.basepercentageselection.ui.BasePercentageSelectionPreview
import com.algorand.android.modules.basepercentageselection.ui.BasePercentageSelectionViewModel
import com.algorand.android.modules.swap.slippagetolerance.ui.model.SlippageTolerancePreview
import com.algorand.android.modules.swap.slippagetolerance.ui.usecase.SlippageTolerancePreviewUseCase
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class SlippageToleranceViewModel @Inject constructor(
    private val slippageTolerancePreviewUseCase: SlippageTolerancePreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BasePercentageSelectionViewModel() {

    private val previousSelectedTolerance: Float = savedStateHandle.getOrThrow(SLIPPAGE_TOLERANCE_PARAM_KEY)

    override fun getInitialPreview(resources: Resources): BasePercentageSelectionPreview {
        return slippageTolerancePreviewUseCase.getSlippageTolerancePreview(resources, previousSelectedTolerance)
    }

    override fun onInputUpdated(resources: Resources, inputValue: String) {
        (getCurrentState() as? SlippageTolerancePreview)?.run {
            val newState = slippageTolerancePreviewUseCase.getCustomItemUpdatedPreview(resources, inputValue, this)
            updatePreviewFlow(newState)
        }
    }

    override fun getCustomInputResultUpdatedPreview(inputValue: String): BasePercentageSelectionPreview? {
        return (getCurrentState() as? SlippageTolerancePreview)?.run {
            slippageTolerancePreviewUseCase.getDoneClickUpdatedPreview(inputValue, this)
        } ?: getCurrentState()
    }

    fun onChipItemSelected(peraChipItem: PeraChipGroup.PeraChipItem, selectedChipIndex: Int) {
        (getCurrentState() as? SlippageTolerancePreview)?.run {
            val newState = slippageTolerancePreviewUseCase
                .getChipItemSelectedUpdatedPreview(selectedChipIndex, peraChipItem, this)
            updatePreviewFlow(newState)
        }
    }

    companion object {
        private const val SLIPPAGE_TOLERANCE_PARAM_KEY = "slippageTolerance"
    }
}
