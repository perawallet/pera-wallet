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

package com.algorand.android.ui.ledgersearch

import android.os.Bundle
import android.view.View
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetLedgerPairInstructionsBinding
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding

class LedgerPairInstructionsBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_ledger_pair_instructions) {

    private val binding by viewBinding(BottomSheetLedgerPairInstructionsBinding::bind)

    private val args: LedgerPairInstructionsBottomSheetArgs by navArgs()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.confirmationButton.setOnClickListener { onConfirmClick() }
    }

    private fun onConfirmClick() {
        setNavigationResult(BLUETOOTH_DEVICE_KEY, args.bluetoothDevice)
        navBack()
    }

    companion object {
        const val BLUETOOTH_DEVICE_KEY = "bluetooth_device_key"
    }
}
