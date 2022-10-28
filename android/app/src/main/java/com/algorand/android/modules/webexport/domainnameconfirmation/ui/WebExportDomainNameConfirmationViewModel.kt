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

package com.algorand.android.modules.webexport.domainnameconfirmation.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.webexport.domainnameconfirmation.ui.model.WebExportDomainNameConfirmationPreview
import com.algorand.android.modules.webexport.domainnameconfirmation.ui.usecase.WebDomainNameConfirmationPreviewUseCase
import com.algorand.android.modules.webexport.utils.NAVIGATION_ACCOUNT_LIST_KEY
import com.algorand.android.modules.webexport.utils.NAVIGATION_BACKUP_ID_KEY
import com.algorand.android.modules.webexport.utils.NAVIGATION_ENCRYPTION_KEY
import com.algorand.android.modules.webexport.utils.NAVIGATION_MODIFICATION_KEY
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class WebExportDomainNameConfirmationViewModel @Inject constructor(
    private val webDomainNameConfirmationPreviewUseCase: WebDomainNameConfirmationPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val backupId = savedStateHandle.getOrThrow<String>(NAVIGATION_BACKUP_ID_KEY)
    private val modificationKey = savedStateHandle.getOrThrow<String>(NAVIGATION_MODIFICATION_KEY)
    private val encryptionKey = savedStateHandle.getOrThrow<String>(NAVIGATION_ENCRYPTION_KEY)
    private val accountList = savedStateHandle.getOrThrow<Array<String>>(NAVIGATION_ACCOUNT_LIST_KEY)

    val webExportDomainNameConfirmationPreviewFlow: StateFlow<WebExportDomainNameConfirmationPreview>
        get() = _domainNameConfirmationPreviewFlow
    private val _domainNameConfirmationPreviewFlow = MutableStateFlow(getInitialPreview())

    fun updatePreviewWithUrlInput(inputUrl: String) {
        viewModelScope.launch {
            _domainNameConfirmationPreviewFlow.emit(
                webDomainNameConfirmationPreviewUseCase.getUpdatedPreviewWithInputUrl(
                    previousPreview = _domainNameConfirmationPreviewFlow.value,
                    inputUrl = inputUrl
                )
            )
        }
    }

    fun onNavigationToNextFragmentClicked() {
        viewModelScope.launch {
            _domainNameConfirmationPreviewFlow.emit(
                webDomainNameConfirmationPreviewUseCase.getUpdatedPreviewWithClickDestination(
                    previousPreview = _domainNameConfirmationPreviewFlow.value
                )
            )
        }
    }

    fun handlePasswordEntryResult(isPasscodeVerified: Boolean) {
        viewModelScope.launch {
            if (isPasscodeVerified) {
                _domainNameConfirmationPreviewFlow.emit(
                    webDomainNameConfirmationPreviewUseCase.getUpdatedPreviewAfterPasscodeVerified(
                        previousPreview = _domainNameConfirmationPreviewFlow.value
                    )
                )
            }
        }
    }

    private fun getInitialPreview(): WebExportDomainNameConfirmationPreview {
        return webDomainNameConfirmationPreviewUseCase.getInitialPreview(
            backupId = backupId,
            modificationKey = modificationKey,
            encryptionKey = encryptionKey,
            accountList = accountList.toList()
        )
    }
}
