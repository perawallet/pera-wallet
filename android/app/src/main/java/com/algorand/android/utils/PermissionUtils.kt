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

package com.algorand.android.utils

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment

const val LOCATION_PERMISSION = Manifest.permission.ACCESS_FINE_LOCATION
const val CAMERA_PERMISSION = Manifest.permission.CAMERA
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
