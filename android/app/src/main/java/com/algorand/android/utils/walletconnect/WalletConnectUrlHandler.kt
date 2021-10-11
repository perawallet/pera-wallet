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

package com.algorand.android.utils.walletconnect

import com.algorand.android.R
import com.algorand.android.models.Account.Type.WATCH
import com.algorand.android.models.AssetInformation.Companion.ALGORAND_ID
import com.algorand.android.utils.AccountCacheManager
import javax.inject.Inject

class WalletConnectUrlHandler @Inject constructor(private val accountCacheManager: AccountCacheManager) {

    fun checkWalletConnectUrl(url: String, listener: Listener) {
        if (hasValidAccountForWalletConnect()) {
            if (!isValidWalletConnectUrl(url)) {
                listener.onInvalidWalletConnectUrl(R.string.could_not_create_wallet_connect)
                return
            }
            listener.onValidWalletConnectUrl(url)
        } else {
            listener.onInvalidWalletConnectUrl(R.string.you_do_not_have_any)
        }
    }

    private fun hasValidAccountForWalletConnect(): Boolean {
        return accountCacheManager.getAccountCacheWithSpecificAsset(ALGORAND_ID, listOf(WATCH)).isNotEmpty()
    }

    interface Listener {
        fun onValidWalletConnectUrl(url: String)
        fun onInvalidWalletConnectUrl(errorResId: Int)
    }
}
