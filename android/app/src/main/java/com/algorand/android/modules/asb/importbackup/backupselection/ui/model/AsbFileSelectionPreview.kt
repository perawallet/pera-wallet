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

package com.algorand.android.modules.asb.importbackup.backupselection.ui.model

import com.algorand.android.customviews.perafileuploadview.model.FileUploadState
import com.algorand.android.models.AnnotatedString
import com.algorand.android.utils.Event

data class AsbFileSelectionPreview(
    val isNextButtonEnabled: Boolean,
    val isPasteButtonVisible: Boolean,
    val fileUploadState: FileUploadState,
    val fileCipherText: String?,
    val openFileSelectorEvent: Event<Unit>?,
    val showGlobalErrorEvent: Event<Pair<AnnotatedString, AnnotatedString?>>?,
    val navToAsbEnterKeyFragmentEvent: Event<String>?,
    val showGlobalSuccessEvent: Event<Int>?
)
