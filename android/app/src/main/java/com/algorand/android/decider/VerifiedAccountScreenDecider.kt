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

package com.algorand.android.decider

import com.algorand.android.R
import com.algorand.android.models.Account
import javax.inject.Inject

class VerifiedAccountScreenDecider @Inject constructor() {

    fun decideTitleRes(accountType: Account.Type?): Int {
        return if (accountType == Account.Type.WATCH) {
            R.string.watch_account_added
        } else {
            R.string.account_is_verified
        }
    }

    fun decideDescriptionRes(hasAccount: Boolean, accountType: Account.Type?): Int {
        return when {
            accountType == Account.Type.WATCH -> R.string.the_watch_account_has_been
            hasAccount -> R.string.congratulations_your_account
            else -> R.string.welcome_to_pera_your_account
        }
    }

    fun decideButtonTextRes(hasAccount: Boolean, accountType: Account.Type?): Int {
        return if (hasAccount || accountType == Account.Type.WATCH) {
            R.string.continue_text
        } else {
            R.string.start_using_pera
        }
    }
}
