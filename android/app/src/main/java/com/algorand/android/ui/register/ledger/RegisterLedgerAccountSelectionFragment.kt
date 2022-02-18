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

import androidx.navigation.fragment.navArgs
import androidx.navigation.navGraphViewModels
import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.AccountInformation
import com.algorand.android.models.AccountSelectionListItem
import com.algorand.android.ui.ledgeraccountselection.BaseLedgerAccountSelectionFragment
import com.algorand.android.ui.ledgeraccountselection.SearchType
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class RegisterLedgerAccountSelectionFragment : BaseLedgerAccountSelectionFragment() {

    private val pairLedgerNavigationViewModel: PairLedgerNavigationViewModel by navGraphViewModels(
        R.id.pairLedgerNavigation
    ) {
        defaultViewModelProviderFactory
    }

    private val args: RegisterLedgerAccountSelectionFragmentArgs by navArgs()

    override val searchType = SearchType.REGISTER

    override fun getLedgerAccountsInformation(): Array<AccountInformation> {
        return args.ledgerAccountsInformation
    }

    override fun onConfirmationClick(selectedAccounts: List<Account>, allAuthAccounts: List<Account>) {
        pairLedgerNavigationViewModel.selectedAccounts = selectedAccounts
        pairLedgerNavigationViewModel.allAuthAccounts = allAuthAccounts
        nav(
            RegisterLedgerAccountSelectionFragmentDirections
                .actionRegisterLedgerAccountSelectionFragmentToVerifyLedgerAddressFragment()
        )
    }

    override fun getBluetoothName(): String? {
        return args.bluetoothName
    }

    override fun onSelectionListFetched(selectionList: List<AccountSelectionListItem>): List<AccountSelectionListItem> {
        return selectionList
    }

    override fun getBluetoothAddress(): String {
        return args.bluetoothAddress
    }
}
