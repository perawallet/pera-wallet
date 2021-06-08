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

package com.algorand.android.ui.ledgersearch

import android.os.Bundle
import android.view.View
import androidx.annotation.StringRes
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetLedgerPairInfoBinding
import com.algorand.android.ui.register.ledger.LedgerInstructionStepsAdapter
import com.algorand.android.utils.viewbinding.viewBinding

class LedgerPairInfoBottomSheet : BaseBottomSheet(R.layout.bottom_sheet_ledger_pair_info) {

    private val ledgerInstructionStepsAdapter = LedgerInstructionStepsAdapter()

    private val binding by viewBinding(BottomSheetLedgerPairInfoBinding::bind)

    private val args: LedgerPairInfoBottomSheetArgs by navArgs()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.instructionList.adapter = ledgerInstructionStepsAdapter
        ledgerInstructionStepsAdapter.setItems(args.infoType.stepResIdList)
        binding.titleTextView.text = getString(R.string.step_number, args.infoType.ordinal + 1)
        binding.cancelButton.setOnClickListener { dismissAllowingStateLoss() }
    }

    enum class InfoType(@StringRes val stepResIdList: List<Int>) {
        FIRST(
            stepResIdList = listOf(
                R.string.ledger_info_power_first_paragraph,
                R.string.ledger_info_power_second_paragraph
            )
        ),
        SECOND(
            stepResIdList = listOf(
                R.string.ledger_info_ledger_first_paragraph,
                R.string.ledger_info_ledger_second_paragraph
            )
        ),
        THIRD(
            stepResIdList = listOf(
                R.string.ledger_info_algorand_first_paragraph,
                R.string.ledger_info_algorand_second_paragraph
            )
        )
    }
}
