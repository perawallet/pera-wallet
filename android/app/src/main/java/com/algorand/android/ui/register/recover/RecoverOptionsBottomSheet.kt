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

package com.algorand.android.ui.register.recover

import android.os.Bundle
import android.view.View
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetRecoverOptionsBinding
import com.algorand.android.utils.openUrl
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding

class RecoverOptionsBottomSheet : DaggerBaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_recover_options,
    fullPageNeeded = false,
    firebaseEventScreenId = null
) {

    private val binding by viewBinding(BottomSheetRecoverOptionsBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.scanQrButton.setOnClickListener { onOptionClick(OptionResult.SCAN_QR) }
        binding.pasteButton.setOnClickListener { onOptionClick(OptionResult.PASTE) }
        binding.cancelButton.setOnClickListener { navBack() }
        binding.learnMoreButton.setOnClickListener { context?.openUrl(RECOVER_INFO_URL) }
    }

    private fun onOptionClick(optionResult: OptionResult) {
        setNavigationResult(RESULT_KEY, optionResult)
        navBack()
    }

    enum class OptionResult {
        SCAN_QR,
        PASTE
    }

    companion object {
        private const val RECOVER_INFO_URL = "https://algorandwallet.com/support/getting-started/recover-an-algorand-account"
        const val RESULT_KEY = "recover_options_result"
    }
}
