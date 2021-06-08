/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License
 */

package com.algorand.android.ui.common.warningconfirmation

import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetMaximumBalanceWarningBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding

abstract class BaseMaximumBalanceWarningBottomSheet : DaggerBaseBottomSheet(
    R.layout.bottom_sheet_maximum_balance_warning,
    fullPageNeeded = false,
    firebaseEventScreenId = null
) {

    abstract fun setDescriptionText(descriptionTextView: TextView)

    protected val maximumBalanceWarningViewModel: MaximumBalanceWarningViewModel by viewModels()

    private val binding by viewBinding(BottomSheetMaximumBalanceWarningBinding::bind)

    private val toolbarConfiguration = ToolbarConfiguration(R.string.minimum_balance_required)

    override fun onPause() {
        super.onPause()
        dismissAllowingStateLoss()
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupToolbar()
        setDescriptionText(binding.descriptionTextView)
        binding.cancelButton.setOnClickListener { navBack() }
        binding.continueButton.setOnClickListener { onContinueClick() }
    }

    private fun setupToolbar() {
        binding.toolbar.configure(toolbarConfiguration)
    }

    private fun onContinueClick() {
        processConfirmation()
    }

    private fun processConfirmation() {
        setNavigationResult(MAX_BALANCE_WARNING_RESULT, true)
        navBack()
    }

    companion object {
        const val MAX_BALANCE_WARNING_RESULT = "max_balance_warning_result"
    }
}
