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

package com.algorand.android.ui.ledgersearch

import android.bluetooth.BluetoothDevice
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import com.algorand.android.core.BaseViewModel
import com.algorand.android.ledger.CustomScanCallback
import com.algorand.android.ledger.LedgerBleSearchManager

class LedgerSearchViewModel @ViewModelInject constructor(
    private val ledgerBleSearchManager: LedgerBleSearchManager
) : BaseViewModel() {

    val ledgerDevicesLiveData = MutableLiveData<List<LedgerBaseItem>>()

    private val addressLedgerDeviceMap = HashMap<String, BluetoothDevice>()

    private val scanCallback = object : CustomScanCallback() {
        override fun onLedgerScanned(device: BluetoothDevice) {
            if (!addressLedgerDeviceMap.containsKey(device.address)) {
                addressLedgerDeviceMap[device.address] = device
                val ledgerDeviceSet = addressLedgerDeviceMap.values.toSet()
                mutableListOf<LedgerBaseItem>().apply {
                    add(LedgerBaseItem.LedgerLoadingItem)
                    addAll(ledgerDeviceSet.map { LedgerBaseItem.LedgerItem(it) })
                    ledgerDevicesLiveData.postValue(this)
                }
            }
        }

        override fun onScanError(errorMessageResId: Int, titleResId: Int) {
            // NOT NEEDED
        }
    }

    init {
        ledgerDevicesLiveData.postValue(listOf(LedgerBaseItem.LedgerLoadingItem))
    }

    fun startBluetoothSearch() {
        ledgerBleSearchManager.scan(scanCallback)
    }

    fun stopBluetoothSearch() {
        ledgerBleSearchManager.stop()
    }
}
