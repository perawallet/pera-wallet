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

package com.algorand.android.modules.basepercentageselection.ui

import android.content.res.Resources
import com.algorand.android.core.BaseViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

abstract class BasePercentageSelectionViewModel : BaseViewModel() {

    private val _basePercentageSelectionPreviewFlow = MutableStateFlow<BasePercentageSelectionPreview?>(null)
    val basePercentageSelectionPreviewFlow: StateFlow<BasePercentageSelectionPreview?>
        get() = _basePercentageSelectionPreviewFlow

    abstract fun getInitialPreview(resources: Resources): BasePercentageSelectionPreview
    abstract fun onInputUpdated(resources: Resources, inputValue: String)
    abstract fun getCustomInputResultUpdatedPreview(
        inputValue: String
    ): BasePercentageSelectionPreview?

    fun initPreview(resources: Resources) {
        _basePercentageSelectionPreviewFlow.value = getInitialPreview(resources)
    }

    fun onDoneClick(inputValue: String) {
        _basePercentageSelectionPreviewFlow.value = getCustomInputResultUpdatedPreview(inputValue)
    }

    protected fun updatePreviewFlow(newState: BasePercentageSelectionPreview) {
        _basePercentageSelectionPreviewFlow.value = newState
    }

    protected fun getCurrentState() = _basePercentageSelectionPreviewFlow.value
}
