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

package com.algorand.android.ui.accounts

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetRenameAccountBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class RenameAccountBottomSheet : DaggerBaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_rename_account,
    fullPageNeeded = false,
    firebaseEventScreenId = null
) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.rename_account,
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    private val renameAccountNameViewModel: RenameAccountNameViewModel by viewModels()

    private val binding by viewBinding(BottomSheetRenameAccountBinding::bind)

    private val args: RenameAccountBottomSheetArgs by navArgs()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        with(binding) {
            toolbar.configure(toolbarConfiguration)
            saveButton.setOnClickListener { onSaveClick() }
            saveButton.isEnabled = false
            accountNameInputLayout.text = args.name
            accountNameInputLayout.setOnTextChangeListener(::onInputTextChanged)
            accountNameInputLayout.requestFocus()
        }
    }

    private fun onInputTextChanged(input: String) {
        binding.saveButton.isEnabled = input.isNotEmpty()
    }

    private fun onSaveClick() {
        val newAccountName = binding.accountNameInputLayout.text
        if (newAccountName.isNotBlank()) {
            renameAccountNameViewModel.changeAccountName(newAccountName)
            setNavigationResult(RENAME_ACCOUNT_RESULT, newAccountName)
            dismissAllowingStateLoss()
        }
    }

    companion object {
        const val RENAME_ACCOUNT_RESULT = "rename_account_result"
    }
}
