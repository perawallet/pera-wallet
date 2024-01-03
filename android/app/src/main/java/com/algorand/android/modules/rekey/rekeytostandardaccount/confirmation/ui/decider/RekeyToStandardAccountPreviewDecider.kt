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

package com.algorand.android.modules.rekey.rekeytostandardaccount.confirmation.ui.decider

import com.algorand.android.R
import com.algorand.android.models.AccountDetail
import com.algorand.android.models.AnnotatedString
import javax.inject.Inject

class RekeyToStandardAccountPreviewDecider @Inject constructor() {

    fun decideDescriptionAnnotatedString(accountDetail: AccountDetail?): AnnotatedString {
        return if (accountDetail?.accountInformation?.isRekeyed() == true) {
            AnnotatedString(R.string.you_are_about_to_rekey_this)
        } else {
            AnnotatedString(R.string.you_are_about_to_rekey)
        }
    }
}
