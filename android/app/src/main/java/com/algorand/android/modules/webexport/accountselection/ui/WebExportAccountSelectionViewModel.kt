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

package com.algorand.android.modules.webexport.accountselection.ui

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import com.algorand.android.core.BaseViewModel
import com.algorand.android.customviews.TriStatesCheckBox
import com.algorand.android.modules.webexport.accountselection.ui.model.WebExportAccountSelectionPreview
import com.algorand.android.modules.webexport.accountselection.ui.usecase.WebExportAccountSelectionPreviewUseCase
import com.algorand.android.modules.webexport.model.WebExportQrCode
import com.algorand.android.modules.webexport.utils.NAVIGATION_BACKUP_ID_KEY
import com.algorand.android.modules.webexport.utils.NAVIGATION_ENCRYPTION_KEY
import com.algorand.android.modules.webexport.utils.NAVIGATION_MODIFICATION_KEY
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

@HiltViewModel
class WebExportAccountSelectionViewModel @Inject constructor(
    private val webExportAccountSelectionPreviewUseCase: WebExportAccountSelectionPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    val backupId = savedStateHandle.getOrThrow<String>(NAVIGATION_BACKUP_ID_KEY)
    val modificationKey = savedStateHandle.getOrThrow<String>(NAVIGATION_MODIFICATION_KEY)
    val encryptionKey = savedStateHandle.getOrThrow<String>(NAVIGATION_ENCRYPTION_KEY)

    val webExportAccountSelectionPreviewFlow: StateFlow<WebExportAccountSelectionPreview>
        get() = _webExportAccountSelectionPreviewFlow
    private val _webExportAccountSelectionPreviewFlow = MutableStateFlow(getInitialPreview())

    init {
        initPreviewFlow()
    }

    private fun initPreviewFlow() {
        viewModelScope.launch(Dispatchers.IO) {
            _webExportAccountSelectionPreviewFlow.emit(
                webExportAccountSelectionPreviewUseCase.getWebExportAccountSelectionPreview()
            )
        }
    }

    fun updatePreviewWithCheckBoxClickEvent(currentCheckBoxState: TriStatesCheckBox.CheckBoxState) {
        viewModelScope.launch {
            _webExportAccountSelectionPreviewFlow.emit(
                webExportAccountSelectionPreviewUseCase.updatePreviewWithCheckBoxClickEvent(
                    currentCheckBoxState = currentCheckBoxState,
                    previousState = _webExportAccountSelectionPreviewFlow.value
                )
            )
        }
    }

    fun updatePreviewWithAccountClicked(accountAddress: String) {
        viewModelScope.launch {
            _webExportAccountSelectionPreviewFlow.emit(
                webExportAccountSelectionPreviewUseCase.updatePreviewWithAccountClicked(
                    accountAddress = accountAddress,
                    previousState = _webExportAccountSelectionPreviewFlow.value
                )
            )
        }
    }

    fun getAllSelectedAccountAddressList(): List<String> {
        return webExportAccountSelectionPreviewUseCase.getAllSelectedAccountAddressList(
            _webExportAccountSelectionPreviewFlow.value
        )
    }

    fun getQRCodeData(): WebExportQrCode {
        return WebExportQrCode(backupId, modificationKey, encryptionKey)
    }

    private fun getInitialPreview(): WebExportAccountSelectionPreview {
        return webExportAccountSelectionPreviewUseCase.getInitialPreview()
    }
}
