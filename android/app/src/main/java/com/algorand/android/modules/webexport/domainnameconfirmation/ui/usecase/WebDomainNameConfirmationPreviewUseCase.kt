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

package com.algorand.android.modules.webexport.domainnameconfirmation.ui.usecase

import com.algorand.android.modules.webexport.domainnameconfirmation.domain.usecase.WebExportDomainNameConfirmationUseCase
import com.algorand.android.modules.webexport.domainnameconfirmation.ui.mapper.WebExportDomainNameConfirmationPreviewMapper
import com.algorand.android.modules.webexport.domainnameconfirmation.ui.model.WebExportDomainNameConfirmationPreview
import com.algorand.android.usecase.SecurityUseCase
import com.algorand.android.utils.Event
import javax.inject.Inject

class WebDomainNameConfirmationPreviewUseCase @Inject constructor(
    private val securityUseCase: SecurityUseCase,
    private val webExportDomainNameConfirmationUseCase: WebExportDomainNameConfirmationUseCase,
    private val webExportDomainNameConfirmationPreviewMapper: WebExportDomainNameConfirmationPreviewMapper
) {

    fun getInitialPreview(
        backupId: String,
        modificationKey: String,
        encryptionKey: String,
        accountList: List<String>
    ): WebExportDomainNameConfirmationPreview {
        return webExportDomainNameConfirmationPreviewMapper.mapTo(
            backupId = backupId,
            modificationKey = modificationKey,
            encryptionKey = encryptionKey,
            accountList = accountList,
            isEnabled = false,
            navigateToShowAuthenticationEvent = null,
            navigateToAccountConfirmationEvent = null,
            hideKeyboardEvent = null
        )
    }

    fun getUpdatedPreviewWithInputUrl(
        previousPreview: WebExportDomainNameConfirmationPreview,
        inputUrl: String
    ): WebExportDomainNameConfirmationPreview {
        return previousPreview.copy(
            isContinueButtonEnabled = webExportDomainNameConfirmationUseCase.isInputUrlValidDomain(inputUrl)
        )
    }

    fun getUpdatedPreviewWithClickDestination(
        previousPreview: WebExportDomainNameConfirmationPreview
    ): WebExportDomainNameConfirmationPreview {
        val pinEnabled = securityUseCase.isPinCodeEnabled()
        val navigateEvent = Event(Unit)
        return previousPreview.copy(
            navigateToShowAuthenticationEvent = navigateEvent.takeIf { pinEnabled },
            navigateToAccountConfirmationEvent = navigateEvent.takeIf { !pinEnabled }
        )
    }

    fun getUpdatedPreviewWithImeOptionDoneClicked(
        previousPreview: WebExportDomainNameConfirmationPreview
    ): WebExportDomainNameConfirmationPreview {
        val isContinueButtonEnabled = previousPreview.isContinueButtonEnabled
        return if (isContinueButtonEnabled) getUpdatedPreviewWithClickDestination(previousPreview) else previousPreview
    }
    fun getUpdatedPreviewAfterPasscodeVerified(
        previousPreview: WebExportDomainNameConfirmationPreview
    ): WebExportDomainNameConfirmationPreview {
        return previousPreview.copy(
            navigateToAccountConfirmationEvent = Event(Unit)
        )
    }

    fun getUpdatedPreviewWithUrlActionButtonEvent(
        previousPreview: WebExportDomainNameConfirmationPreview
    ): WebExportDomainNameConfirmationPreview {
        return if (previousPreview.isContinueButtonEnabled) {
            getUpdatedPreviewWithClickDestination(previousPreview = previousPreview)
        } else {
            previousPreview.copy(hideKeyboardEvent = Event(Unit))
        }
    }
}
