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

package com.algorand.android.ui.common.accountselector

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseBottomSheet
import com.algorand.android.databinding.BottomSheetAccountSelectionBinding
import com.algorand.android.models.AccountSelection
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.setNavigationResult
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class AccountSelectionBottomSheet : DaggerBaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_account_selection,
    fullPageNeeded = false,
    firebaseEventScreenId = null
) {
    private val args: AccountSelectionBottomSheetArgs by navArgs()

    private val binding by viewBinding(BottomSheetAccountSelectionBinding::bind)

    private val accountSelectionViewModel: AccountSelectionViewModel by viewModels()

    private var accountsSelectorAdapter: AccountsSelectorAdapter? = null

    // TODO: 1.09.2021 onFailed case did not handle before and loading cases will be updated when shimmer implement
    private val cachedAccountCollector: suspend (value: List<AccountSelection>?) -> Unit = {
        accountsSelectorAdapter?.submitList(it)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        if (args.showBackButton) {
            ToolbarConfiguration(
                startIconResId = R.drawable.ic_left_arrow,
                startIconClick = ::navBack,
                titleResId = args.titleResId
            ).apply { binding.customToolbar.configure(this) }
        } else {
            binding.customToolbar.changeTitle(args.titleResId)
        }
        setupRecyclerView()
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            accountSelectionViewModel.cachedAccountFlow.collectLatest(cachedAccountCollector)
        }
    }

    private fun setupRecyclerView() {
        accountsSelectorAdapter = AccountsSelectorAdapter(
            ::onAccountSelect,
            args.showBalance,
            args.selectedAccountAddress
        )
        binding.accountRecyclerView.adapter = accountsSelectorAdapter
    }

    private fun onAccountSelect(accountSelection: AccountSelection) {
        setNavigationResult(ACCOUNT_SELECTION_KEY, accountSelection)
        navBack()
    }

    companion object {
        const val ACCOUNT_SELECTION_KEY = "account_selection_key"
    }
}
