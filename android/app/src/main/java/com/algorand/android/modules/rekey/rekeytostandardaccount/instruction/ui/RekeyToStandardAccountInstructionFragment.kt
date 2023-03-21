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

package com.algorand.android.modules.rekey.rekeytostandardaccount.instruction.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentRekeyToStandardAccountInstructionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.rekey.rekeytostandardaccount.instruction.ui.model.RekeyToStandardAccountInstructionPreview
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class RekeyToStandardAccountInstructionFragment : BaseFragment(
    R.layout.fragment_rekey_to_standard_account_instruction
) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val rekeyToStandardAccountInstructionViewModel by viewModels<RekeyToStandardAccountInstructionViewModel>()

    private val binding by viewBinding(FragmentRekeyToStandardAccountInstructionBinding::bind)

    private val rekeyToStandardAccountInstructionPreviewCollector: suspend (
        RekeyToStandardAccountInstructionPreview
    ) -> Unit = { preview ->
        updatePreview(preview)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
        initUi()
    }

    private fun initUi() {
        binding.processButton.setOnClickListener { onStartProcessClick() }
    }

    private fun initObservers() {
        with(rekeyToStandardAccountInstructionViewModel) {
            collectLatestOnLifecycle(
                flow = rekeyToStandardAccountInstructionPreviewFlow,
                collection = rekeyToStandardAccountInstructionPreviewCollector
            )
        }
    }

    private fun updatePreview(rekeyToStandardAccountInstructionPreview: RekeyToStandardAccountInstructionPreview) {
        with(rekeyToStandardAccountInstructionPreview) {
            with(binding) {
                titleTextView.setText(titleTextResId)
                descriptionTextView.setText(descriptionTextResId)
                firstExpectationTextView.setText(firstDescriptionTextResId)
                secondExpectationTextView.setText(secondDescriptionTextRestId)
                thirdExpectationTextView.setText(thirdDescriptionTextResId)
                processButton.setText(actionButtonTextResId)
            }
        }
    }

    private fun onStartProcessClick() {
        val accountAddress = rekeyToStandardAccountInstructionViewModel.accountAddress
        nav(
            RekeyToStandardAccountInstructionFragmentDirections
                .actionRekeyToStandardAccountInstructionFragmentToRekeyToStandardAccountSelectionFragment(
                    accountAddress = accountAddress
                )
        )
    }
}
