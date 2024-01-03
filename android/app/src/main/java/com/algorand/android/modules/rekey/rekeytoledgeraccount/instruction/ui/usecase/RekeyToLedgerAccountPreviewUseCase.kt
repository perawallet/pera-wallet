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

package com.algorand.android.modules.rekey.rekeytoledgeraccount.instruction.ui.usecase

import com.algorand.android.R
import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.rekey.rekeytoledgeraccount.instruction.ui.decider.RekeyToLedgerAccountPreviewDecider
import com.algorand.android.modules.rekey.rekeytoledgeraccount.instruction.ui.mapper.RekeyToLedgerAccountPreviewMapper
import com.algorand.android.modules.rekey.rekeytoledgeraccount.instruction.ui.model.RekeyToLedgerAccountPreview
import com.algorand.android.usecase.AccountDetailUseCase
import javax.inject.Inject

class RekeyToLedgerAccountPreviewUseCase @Inject constructor(
    private val accountDetailUseCase: AccountDetailUseCase,
    private val rekeyToLedgerAccountPreviewDecider: RekeyToLedgerAccountPreviewDecider,
    private val rekeyToLedgerAccountPreviewMapper: RekeyToLedgerAccountPreviewMapper
) {

    fun getInitialRekeyToLedgerAccountPreview(accountAddress: String): RekeyToLedgerAccountPreview {
        val accountDetail = accountDetailUseCase.getCachedAccountDetail(accountAddress)?.data
        val accountType = accountDetail?.account?.type
        val bannerDrawableResId = rekeyToLedgerAccountPreviewDecider.decideBannerDrawableResId(
            accountType = accountType
        )
        val descriptionAnnotatedString = rekeyToLedgerAccountPreviewDecider.decideDescriptionAnnotatedString(
            accountType = accountType
        )
        val expectationListItems = rekeyToLedgerAccountPreviewDecider.decideExpectationListItems(
            accountType = accountType
        )
        return rekeyToLedgerAccountPreviewMapper.mapToRekeyToLedgerAccountPreview(
            bannerDrawableResId = bannerDrawableResId,
            titleAnnotatedString = AnnotatedString(stringResId = R.string.rekey_to_ledger_account_lower_case),
            descriptionAnnotatedString = descriptionAnnotatedString,
            expectationListItems = expectationListItems,
            actionButtonAnnotatedString = AnnotatedString(stringResId = R.string.start_process)
        )
    }
}
