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

import android.bluetooth.BluetoothDevice
import androidx.hilt.lifecycle.ViewModelInject
import com.algorand.android.core.BaseViewModel
import com.algorand.android.models.Account

class PairLedgerNavigationViewModel @ViewModelInject constructor() : BaseViewModel() {

    var selectedAccounts = listOf<Account>()

    var allAuthAccounts = listOf<Account>()

    var pairedLedger: BluetoothDevice? = null

    fun getSelectedAuthAccounts(): List<Account> {
        return allAuthAccounts.filter { authAccount ->
            selectedAccounts.any { selectedAccount ->
                if (authAccount.address == selectedAccount.address) {
                    return@any true
                }
                if (selectedAccount.detail is Account.Detail.RekeyedAuth) {
                    selectedAccount.detail.rekeyedAuthDetail[authAccount.address] != null
                } else {
                    false
                }
            }
        }
    }
}
