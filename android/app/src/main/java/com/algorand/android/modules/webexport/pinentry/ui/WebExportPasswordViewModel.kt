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

package com.algorand.android.modules.webexport.pinentry.ui

import androidx.lifecycle.SavedStateHandle
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.webexport.utils.NAVIGATION_ACCOUNT_LIST_KEY
import com.algorand.android.modules.webexport.utils.NAVIGATION_BACKUP_ID_KEY
import com.algorand.android.modules.webexport.utils.NAVIGATION_ENCRYPTION_KEY
import com.algorand.android.modules.webexport.utils.NAVIGATION_MODIFICATION_KEY
import com.algorand.android.utils.getOrThrow
import com.algorand.android.modules.webexport.pinentry.ui.model.WebExportPasswordPreview
import com.algorand.android.modules.webexport.pinentry.ui.usecase.WebExportPasswordPreviewUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import javax.inject.Inject

@HiltViewModel
class WebExportPasswordViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val webExportPasswordPreviewUseCase: WebExportPasswordPreviewUseCase
) : BaseViewModel() {

    val backupId = savedStateHandle.getOrThrow<String>(NAVIGATION_BACKUP_ID_KEY)
    val modificationKey = savedStateHandle.getOrThrow<String>(NAVIGATION_MODIFICATION_KEY)
    val encryptionKey = savedStateHandle.getOrThrow<String>(NAVIGATION_ENCRYPTION_KEY)
    val accountList = savedStateHandle.getOrThrow<Array<String>>(NAVIGATION_ACCOUNT_LIST_KEY)

    val webExportPasswordPreviewFlow: StateFlow<WebExportPasswordPreview>
        get() = _webExportPasswordPreviewFlow
    private val _webExportPasswordPreviewFlow = MutableStateFlow(getInitialPreview())

    private fun getInitialPreview(): WebExportPasswordPreview {
        return webExportPasswordPreviewUseCase.getInitialPreview()
    }
}
