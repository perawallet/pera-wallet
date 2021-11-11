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

import android.bluetooth.BluetoothDevice
import androidx.navigation.navGraphViewModels
import com.algorand.android.R
import com.algorand.android.models.AccountInformation
import com.algorand.android.ui.common.BaseLedgerSearchFragment
import com.algorand.android.ui.register.ledger.PairLedgerNavigationViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class RegisterLedgerSearchFragment : BaseLedgerSearchFragment(titleResId = R.string.pair_ledger_device) {

    override val fragmentId: Int = R.id.registerLedgerSearchFragment

    private val pairLedgerNavigationViewModel: PairLedgerNavigationViewModel by navGraphViewModels(R.id.pairLedgerNavigation) {
        defaultViewModelProviderFactory
    }

    override fun onLedgerConnected(
        accountList: List<AccountInformation>,
        ledgerDevice: BluetoothDevice
    ) {
        setLoadingVisibility(isVisible = false)
        pairLedgerNavigationViewModel.pairedLedger = ledgerDevice
        nav(
            RegisterLedgerSearchFragmentDirections.actionRegisterLedgerSearchFragmentToLedgerAccountSelectionFragment(
                ledgerAccountsInformation = accountList.toTypedArray(),
                bluetoothName = ledgerDevice.name,
                bluetoothAddress = ledgerDevice.address
            )
        )
    }

    override fun navigateToPairInstructionBottomSheet(bluetoothDevice: BluetoothDevice) {
        nav(
            RegisterLedgerSearchFragmentDirections
                .actionRegisterLedgerSearchFragmentToLedgerPairInstructionsBottomSheet(bluetoothDevice)
        )
    }
}
