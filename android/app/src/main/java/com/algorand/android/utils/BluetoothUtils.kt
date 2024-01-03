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

package com.algorand.android.utils

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.Intent
import android.location.LocationManager
import android.os.Build
import androidx.activity.result.ActivityResultLauncher
import androidx.annotation.RequiresApi
import androidx.core.location.LocationManagerCompat
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.modules.baseledgersearch.ledgersearch.ui.BaseLedgerSearchFragment
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionRequestFragment

fun BaseFragment.isBluetoothEnabled(resultLauncher: ActivityResultLauncher<Intent>): Boolean {

    val bluetoothAdapter =
        (context?.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager)?.adapter ?: return false

    if (context?.areBluetoothPermissionsGranted() != true) {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            requestPermissionFromUser(BLUETOOTH_SCAN_PERMISSION, BLUETOOTH_SCAN_PERMISSION_REQUEST_CODE, true)
            requestPermissionFromUser(BLUETOOTH_CONNECT_PERMISSION, BLUETOOTH_CONNECT_PERMISSION_REQUEST_CODE, true)
            false
        } else {
            requestPermissionFromUser(LOCATION_PERMISSION, LOCATION_PERMISSION_REQUEST_CODE, true)
            false
        }
    }
    if (bluetoothAdapter.isEnabled.not()) {
        showEnableBluetoothPopup(resultLauncher)
        return false
    }
    if (context?.isLocationEnabled() != true) {
        when (this) {
            is TransactionBaseFragment -> {
                permissionDeniedOnTransactionData(R.string.please_ensure, R.string.bluetooth_location_services)
            }
            is WalletConnectTransactionRequestFragment -> {
                permissionDeniedOnTransaction(R.string.please_ensure, R.string.bluetooth_location_services)
            }
            is BaseLedgerSearchFragment -> {
                showGlobalError(getString(R.string.please_ensure), getString(R.string.bluetooth_location_services))
                navBack()
            }
        }
        return false
    }
    return true
}

fun Context.isLocationEnabled(): Boolean {
    val locationManager = getSystemService(Context.LOCATION_SERVICE) as? LocationManager ?: return false
    return LocationManagerCompat.isLocationEnabled(locationManager)
}

fun showEnableBluetoothPopup(resultLauncher: ActivityResultLauncher<Intent>) {
    Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE).apply { resultLauncher.launch(this) }
}

fun requestLocationRequestFromUser(resultLauncher: ActivityResultLauncher<String>) {
    resultLauncher.launch(android.Manifest.permission.ACCESS_FINE_LOCATION)
}

fun Context.checkIfBluetoothPermissionAreTaken(
    bluetoothResultLauncher: ActivityResultLauncher<Array<String>>,
    locationResultLauncher: ActivityResultLauncher<String>
): Boolean {
    if (!areBluetoothPermissionsGranted()) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            requestBluetoothScanConnectPermission(bluetoothResultLauncher)
        } else {
            requestLocationPermission(locationResultLauncher)
        }
        return false
    }
    return true
}

@RequiresApi(Build.VERSION_CODES.S)
private fun requestBluetoothScanConnectPermission(resultLauncher: ActivityResultLauncher<Array<String>>) {
    resultLauncher.launch(
        arrayOf(
            android.Manifest.permission.BLUETOOTH_SCAN,
            android.Manifest.permission.BLUETOOTH_CONNECT
        )
    )
}

private fun requestLocationPermission(resultLauncher: ActivityResultLauncher<String>) {
    resultLauncher.launch(android.Manifest.permission.ACCESS_FINE_LOCATION)
}
