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

import android.app.Activity
import android.content.Context
import android.content.res.Resources
import android.graphics.Point
import android.view.View
import android.view.WindowManager

fun Activity.switchToFullScreen() {
    var flags: Int = window.decorView.systemUiVisibility
    flags = flags xor
        (View.SYSTEM_UI_FLAG_VISIBLE or (View.SYSTEM_UI_FLAG_LAYOUT_STABLE or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN))
    this.window.decorView.systemUiVisibility = flags
}

fun Activity.switchToNonFullscreen() {
    var flags: Int = window.decorView.systemUiVisibility
    flags = flags xor
        ((View.SYSTEM_UI_FLAG_LAYOUT_STABLE or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN) or View.SYSTEM_UI_FLAG_VISIBLE)
    this.window.decorView.systemUiVisibility = flags
}

fun Activity.showDarkStatusBarIcons() {
    var flags: Int = window.decorView.systemUiVisibility // get current flag
    flags = flags or View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR // add LIGHT_STATUS_BAR to flag
    window.decorView.systemUiVisibility = flags
}

fun Activity.showLightStatusBarIcons() {
    var flags: Int = window.decorView.systemUiVisibility // get current flag
    flags = flags xor View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR // use XOR here for remove LIGHT_STATUS_BAR from flags
    window.decorView.systemUiVisibility = flags
}

fun Context.getDisplaySize(): Point {
    val displaySize = Point()
    val windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
    windowManager.defaultDisplay.getSize(displaySize)
    return displaySize
}

// TODO: 20.01.2022 There is an issue on Android 12 to making app blurry when putting the app into background
//  https://github.com/Hipo/algorand-android/pull/781#discussion_r787853240
fun Activity.disableScreenCapture() {
    window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
}

fun Activity.enableScreenCapture() {
    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
}

fun Float.pxToDp(resources: Resources): Float {
    return this / resources.displayMetrics.density
}

fun Float.dpToPX(resources: Resources): Float {
    return this * resources.displayMetrics.density
}
