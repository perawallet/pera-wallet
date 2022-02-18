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

import android.bluetooth.BluetoothDevice
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.models.AccountInformation
import com.algorand.android.ui.common.BaseLedgerSearchFragment
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class RekeyLedgerSearchFragment : BaseLedgerSearchFragment() {

    override val fragmentId: Int = R.id.rekeyLedgerSearchFragment

    private val args: RekeyLedgerSearchFragmentArgs by navArgs()

    override fun onLedgerConnected(accountList: List<AccountInformation>, ledgerDevice: BluetoothDevice) {
        setLoadingVisibility(isVisible = false)
        nav(
            RekeyLedgerSearchFragmentDirections.actionRekeyLedgerSearchFragmentToRekeyLedgerAccountSelectionFragment(
                ledgerDevice.name, ledgerDevice.address, accountList.toTypedArray(), args.rekeyAddress
            )
        )
    }

    override fun navToPairInstructionBottomSheet(bluetoothDevice: BluetoothDevice) {
        nav(
            RekeyLedgerSearchFragmentDirections
                .actionRekeyLedgerSearchFragmentToLedgerPairInstructionsBottomSheet(bluetoothDevice)
        )
    }
}
