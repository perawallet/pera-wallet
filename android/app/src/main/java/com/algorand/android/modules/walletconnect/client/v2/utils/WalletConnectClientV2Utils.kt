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

package com.algorand.android.modules.walletconnect.client.v2.utils

import com.algorand.android.modules.walletconnect.domain.model.WalletConnectVersionIdentifier

object WalletConnectClientV2Utils {

    fun getWalletConnectV2VersionIdentifier() = WalletConnectVersionIdentifier.VERSION_2

    fun isValidWalletConnectV2Url(url: String): Boolean {
        return WalletConnectV2UriValidator.isValidWCUri(url)
    }
}
