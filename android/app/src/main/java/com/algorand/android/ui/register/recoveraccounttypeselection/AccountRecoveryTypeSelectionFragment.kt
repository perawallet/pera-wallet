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
 */

package com.algorand.android.ui.register.recoveraccounttypeselection

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.LoginNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAccountRecoveryTypeSelectionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class AccountRecoveryTypeSelectionFragment : BaseFragment(R.layout.fragment_account_recovery_type_selection) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack,
        backgroundColor = R.color.primaryBackground
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val accountRecoveryTypeSelectionViewModel: AccountRecoveryTypeSelectionViewModel by viewModels()

    private val binding by viewBinding(FragmentAccountRecoveryTypeSelectionBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
    }

    private fun initUi() {
        setupToolbar()
        with(binding) {
            recoverAnAccountSelectionItem.setOnClickListener { navToRecoverAccountInfoFragment() }
            pairLedgerSelectionItem.setOnClickListener { navToPairLedgerNavigation() }
        }
    }

    private fun navToRecoverAccountInfoFragment() {
        nav(
            AccountRecoveryTypeSelectionFragmentDirections
                .actionAccountRecoveryTypeSelectionFragmentToRecoverAccountInfoFragment()
        )
    }

    private fun navToPairLedgerNavigation() {
        nav(
            AccountRecoveryTypeSelectionFragmentDirections
                .actionAccountRecoveryTypeSelectionFragmentToPairLedgerNavigation()
        )
    }

    private fun setupToolbar() {
        if (accountRecoveryTypeSelectionViewModel.hasAccount().not()) {
            getAppToolbar()?.addButtonToEnd(TextButton(R.string.skip, onClick = ::onSkipClick))
        }
    }

    private fun onSkipClick() {
        accountRecoveryTypeSelectionViewModel.setRegisterSkip()
        nav(LoginNavigationDirections.actionGlobalToHomeNavigation())
    }
}
