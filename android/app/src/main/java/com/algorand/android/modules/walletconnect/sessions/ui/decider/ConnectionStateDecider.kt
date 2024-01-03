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

package com.algorand.android.modules.walletconnect.sessions.ui.decider

import com.algorand.android.R
import javax.inject.Inject

class ConnectionStateDecider @Inject constructor() {

    fun decideConnectionStateName(isConnected: Boolean): Int {
        return if (isConnected) R.string.connected else R.string.disconnected
    }

    fun decideConnectionStateTextColorResId(isConnected: Boolean): Int {
        return if (isConnected) R.color.positive else R.color.negative
    }

    fun decideConnectionStateBackgroundColorResId(isConnected: Boolean): Int {
        return if (isConnected) R.color.positive_lighter else R.color.negative_lighter
    }

    fun decideConnectionStateBackgroundResId(isConnected: Boolean): Int {
        return if (isConnected) R.drawable.bg_rectangle_radius_12 else R.drawable.bg_rectangle_radius_12
    }
}
