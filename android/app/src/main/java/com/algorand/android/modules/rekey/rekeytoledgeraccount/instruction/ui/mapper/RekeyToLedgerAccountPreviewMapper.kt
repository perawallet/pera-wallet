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

package com.algorand.android.modules.rekey.rekeytoledgeraccount.instruction.ui.mapper

import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.baseintroduction.ui.model.FeatureTag
import com.algorand.android.modules.rekey.rekeytoledgeraccount.instruction.ui.model.RekeyToLedgerAccountPreview
import javax.inject.Inject

class RekeyToLedgerAccountPreviewMapper @Inject constructor() {

    fun mapToRekeyToLedgerAccountPreview(
        bannerDrawableResId: Int,
        titleAnnotatedString: AnnotatedString,
        featureTag: FeatureTag? = null,
        descriptionAnnotatedString: AnnotatedString?,
        actionButtonAnnotatedString: AnnotatedString,
        expectationListItems: List<AnnotatedString>
    ): RekeyToLedgerAccountPreview {
        return RekeyToLedgerAccountPreview(
            bannerDrawableResId = bannerDrawableResId,
            titleAnnotatedString = titleAnnotatedString,
            featureTag = featureTag,
            descriptionAnnotatedString = descriptionAnnotatedString,
            actionButtonAnnotatedString = actionButtonAnnotatedString,
            expectationListItems = expectationListItems
        )
    }
}
