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

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment

@RequiresApi(Build.VERSION_CODES.S)
const val BLUETOOTH_SCAN_PERMISSION = Manifest.permission.BLUETOOTH_SCAN

@RequiresApi(Build.VERSION_CODES.S)
const val BLUETOOTH_CONNECT_PERMISSION = Manifest.permission.BLUETOOTH_CONNECT
const val LOCATION_PERMISSION = Manifest.permission.ACCESS_FINE_LOCATION
const val CAMERA_PERMISSION = Manifest.permission.CAMERA

const val BLUETOOTH_CONNECT_PERMISSION_REQUEST_CODE = 1013
const val BLUETOOTH_SCAN_PERMISSION_REQUEST_CODE = 1012
const val LOCATION_PERMISSION_REQUEST_CODE = 1011
const val CAMERA_PERMISSION_REQUEST_CODE = 1010
const val BLE_OPEN_REQUEST_CODE = 1009

fun Fragment.requestPermissionFromUser(
    permission: String,
    permissionRequestCode: Int,
    shouldShowAlways: Boolean
) {
    if (!shouldShowRequestPermissionRationale(permission) || shouldShowAlways) {
        requestPermissions(arrayOf(permission), permissionRequestCode)
    }
}

fun Context.isPermissionGranted(permission: String): Boolean {
    return ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
}

fun Context.areBluetoothPermissionsGranted(): Boolean {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        isPermissionGranted(BLUETOOTH_SCAN_PERMISSION) && isPermissionGranted(BLUETOOTH_CONNECT_PERMISSION)
    } else {
        isPermissionGranted(LOCATION_PERMISSION)
    }
}
