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

import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.customviews.PeraChipGroup
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.basepercentageselection.ui.BasePercentageSelectionBottomSheet
import com.algorand.android.modules.basepercentageselection.ui.BasePercentageSelectionViewModel
import com.algorand.android.utils.DecimalDigitsInputFilter
import com.algorand.android.utils.setFragmentNavigationResult
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class SlippageToleranceBottomSheet : BasePercentageSelectionBottomSheet() {

    override val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_close,
        titleResId = R.string.slippage_tolerance
    )

    private val slippageToleranceViewModel by viewModels<SlippageToleranceViewModel>()

    override val basePercentageSelectionViewModel: BasePercentageSelectionViewModel
        get() = slippageToleranceViewModel

    override val inputFieldHintText: Int = R.string.set_custom_slippage

    override fun onChipItemSelected(peraChipItem: PeraChipGroup.PeraChipItem, selectedChipIndex: Int) {
        slippageToleranceViewModel.onChipItemSelected(peraChipItem, selectedChipIndex)
    }

    override fun handleResult(value: Float) {
        super.handleResult(value)
        setFragmentNavigationResult(
            key = CHECKED_SLIPPAGE_TOLERANCE_KEY,
            value = value
        )
        dismissAllowingStateLoss()
    }

    override fun initUi() {
        super.initUi()
        initCustomInputLayout()
        setCustomPercentageChangeListener { slippageToleranceViewModel.onCustomPercentageChange(it) }
    }

    private fun initCustomInputLayout() {
        binding.customPercentageInput.setInputFilter(DecimalDigitsInputFilter(SLIPPAGE_TOLERANCE_DECIMAL_LIMIT))
    }

    companion object {
        const val SLIPPAGE_TOLERANCE_DECIMAL_LIMIT = 2
        const val CHECKED_SLIPPAGE_TOLERANCE_KEY = "checked_slippage_tolerance_key"
    }
}
