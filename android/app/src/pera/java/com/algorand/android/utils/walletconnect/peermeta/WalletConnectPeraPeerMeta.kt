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

package com.algorand.android.utils.walletconnect.peermeta

object WalletConnectPeraPeerMeta : WalletConnectPeerMetaBuilder {

    override val appName: String
        get() = "Pera Wallet"

    override val appDescription: String
        get() = "Pera Wallet: Simply the best Algorand wallet."

    override val appUrl: String
        get() = "https://perawallet.app/"

    override val appIcons: List<String>
        get() = listOf(
            "https://algorand-app.s3.amazonaws.com/app-icons/Pera-walletconnect-128.png",
            "https://algorand-app.s3.amazonaws.com/app-icons/Pera-walletconnect-192.png",
            "https://algorand-app.s3.amazonaws.com/app-icons/Pera-walletconnect-512.png"
        )
}
