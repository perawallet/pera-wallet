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

package com.algorand.android.ui.ledgeraccountselection

import android.os.Bundle
import android.view.View
import com.algorand.android.MainNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentLedgerAccountSelectionBinding
import com.algorand.android.models.Account
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.button.MaterialButton

abstract class BaseLedgerAccountSelectionFragment : DaggerBaseFragment(R.layout.fragment_ledger_account_selection) {

    abstract val ledgerAccountSelectionViewModel: LedgerAccountSelectionViewModel

    abstract val ledgerAccountListAdapter: LedgerAccountSelectionAdapter

    abstract fun onConfirmationClick(selectedAccounts: List<Account>, allAuthAccounts: List<Account>)

    abstract fun changeToolbarTitle()

    abstract fun initObservers()

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    protected val binding by viewBinding(FragmentLedgerAccountSelectionBinding::bind)

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    protected val ledgerAccountListAdapterListener = object : LedgerAccountSelectionAdapter.Listener {
        override fun onAccountClick(accountItem: AccountSelectionListItem.AccountItem) {
            ledgerAccountSelectionViewModel.onNewAccountSelected(accountItem)
        }

        override fun onAccountInfoClick(accountItem: AccountSelectionListItem.AccountItem) {
            nav(
                MainNavigationDirections.actionGlobalLedgerInformationBottomSheet(
                    accountItem,
                    ledgerAccountSelectionViewModel.getAuthAccountOf(accountItem),
                    ledgerAccountSelectionViewModel.getRekeyedAccountOf(accountItem)
                )
            )
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        changeToolbarTitle()
        setupConfirmButton(binding.confirmationButton)
        setupRecyclerView()
        initObservers()
    }

    open fun setupConfirmButton(confirmationButton: MaterialButton) {
        confirmationButton.setOnClickListener { onConfirmationButtonClick() }
    }

    private fun setupRecyclerView() {
        binding.ledgersRecyclerView.adapter = ledgerAccountListAdapter
    }

    private fun onConfirmationButtonClick() {
        val selectedAccounts = ledgerAccountSelectionViewModel.selectedAccounts
        val allAuthAccounts = ledgerAccountSelectionViewModel.allAuthAccounts
        if (selectedAccounts.isNotEmpty() && allAuthAccounts.isNotEmpty()) {
            onConfirmationClick(selectedAccounts, allAuthAccounts)
        }
    }
}
