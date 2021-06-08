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

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import com.algorand.android.MainNavigationDirections.Companion.actionGlobalLedgerPairInfoBottomSheet
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.LayoutLedgerTroubleshootInstructionsBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.BLE_OPEN_REQUEST_CODE
import com.algorand.android.utils.showEnableBluetoothPopup
import com.algorand.android.utils.showSnackbar
import com.algorand.android.utils.viewbinding.viewBinding

class LedgerTroubleshootingFragment : BaseFragment(R.layout.layout_ledger_troubleshoot_instructions) {

    private val binding by viewBinding(LayoutLedgerTroubleshootInstructionsBinding::bind)

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.advanced_troubleshooting,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.firstStepLayout.setOnClickListener {
            navToInfoBottomSheet(LedgerPairInfoBottomSheet.InfoType.FIRST)
        }
        binding.secondStepLayout.setOnClickListener {
            navToInfoBottomSheet(LedgerPairInfoBottomSheet.InfoType.SECOND)
        }
        binding.thirdStepLayout.setOnClickListener {
            navToInfoBottomSheet(LedgerPairInfoBottomSheet.InfoType.THIRD)
        }
        binding.fourthStepLayout.setOnClickListener { showEnableBluetoothPopup() }
    }

    private fun navToInfoBottomSheet(infoType: LedgerPairInfoBottomSheet.InfoType) {
        nav(actionGlobalLedgerPairInfoBottomSheet(infoType))
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == BLE_OPEN_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                showSnackbar(getString(R.string.bluetooth_is_enabled), binding.root)
            } else {
                showGlobalError(getString(R.string.error_bluetooth_message), getString(R.string.error_bluetooth_title))
            }
        }
    }
}
