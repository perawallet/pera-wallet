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

import android.os.Bundle
import android.view.View
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.customviews.PeraChipGroup
import com.algorand.android.customviews.PeraChipGroup.PeraChipItem
import com.algorand.android.databinding.BottomSheetPercentageSelectionBinding
import com.algorand.android.customviews.toolbar.buttoncontainer.model.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.hideKeyboard
import com.algorand.android.utils.viewbinding.viewBinding

abstract class BasePercentageSelectionBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_percentage_selection) {

    abstract val toolbarConfiguration: ToolbarConfiguration

    abstract val inputFieldHintText: Int

    abstract fun onChipItemSelected(peraChipItem: PeraChipItem, selectedChipIndex: Int)

    protected val binding by viewBinding(BottomSheetPercentageSelectionBinding::bind)

    abstract val basePercentageSelectionViewModel: BasePercentageSelectionViewModel

    private val peraCheckGroupListener = object : PeraChipGroup.PeraChipGroupListener {
        override fun onCheckChange(peraChipItem: PeraChipItem, selectedChipIndex: Int) {
            onChipItemSelected(peraChipItem, selectedChipIndex)
        }
    }

    private val basePercentageSelectionPreviewCollector: suspend (BasePercentageSelectionPreview?) -> Unit = {
        it?.run {
            binding.predefinedPercentageChipGroup.initPeraChipGroup(chipOptionList, checkedOption)
            returnResultEvent?.consume()?.run { handleResult(this) }
            binding.customPercentageInput.error = errorString
            requestFocusToInputEvent?.consume()?.run { focusOnInputEditText() }
            prefilledAmountInputValue?.consume()?.run { updateCustomInputEditText(this) }
        }
    }

    private fun updateCustomInputEditText(inputValue: String) {
        binding.customPercentageInput.text = inputValue
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
        basePercentageSelectionViewModel.initPreview(resources)
    }

    protected open fun handleResult(value: Float) {
        binding.root.hideKeyboard()
    }

    private fun focusOnInputEditText() {
        binding.customPercentageInput.requestFocusAndShowKeyboard()
    }

    protected open fun initUi() {
        with(binding) {
            toolbar.apply {
                configure(toolbarConfiguration)
                setEndButton(TextButton(R.string.done, R.color.link_primary, ::onDoneClick))
            }
            customPercentageInput.apply {
                hint = getString(inputFieldHintText)
                setOnEditorEnterClickListener { onDoneClick() }
                setImeOptionsDone { onDoneClick() }
                setOnTextChangeListener { basePercentageSelectionViewModel.onInputUpdated(resources, it) }
            }
            predefinedPercentageChipGroup.setListener(peraCheckGroupListener)
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            basePercentageSelectionViewModel.basePercentageSelectionPreviewFlow,
            basePercentageSelectionPreviewCollector
        )
    }

    private fun onDoneClick() {
        val percentageInput = binding.customPercentageInput.text
        basePercentageSelectionViewModel.onDoneClick(percentageInput)
    }
}
