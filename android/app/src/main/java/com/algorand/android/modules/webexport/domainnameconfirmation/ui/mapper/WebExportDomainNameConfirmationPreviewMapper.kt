/*
 *  Copyright 2022 Pera Wallet, LDA
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License
 */

package com.algorand.android.modules.webexport.domainnameconfirmation.ui.mapper

import com.algorand.android.modules.webexport.domainnameconfirmation.ui.model.WebExportDomainNameConfirmationPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class WebExportDomainNameConfirmationPreviewMapper @Inject constructor() {

    fun mapTo(
        backupId: String,
        modificationKey: String,
        encryptionKey: String,
        accountList: List<String>,
        isEnabled: Boolean,
        navigateToShowAuthenticationEvent: Event<Unit>?,
        navigateToAccountConfirmationEvent: Event<Unit>?
    ): WebExportDomainNameConfirmationPreview {
        return WebExportDomainNameConfirmationPreview(
            backupId = backupId,
            modificationKey = modificationKey,
            encryptionKey = encryptionKey,
            accountList = accountList,
            isContinueButtonEnabled = isEnabled,
            navigateToShowAuthenticationEvent = navigateToShowAuthenticationEvent,
            navigateToAccountConfirmationEvent = navigateToAccountConfirmationEvent
        )
    }
}
