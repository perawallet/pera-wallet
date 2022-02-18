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

package com.algorand.android.ledger

import android.bluetooth.BluetoothManager
import android.bluetooth.le.ScanFilter
import android.bluetooth.le.ScanSettings
import android.os.Handler
import android.os.ParcelUuid
import com.algorand.android.R
import com.algorand.android.ledger.LedgerBleConnectionManager.Companion.SERVICE_UUID
import javax.inject.Inject

class LedgerBleSearchManager @Inject constructor(
    private val bluetoothManager: BluetoothManager?,
    private val ledgerBleConnectionManager: LedgerBleConnectionManager
) {

    private var isScanning = false
    private var scanCallback: CustomScanCallback? = null
    private var connectionTimeoutHandler: Handler? = null

    fun scan(newScanCallback: CustomScanCallback, filteredAddress: String? = null) {
        if (filteredAddress != null && isLedgerConnected(filteredAddress)) {
            // Don't need to scan any ledger devices because it has already connected.
            return
        }

        if (isScanning) return
        isScanning = true
        this.scanCallback = newScanCallback.apply {
            this.filteredAddress = filteredAddress
        }

        val scanFilters = listOf(
            ScanFilter.Builder()
                .setServiceUuid(ParcelUuid(SERVICE_UUID))
                .build()
        )

        val scanSettings = ScanSettings.Builder().build()
        bluetoothManager?.adapter?.bluetoothLeScanner?.startScan(scanFilters, scanSettings, scanCallback)

        if (filteredAddress != null) {
            startTimeout()
        } else {
            provideConnectedLedger()
        }
    }

    private fun startTimeout() {
        connectionTimeoutHandler = Handler()
        connectionTimeoutHandler?.postDelayed({
            scanCallback?.onScanError(R.string.error_connection_message, R.string.error_connection_title)
            stop()
        }, MAX_SCAN_DURATION)
    }

    private fun provideConnectedLedger() {
        val connectedDevice = ledgerBleConnectionManager.bluetoothDevice
        if (connectedDevice != null) {
            scanCallback?.onLedgerScanned(connectedDevice)
        }
    }

    private fun isLedgerConnected(deviceAddress: String): Boolean {
        val connectedDevice = ledgerBleConnectionManager.bluetoothDevice
        if (connectedDevice != null && connectedDevice.address == deviceAddress) {
            scanCallback?.onLedgerScanned(connectedDevice)
            return true
        }

        return false
    }

    fun stop() {
        connectionTimeoutHandler?.removeCallbacksAndMessages(null)
        scanCallback?.run {
            bluetoothManager?.adapter?.bluetoothLeScanner?.stopScan(this)
        }
        isScanning = false
    }

    companion object {
        private const val MAX_SCAN_DURATION = 15000L
    }
}
