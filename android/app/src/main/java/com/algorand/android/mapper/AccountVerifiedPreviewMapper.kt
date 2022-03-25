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

package com.algorand.android.mapper

import com.algorand.android.R
import com.algorand.android.decider.VerifiedAccountScreenDecider
import com.algorand.android.models.Account
import com.algorand.android.models.AccountVerifiedPreview
import javax.inject.Inject

class AccountVerifiedPreviewMapper @Inject constructor(
    private val verifiedAccountScreenDecider: VerifiedAccountScreenDecider
) {

    fun mapTo(hasAccount: Boolean, accountType: Account.Type?): AccountVerifiedPreview {
        val titleRes = verifiedAccountScreenDecider.decideTitleRes(accountType)
        val descriptionRes = verifiedAccountScreenDecider.decideDescriptionRes(hasAccount, accountType)
        val imageRes = R.drawable.ic_check
        val buttonTextRes = verifiedAccountScreenDecider.decideButtonTextRes(hasAccount, accountType)
        return AccountVerifiedPreview(titleRes, descriptionRes, imageRes, buttonTextRes)
    }
}
