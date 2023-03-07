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

package com.algorand.android.modules.rekey.rekeytostandardaccount.instruction.ui.mapper

import com.algorand.android.modules.rekey.rekeytostandardaccount.instruction.ui.model.RekeyToStandardAccountInstructionPreview
import javax.inject.Inject

class RekeyToStandardAccountInstructionPreviewMapper @Inject constructor() {

    fun mapToRekeyToStandardAccountInstructionPreview(
        titleTextResId: Int,
        descriptionTextResId: Int,
        firstDescriptionTextResId: Int,
        secondDescriptionTextRestId: Int,
        thirdDescriptionTextResId: Int,
        actionButtonTextResId: Int
    ): RekeyToStandardAccountInstructionPreview {
        return RekeyToStandardAccountInstructionPreview(
            titleTextResId = titleTextResId,
            descriptionTextResId = descriptionTextResId,
            firstDescriptionTextResId = firstDescriptionTextResId,
            secondDescriptionTextRestId = secondDescriptionTextRestId,
            thirdDescriptionTextResId = thirdDescriptionTextResId,
            actionButtonTextResId = actionButtonTextResId
        )
    }
}
