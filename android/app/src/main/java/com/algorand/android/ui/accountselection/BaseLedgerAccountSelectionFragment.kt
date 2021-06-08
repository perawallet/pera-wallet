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

package com.algorand.android.ui.accountselection

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import com.algorand.android.MainNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentLedgerAccountSelectionBinding
import com.algorand.android.models.Account
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.Resource
import com.algorand.android.utils.viewbinding.viewBinding

abstract class BaseLedgerAccountSelectionFragment : DaggerBaseFragment(R.layout.fragment_ledger_account_selection) {

    abstract val searchType: SearchType

    abstract fun getLedgerAccountsInformation(): Array<AccountInformation>

    abstract fun onConfirmationClick(selectedAccounts: List<Account>, allAuthAccounts: List<Account>)

    abstract fun getBluetoothAddress(): String

    abstract fun getBluetoothName(): String?

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_back_navigation, startIconClick = ::navBack
    )

    private val binding by viewBinding(FragmentLedgerAccountSelectionBinding::bind)

    private val ledgerAccountSelectionViewModel: LedgerAccountSelectionViewModel by viewModels()

    private val selectionListObserver = Observer<Resource<List<AccountSelectionListItem>>> { resource ->
        resource.use(
            onSuccess = { accountSelectionListItems ->
                ledgerAccountListAdapter?.setItems(if (searchType == SearchType.REGISTER) {
                    accountSelectionListItems
                } else {
                    accountSelectionListItems.filterNot { it.account.type == Account.Type.REKEYED_AUTH }
                })
            },
            onFailed = { error ->
                showGlobalError(error.parse(requireContext()))
            },
            onLoadingFinished = {
                binding.loadingProgressBar.visibility = View.INVISIBLE
            }
        )
    }

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private var ledgerAccountListAdapter: LedgerAccountSelectionAdapter? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        changeToolbarTitle()
        setupConfirmButton()
        setupRecyclerView()
        initObservers()
    }

    private fun setupConfirmButton() {
        binding.confirmationButton.apply {
            setText(
                if (searchType == SearchType.REGISTER) R.string.verify_selected_account else R.string.select_account
            )
            setOnClickListener { onConfirmationButtonClick() }
        }
    }

    private fun setupRecyclerView() {
        if (ledgerAccountListAdapter == null) {
            ledgerAccountListAdapter =
                LedgerAccountSelectionAdapter(searchType, ::accountSelectionChanged, ::onAccountInfoClick)
        }
        binding.ledgersRecyclerView.adapter = ledgerAccountListAdapter?.also {
            if (it.isEmpty) {
                ledgerAccountSelectionViewModel.getAccountSelectionListItems(
                    getLedgerAccountsInformation(),
                    getBluetoothAddress(),
                    getBluetoothName()
                )
            } else {
                accountSelectionChanged(it.selectedCount)
            }
        }
    }

    private fun onAccountInfoClick(accountSelectionListItem: AccountSelectionListItem) {
        nav(
            MainNavigationDirections.actionGlobalLedgerInformationBottomSheet(
                accountSelectionListItem,
                ledgerAccountSelectionViewModel.getAuthAccountOf(accountSelectionListItem),
                ledgerAccountSelectionViewModel.getRekeyedAccountOf(accountSelectionListItem)
            )
        )
    }

    private fun accountSelectionChanged(count: Int) {
        binding.confirmationButton.isEnabled = count != 0
        if (searchType == SearchType.REGISTER) {
            binding.confirmationButton.text = resources.getQuantityString(R.plurals.verify_selected_count, count)
        }
    }

    private fun initObservers() {
        ledgerAccountSelectionViewModel.accountSelectionListLiveData.observe(viewLifecycleOwner, selectionListObserver)
    }

    private fun changeToolbarTitle() {
        getAppToolbar()?.changeTitle(getBluetoothName().orEmpty())
    }

    private fun onConfirmationButtonClick() {
        val selectedAccounts = ledgerAccountListAdapter?.getSelectedAccounts()
        val allAuthAccounts = ledgerAccountListAdapter?.getAllAuthAccounts()
        if (!selectedAccounts.isNullOrEmpty() && !allAuthAccounts.isNullOrEmpty()) {
            onConfirmationClick(selectedAccounts, allAuthAccounts)
        }
    }
}
