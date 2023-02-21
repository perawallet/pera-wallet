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

package com.algorand.android.ui.rekey

import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.ui.ledgeraccountselection.BaseLedgerAccountSelectionFragment
import com.algorand.android.ui.ledgeraccountselection.LedgerAccountSelectionAdapter
import com.algorand.android.ui.ledgeraccountselection.LedgerAccountSelectionViewModel
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.google.android.material.button.MaterialButton
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class RekeyLedgerAccountSelectionFragment : BaseLedgerAccountSelectionFragment() {

    override val ledgerAccountListAdapter = LedgerAccountSelectionAdapter(ledgerAccountListAdapterListener)

    override val ledgerAccountSelectionViewModel: LedgerAccountSelectionViewModel
        get() = rekeyLedgerAccountSelectionViewModel

    private val rekeyLedgerAccountSelectionViewModel by viewModels<RekeyLedgerAccountSelectionViewModel>()

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
        with(rekeyLedgerAccountSelectionViewModel.rekeyLedgerAccountSelectionPreviewFlow) {
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

    override fun onConfirmationClick(selectedAccounts: List<Account>, allAuthAccounts: List<Account>) {
        val selectedAccount = selectedAccounts.firstOrNull()
        if (selectedAccount != null && selectedAccount.detail is Account.Detail.Ledger) {
            nav(
                RekeyLedgerAccountSelectionFragmentDirections
                    .rekeyLedgerAccountSelectionFragmentToRekeyConfirmationFragment(
                        rekeyAddress = rekeyLedgerAccountSelectionViewModel.rekeyAddressKey,
                        rekeyAdminAddress = selectedAccount.address,
                        ledgerDetail = selectedAccount.detail
                    )
            )
        }
    }

    override fun changeToolbarTitle() {
        getAppToolbar()?.changeTitle(rekeyLedgerAccountSelectionViewModel.ledgerBluetoothName.orEmpty())
    }

    override fun setupConfirmButton(confirmationButton: MaterialButton) {
        super.setupConfirmButton(confirmationButton)
        confirmationButton.setText(R.string.select_account)
    }
}
