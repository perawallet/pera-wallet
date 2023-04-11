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

package com.algorand.android.modules.asb.importbackup.accountrestoreresult.ui

import androidx.lifecycle.SavedStateHandle
import com.algorand.android.modules.asb.importbackup.accountrestoreresult.ui.model.AsbAccountRestoreResultPreview
import com.algorand.android.modules.asb.importbackup.accountrestoreresult.ui.usecase.AsbAccountRestoreResultPreviewUseCase
import com.algorand.android.modules.asb.importbackup.accountselection.ui.model.AsbAccountImportResult
import com.algorand.android.modules.baseresult.ui.BaseResultViewModel
import com.algorand.android.modules.baseresult.ui.model.BaseResultPreviewFields
import com.algorand.android.utils.getOrThrow
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

@HiltViewModel
class AsbAccountRestoreResultViewModel @Inject constructor(
    private val asbAccountRestoreResultPreviewUseCase: AsbAccountRestoreResultPreviewUseCase,
    savedStateHandle: SavedStateHandle
) : BaseResultViewModel() {

    private val asbAccountImportResult = savedStateHandle.getOrThrow<AsbAccountImportResult>(
        ASB_ACCOUNT_IMPORT_RESULT_KEY
    )

    private val asbAccountRestoreResultFlow = MutableStateFlow(getInitialPreview())
    override val baseResultPreviewFlow: StateFlow<BaseResultPreviewFields> get() = asbAccountRestoreResultFlow

    private fun getInitialPreview(): AsbAccountRestoreResultPreview {
        return asbAccountRestoreResultPreviewUseCase.getAsbAccountRestoreResultPreview(asbAccountImportResult)
    }

    companion object {
        private const val ASB_ACCOUNT_IMPORT_RESULT_KEY = "asbAccountImportResult"
    }
}
