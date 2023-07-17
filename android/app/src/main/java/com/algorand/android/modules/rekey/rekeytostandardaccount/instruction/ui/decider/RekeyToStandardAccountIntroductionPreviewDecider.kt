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

package com.algorand.android.modules.rekey.rekeytostandardaccount.instruction.ui.decider

import com.algorand.android.R
import com.algorand.android.models.Account
import com.algorand.android.models.AnnotatedString
import javax.inject.Inject

class RekeyToStandardAccountIntroductionPreviewDecider @Inject constructor() {

    fun decideBannerDrawableResId(accountType: Account.Type?): Int {
        return when (accountType) {
            Account.Type.STANDARD -> R.drawable.ic_rekey_from_standard_banner
            Account.Type.LEDGER -> R.drawable.ic_rekey_from_ledger_banner
            Account.Type.REKEYED,
            Account.Type.REKEYED_AUTH -> R.drawable.ic_rekey_from_rekeyed_banner
            // [null] and [Watch] cases are not possible
            Account.Type.WATCH, null -> R.drawable.ic_rekey_from_rekeyed_banner
        }
    }

    fun decideDescriptionAnnotatedString(accountType: Account.Type?): AnnotatedString? {
        val stringResId = when (accountType) {
            Account.Type.STANDARD -> R.string.use_another_account_s_private
            Account.Type.LEDGER -> R.string.remove_a_ledger_device_from
            Account.Type.REKEYED, Account.Type.REKEYED_AUTH -> R.string.rekey_your_account_to
            Account.Type.WATCH, null -> null
        }
        // TODO find a way to use `click spannable` in use case
        return AnnotatedString(stringResId = stringResId ?: return null)
    }

    fun decideExpectationListItems(accountType: Account.Type?): List<AnnotatedString> {
        return mutableListOf<AnnotatedString>().apply {
            when (accountType) {
                Account.Type.STANDARD -> {
                    add(AnnotatedString(stringResId = R.string.future_transactions_can_only))
                    add(AnnotatedString(stringResId = R.string.this_account_will_no_longer))
                    add(AnnotatedString(stringResId = R.string.your_account_s_public_key))
                }
                Account.Type.LEDGER -> {
                    add(AnnotatedString(stringResId = R.string.future_transactions_can_only_be))
                    add(AnnotatedString(stringResId = R.string.your_ledger_device_will_no_longer))
                    add(AnnotatedString(stringResId = R.string.your_account_s_public_key))
                    add(AnnotatedString(stringResId = R.string.make_sure_bluetooth))
                }
                Account.Type.REKEYED, Account.Type.REKEYED_AUTH -> {
                    add(AnnotatedString(stringResId = R.string.future_transactions_will_be_signed))
                    add(AnnotatedString(stringResId = R.string.this_account_will_continue))
                    add(AnnotatedString(stringResId = R.string.your_account_s_public_key))
                    add(AnnotatedString(stringResId = R.string.make_sure_bluetooth))
                }
                Account.Type.WATCH, null -> Unit
            }
        }
    }
}
