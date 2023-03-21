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

package com.algorand.android.modules.swap.balancepercentage.ui

import android.content.res.Resources
import com.algorand.android.modules.basepercentageselection.ui.BasePercentageSelectionPreview
import com.algorand.android.modules.basepercentageselection.ui.BasePercentageSelectionViewModel
import com.algorand.android.modules.swap.balancepercentage.ui.model.BalancePercentagePreview
import com.algorand.android.modules.swap.balancepercentage.ui.usecase.BalancePercentagePreviewUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject

@HiltViewModel
class BalancePercentageViewModel @Inject constructor(
    private val balancePercentagePreviewUseCase: BalancePercentagePreviewUseCase
) : BasePercentageSelectionViewModel() {

    override fun getInitialPreview(resources: Resources): BasePercentageSelectionPreview {
        return balancePercentagePreviewUseCase.getBalancePercentagePreview(resources)
    }

    override fun onInputUpdated(resources: Resources, inputValue: String) {
        (getCurrentState() as? BalancePercentagePreview)?.run {
            val newState = balancePercentagePreviewUseCase.getPercentageUpdatedPreview(resources, inputValue, this)
            updatePreviewFlow(newState)
        }
    }

    override fun getCustomInputResultUpdatedPreview(inputValue: String): BasePercentageSelectionPreview? {
        return (getCurrentState() as? BalancePercentagePreview)?.run {
            balancePercentagePreviewUseCase.getDoneClickUpdatedPreview(inputValue, this)
        }
    }
}
