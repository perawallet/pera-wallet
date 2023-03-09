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

package com.algorand.android.modules.webimport.result.ui

import androidx.lifecycle.SavedStateHandle
import com.algorand.android.core.BaseViewModel
import com.algorand.android.modules.webimport.result.ui.model.WebImportResultPreview
import com.algorand.android.modules.webimport.result.ui.usecase.WebImportResultPreviewUseCase
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

@HiltViewModel
class WebImportResultViewModel @Inject constructor(
    private val webImportResultPreviewUseCase: WebImportResultPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseViewModel() {

    private val importedAccountList = savedStateHandle
        .getOrThrow<Array<String>>(NAVIGATION_IMPORTED_ACCOUNT_LIST_KEY).toList()
    private val unimportedAccountList = savedStateHandle
        .getOrThrow<Array<String>>(NAVIGATION_UNIMPORTED_ACCOUNT_LIST_KEY).toList()

    val webImportResultPreviewFlow: StateFlow<WebImportResultPreview>
        get() = _webImportResultPreviewFlow
    private val _webImportResultPreviewFlow = MutableStateFlow(getInitialPreview())

    private fun getInitialPreview(): WebImportResultPreview {
        return webImportResultPreviewUseCase.getInitialPreview(
            importedAccountList = importedAccountList,
            unimportedAccountList = unimportedAccountList
        )
    }

    companion object {
        private const val NAVIGATION_IMPORTED_ACCOUNT_LIST_KEY = "importedAccountList"
        private const val NAVIGATION_UNIMPORTED_ACCOUNT_LIST_KEY = "unimportedAccountList"
    }
}
