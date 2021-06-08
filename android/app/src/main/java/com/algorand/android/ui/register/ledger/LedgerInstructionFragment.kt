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

package com.algorand.android.ui.register.ledger

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageButton
import androidx.navigation.navGraphViewModels
import com.algorand.android.MainNavigationDirections.Companion.actionGlobalLedgerPairInfoBottomSheet
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentLedgerInstructionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.ledgersearch.LedgerPairInfoBottomSheet
import com.algorand.android.ui.register.LoginNavigationViewModel
import com.algorand.android.utils.BLE_OPEN_REQUEST_CODE
import com.algorand.android.utils.openUrl
import com.algorand.android.utils.showEnableBluetoothPopup
import com.algorand.android.utils.showSnackbar
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class LedgerInstructionFragment : DaggerBaseFragment(R.layout.fragment_ledger_instruction) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::navBack,
        backgroundColor = R.color.secondaryBackground
    )

    private val binding by viewBinding(FragmentLedgerInstructionBinding::bind)

    private val loginNavigationViewModel: LoginNavigationViewModel by navGraphViewModels(R.id.loginNavigation) {
        defaultViewModelProviderFactory
    }

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        loginNavigationViewModel.clearTempAccount()
        configureToolbar()
        binding.searchButton.setOnClickListener {
            nav(LedgerInstructionFragmentDirections.actionLedgerInstructionFragmentToRegisterLedgerSearchFragment())
        }
        binding.instructionsLayout.firstStepLayout.setOnClickListener {
            navToInfoBottomSheet(LedgerPairInfoBottomSheet.InfoType.FIRST)
        }
        binding.instructionsLayout.secondStepLayout.setOnClickListener {
            navToInfoBottomSheet(LedgerPairInfoBottomSheet.InfoType.SECOND)
        }
        binding.instructionsLayout.thirdStepLayout.setOnClickListener {
            navToInfoBottomSheet(LedgerPairInfoBottomSheet.InfoType.THIRD)
        }
        binding.instructionsLayout.fourthStepLayout.setOnClickListener { showEnableBluetoothPopup() }
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

    private fun configureToolbar() {
        getAppToolbar()?.apply {
            val infoButton = LayoutInflater
                .from(context)
                .inflate(R.layout.custom_icon_tab_button, this, false) as ImageButton

            infoButton.apply {
                setImageResource(R.drawable.ic_info)
                setOnClickListener { onInfoClick() }
                addViewToEndSide(this)
            }
        }
    }

    private fun navToInfoBottomSheet(infoType: LedgerPairInfoBottomSheet.InfoType) {
        nav(actionGlobalLedgerPairInfoBottomSheet(infoType))
    }

    private fun onInfoClick() {
        context?.openUrl(LEDGER_HELP_WEB_URL)
    }

    companion object {
        private const val LEDGER_HELP_WEB_URL = "https://algorandwallet.com/support/security/pairing-your-ledger-nano-x"
    }
}
