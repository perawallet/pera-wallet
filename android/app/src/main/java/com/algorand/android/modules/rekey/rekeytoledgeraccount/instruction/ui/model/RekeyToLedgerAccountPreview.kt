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

package com.algorand.android.modules.rekey.rekeytoledgeraccount.instruction.ui.model

import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.baseintroduction.ui.model.BaseIntroductionFields
import com.algorand.android.modules.baseintroduction.ui.model.FeatureTag

data class RekeyToLedgerAccountPreview(
    override val bannerDrawableResId: Int,
    override val titleAnnotatedString: AnnotatedString,
    override val featureTag: FeatureTag?,
    override val descriptionAnnotatedString: AnnotatedString?,
    override val actionButtonAnnotatedString: AnnotatedString,
    val expectationListItems: List<AnnotatedString>
) : BaseIntroductionFields
