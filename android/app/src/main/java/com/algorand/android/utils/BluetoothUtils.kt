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
import android.content.Context
import android.content.Intent
import android.location.LocationManager
import androidx.activity.result.ActivityResultLauncher
import androidx.core.location.LocationManagerCompat
import androidx.fragment.app.Fragment
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.core.TransactionBaseFragment
import com.algorand.android.ui.common.BaseLedgerSearchFragment
import com.algorand.android.ui.wctransactionrequest.WalletConnectTransactionRequestFragment

fun BaseFragment.isBluetoothEnabled(): Boolean {
    val bluetoothAdapter = BluetoothAdapter.getDefaultAdapter() ?: return false

    if (context?.isPermissionGranted(LOCATION_PERMISSION) != true) {
        requestPermissionFromUser(LOCATION_PERMISSION, LOCATION_PERMISSION_REQUEST_CODE, true)
        return false
    }
    if (bluetoothAdapter.isEnabled.not()) {
        showEnableBluetoothPopup()
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

fun Fragment.showEnableBluetoothPopup() {
    val enableBtIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
    startActivityForResult(enableBtIntent, BLE_OPEN_REQUEST_CODE)
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
