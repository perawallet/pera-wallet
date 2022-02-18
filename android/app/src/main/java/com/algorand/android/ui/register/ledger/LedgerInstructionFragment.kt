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

package com.algorand.android.ui.register.ledger

import android.os.Bundle
import android.view.View
import com.algorand.android.MainNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentLedgerInstructionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.LEDGER_HELP_WEB_URL
import com.algorand.android.utils.openUrl
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class LedgerInstructionFragment : DaggerBaseFragment(R.layout.fragment_ledger_instruction) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    private val binding by viewBinding(FragmentLedgerInstructionBinding::bind)

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        configureToolbar()
        with(binding) {
            searchButton.setOnClickListener { onPairWithLedgerClick() }
            howItWorkButton.setOnClickListener { onHowDoesItWorkClick() }
        }
    }

    private fun onHowDoesItWorkClick() {
        nav(MainNavigationDirections.actionGlobalHowDoesLedgerWorkFragment())
    }

    private fun onPairWithLedgerClick() {
        nav(LedgerInstructionFragmentDirections.actionLedgerInstructionFragmentToRegisterLedgerSearchFragment())
    }

    private fun configureToolbar() {
        getAppToolbar()?.addButtonToEnd(IconButton(R.drawable.ic_info, onClick = ::onInfoClick))
    }

    private fun onInfoClick() {
        context?.openUrl(LEDGER_HELP_WEB_URL)
    }
}
