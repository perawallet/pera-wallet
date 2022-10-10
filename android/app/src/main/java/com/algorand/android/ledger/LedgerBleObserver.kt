/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.ledger

import android.bluetooth.BluetoothDevice
import androidx.annotation.StringRes
import com.algorand.android.R
import no.nordicsemi.android.ble.observer.BondingObserver
import no.nordicsemi.android.ble.observer.ConnectionObserver

interface LedgerBleObserver : ConnectionObserver, BondingObserver {

    fun onDataReceived(device: BluetoothDevice, data: ByteArray) {
        // override when needed
    }

    fun onOperationCancelled() {
        // override when needed
    }

    fun onManagerError(
        @StringRes errorResId: Int,
        @StringRes titleResId: Int = R.string.error_default_title
    ) {
        // override when needed
    }

    fun onMissingBytes(device: BluetoothDevice) {
        // override when needed
    }

    fun onError(device: BluetoothDevice, message: String, errorCode: Int) {
        // override when needed
    }

    // ConnectionObserver
    override fun onDeviceDisconnecting(device: BluetoothDevice) {
        // not needed yet.
    }

    override fun onDeviceDisconnected(device: BluetoothDevice, reason: Int) {
        // not needed yet.
    }

    override fun onDeviceReady(device: BluetoothDevice) {
        // not needed yet.
    }

    override fun onDeviceConnecting(device: BluetoothDevice) {
        // not needed yet.
    }

    override fun onDeviceConnected(device: BluetoothDevice) {
        // not needed yet.
    }

    override fun onDeviceFailedToConnect(device: BluetoothDevice, reason: Int) {
        // not needed yet.
    }

    // BondingObserver
    override fun onBonded(device: BluetoothDevice) {
        // not needed yet.
    }

    override fun onBondingRequired(device: BluetoothDevice) {
        // not needed yet.
    }

    override fun onBondingFailed(device: BluetoothDevice) {
        // not needed yet.
    }
}
