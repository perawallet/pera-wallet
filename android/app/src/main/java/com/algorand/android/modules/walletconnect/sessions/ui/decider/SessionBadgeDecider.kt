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
import com.algorand.android.modules.walletconnect.domain.model.WalletConnectVersionIdentifier
import javax.inject.Inject

class SessionBadgeDecider @Inject constructor() {

    fun decideBadgeName(versionIdentifier: WalletConnectVersionIdentifier): Int? {
        return when (versionIdentifier) {
            WalletConnectVersionIdentifier.VERSION_1 -> R.string.wc_v1
            WalletConnectVersionIdentifier.VERSION_2 -> null
        }
    }

    fun decideBadgeTextColorResId(versionIdentifier: WalletConnectVersionIdentifier): Int? {
        return when (versionIdentifier) {
            WalletConnectVersionIdentifier.VERSION_1 -> R.color.text_gray
            WalletConnectVersionIdentifier.VERSION_2 -> null
        }
    }

    fun decideBadgeBackgroundColorResId(versionIdentifier: WalletConnectVersionIdentifier): Int? {
        return when (versionIdentifier) {
            WalletConnectVersionIdentifier.VERSION_1 -> R.color.layer_gray_lighter
            WalletConnectVersionIdentifier.VERSION_2 -> null
        }
    }

    fun decideBadgeBackgroundResId(versionIdentifier: WalletConnectVersionIdentifier): Int? {
        return when (versionIdentifier) {
            WalletConnectVersionIdentifier.VERSION_1 -> R.drawable.bg_rectangle_radius_12
            WalletConnectVersionIdentifier.VERSION_2 -> null
        }
    }
}
