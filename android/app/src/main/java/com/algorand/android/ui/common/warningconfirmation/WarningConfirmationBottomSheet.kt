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
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.AccountManager
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetWarningConfirmationBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding
import javax.inject.Inject

class WarningConfirmationBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_warning_confirmation) {

    @Inject
    lateinit var accountManager: AccountManager

    @Inject
    lateinit var accountCacheManager: AccountCacheManager

    private val args: WarningConfirmationBottomSheetArgs by navArgs()

    private val binding by viewBinding(BottomSheetWarningConfirmationBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.descriptionTextView.setText(args.descriptionTextResId)
        val toolbarConfiguration = ToolbarConfiguration(titleResId = args.titleTextResId)
        binding.toolbar.configure(toolbarConfiguration)
        binding.positiveButton.setText(args.positiveButtonTextResId)
        binding.negativeButton.setText(args.negativeButtonTextResId)
        binding.logoImageView.setImageResource(args.drawableResId)
        binding.negativeButton.setOnClickListener { navBack() }
        binding.positiveButton.setOnClickListener {
            setNavigationResult(WARNING_CONFIRMATION_KEY, true)
            navBack()
        }
    }

    companion object {
        const val WARNING_CONFIRMATION_KEY = "delete_confirmation_key"
    }
}
