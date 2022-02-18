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

package com.algorand.android.ui.ledgersearch.instructions

import android.app.Activity
import androidx.activity.result.contract.ActivityResultContracts
import androidx.navigation.NavDirections
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.LayoutLedgerInstructionsBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.extensions.setClickActionAndVisibility
import com.algorand.android.utils.showEnableBluetoothPopup
import com.algorand.android.utils.showSnackbar
import com.algorand.android.utils.viewbinding.viewBinding

abstract class BaseLedgerInstructionFragment : BaseFragment(R.layout.layout_ledger_instructions) {

    private val binding by viewBinding(LayoutLedgerInstructionsBinding::bind)

    abstract val toolbarConfiguration: ToolbarConfiguration

    private val bleRequestLauncher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) {
        if (it.resultCode == Activity.RESULT_OK) {
            showSnackbar(getString(R.string.bluetooth_is_enabled), binding.root)
        } else {
            showGlobalError(getString(R.string.error_bluetooth_message), getString(R.string.error_bluetooth_title))
        }
    }

    protected fun setFirstInstructionClickAction(navDirections: NavDirections) {
        binding.firstInstruction.setClickActionAndVisibility { nav(navDirections) }
    }

    protected fun setSecondInstructionClickAction(navDirections: NavDirections) {
        binding.secondInstruction.setClickActionAndVisibility { nav(navDirections) }
    }

    protected fun setThirdInstructionClickAction(navDirections: NavDirections) {
        binding.thirdInstruction.setClickActionAndVisibility { nav(navDirections) }
    }

    protected fun setFourthInstructionClickAction() {
        binding.fourthInstruction.setClickActionAndVisibility { showEnableBluetoothPopup(bleRequestLauncher) }
    }
}
