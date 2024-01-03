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

package com.algorand.android.modules.onboarding.pairledger.accountselection.ui

import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.navigation.navGraphViewModels
import com.algorand.android.MainNavigationDirections
import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.modules.baseledgeraccountselection.accountselection.ui.BaseLedgerAccountSelectionFragment
import com.algorand.android.modules.baseledgeraccountselection.accountselection.ui.BaseLedgerAccountSelectionViewModel
import com.algorand.android.modules.baseledgeraccountselection.accountselection.ui.adapter.LedgerAccountSelectionAdapter
import com.algorand.android.modules.onboarding.pairledger.PairLedgerNavigationViewModel
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class RegisterLedgerAccountSelectionFragment : BaseLedgerAccountSelectionFragment() {

    private val pairLedgerNavigationViewModel: PairLedgerNavigationViewModel by navGraphViewModels(
        R.id.pairLedgerNavigation
    ) {
        defaultViewModelProviderFactory
    }

    override val ledgerAccountListAdapter = LedgerAccountSelectionAdapter(ledgerAccountListAdapterListener)

    override val baseLedgerAccountSelectionViewModel: BaseLedgerAccountSelectionViewModel
        get() = registerLedgerAccountSelectionViewModel

    private val registerLedgerAccountSelectionViewModel by viewModels<RegisterBaseLedgerAccountSelectionViewModel>()

    private val accountsIsLoadingCollector: suspend (Boolean?) -> Unit = {
        binding.loadingProgressBar.isVisible = it == true
    }

    private val accountListItemCollector: suspend (List<AccountSelectionListItem>?) -> Unit = {
        ledgerAccountListAdapter.submitList(it)
    }

    private val actionButtonStateCollector: suspend (Boolean?) -> Unit = {
        binding.confirmationButton.isEnabled = it == true
    }

    override fun initObservers() {
        with(registerLedgerAccountSelectionViewModel.registerLedgerAccountSelectionPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it?.isLoading },
                collection = accountsIsLoadingCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.accountSelectionListItems },
                collection = accountListItemCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.isActionButtonEnabled },
                collection = actionButtonStateCollector
            )
        }
    }

    override fun onTroubleshootClick() {
        nav(MainNavigationDirections.actionGlobalLedgerTroubleshootFragment())
    }

    override fun onConfirmationClick(selectedAccounts: List<Account>, allAuthAccounts: List<Account>) {
        with(pairLedgerNavigationViewModel) {
            this.selectedAccounts = selectedAccounts
            this.allAuthAccounts = allAuthAccounts
        }
        nav(
            RegisterLedgerAccountSelectionFragmentDirections
                .actionRegisterLedgerAccountSelectionFragmentToVerifyLedgerAddressFragment()
        )
    }

    override fun changeToolbarTitle() {
        getAppToolbar()?.changeTitle(registerLedgerAccountSelectionViewModel.ledgerBluetoothName.orEmpty())
    }

    override fun setupConfirmButton(confirmationButton: MaterialButton) {
        super.setupConfirmButton(confirmationButton)
        confirmationButton.setText(R.string.verify_selected_account)
    }
}
