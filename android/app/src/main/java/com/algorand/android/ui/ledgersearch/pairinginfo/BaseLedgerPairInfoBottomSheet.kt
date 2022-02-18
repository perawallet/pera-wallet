/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.ledgersearch.pairinginfo

import android.os.Bundle
import android.view.View
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetLedgerPairInfoBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.ledgersearch.instructions.LedgerInstructionStepsAdapter
import com.algorand.android.utils.viewbinding.viewBinding

abstract class BaseLedgerPairInfoBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_ledger_pair_info) {

    private val ledgerInstructionStepsAdapter = LedgerInstructionStepsAdapter()

    abstract val toolbarConfiguration: ToolbarConfiguration

    private val binding by viewBinding(BottomSheetLedgerPairInfoBinding::bind)

    protected abstract val instructions: List<Int>

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        with(binding) {
            binding.toolbar.configure(toolbarConfiguration)
            instructionList.adapter = ledgerInstructionStepsAdapter
            ledgerInstructionStepsAdapter.setItems(instructions)
        }
    }
}
