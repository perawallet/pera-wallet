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

import android.os.Bundle
import android.view.View
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration

class LedgerTroubleshootFragment : BaseLedgerInstructionFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.advanced_troubleshooting,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        with(LedgerTroubleshootFragmentDirections) {
            setFirstInstructionClickAction(actionLedgerTroubleshootFragmentToEnableLedgerBluetoothBottomSheet())
            setSecondInstructionClickAction(actionLedgerTroubleshootFragmentToInstallAlgorandOntoLedgerBottomSheet())
            setThirdInstructionClickAction(actionLedgerTroubleshootFragmentToOpenAppOnLedgerBottomSheet())
            setFourthInstructionClickAction()
        }
    }
}
