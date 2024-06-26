/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.modules.collectibles.detail.base.domain.decider

import com.algorand.android.R
import com.algorand.android.models.Account
import javax.inject.Inject

class CollectibleDetailDecider @Inject constructor() {

    // TODO: 4.03.2022 Handle other error cases 
    fun decideWarningTextRes(prismUrl: String?): Int? {
        return if (prismUrl.isNullOrBlank()) {
            R.string.we_can_t_display
        } else {
            null
        }
    }

    fun decideOptedInWarningTextRes(isOwnedByTheUser: Boolean, accountType: Account.Type?): Int? {
        if (isOwnedByTheUser) return null
        return when (accountType) {
            Account.Type.STANDARD, Account.Type.LEDGER, Account.Type.REKEYED, Account.Type.REKEYED_AUTH -> {
                R.string.you_are_not_the_owner
            }
            Account.Type.WATCH -> {
                R.string.this_watch_account_has_opted
            }
            else -> null
        }
    }
}
