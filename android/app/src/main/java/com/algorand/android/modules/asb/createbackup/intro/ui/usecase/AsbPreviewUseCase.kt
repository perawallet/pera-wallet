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

package com.algorand.android.modules.asb.createbackup.intro.ui.usecase

import com.algorand.android.modules.asb.createbackup.intro.ui.mapper.AsbIntroPreviewMapper
import com.algorand.android.modules.asb.createbackup.intro.ui.model.AsbIntroPreview
import com.algorand.android.usecase.SecurityUseCase
import com.algorand.android.utils.Event
import com.algorand.android.utils.browser.ASB_SUPPORT_URL
import javax.inject.Inject

class AsbPreviewUseCase @Inject constructor(
    private val securityUseCase: SecurityUseCase,
    private val asbIntroPreviewMapper: AsbIntroPreviewMapper
) {

    fun getInitialPreview(): AsbIntroPreview {
        return asbIntroPreviewMapper.mapToAlgorandSecureBackupIntroPreview()
    }

    fun updatePreviewAfterStartClick(preview: AsbIntroPreview): AsbIntroPreview {
        val pinEnabled = securityUseCase.isPinCodeEnabled()
        val navigateEvent = Event(Unit)
        return preview.copy(
            navToAccountSelectionScreenEvent = navigateEvent.takeIf { !pinEnabled },
            navToEnterPinScreenEvent = navigateEvent.takeIf { pinEnabled }
        )
    }

    fun updatePreviewAfterLearnMoreClick(preview: AsbIntroPreview): AsbIntroPreview {
        return preview.copy(openUrlEvent = Event(ASB_SUPPORT_URL))
    }
}
