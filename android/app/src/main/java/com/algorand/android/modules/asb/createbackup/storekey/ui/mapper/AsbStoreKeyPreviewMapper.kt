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

package com.algorand.android.modules.asb.createbackup.storekey.ui.mapper

import com.algorand.android.models.AnnotatedString
import com.algorand.android.modules.asb.createbackup.storekey.ui.model.AsbStoreKeyPreview
import com.algorand.android.utils.Event
import javax.inject.Inject

class AsbStoreKeyPreviewMapper @Inject constructor() {

    @SuppressWarnings("LongParameterList")
    fun mapToAsbStoreKeyPreview(
        titleTextResId: Int,
        descriptionAnnotatedString: AnnotatedString,
        isCreateNewKeyButtonVisible: Boolean,
        mnemonics: List<String>,
        navToCreateBackupConfirmationEvent: Event<Unit>? = null,
        navToBackupReadyEvent: Event<String>? = null,
        navToCreateNewKeyConfirmationEvent: Event<Unit>? = null,
        openUrlEvent: Event<String>? = null,
        showGlobalErrorEvent: Event<Int>? = null,
        onKeyCopiedEvent: Event<String>? = null,
        navToFailureScreenEvent: Event<Unit>? = null
    ): AsbStoreKeyPreview {
        return AsbStoreKeyPreview(
            titleTextResId = titleTextResId,
            descriptionAnnotatedString = descriptionAnnotatedString,
            isCreateNewKeyButtonVisible = isCreateNewKeyButtonVisible,
            mnemonics = mnemonics,
            navToCreateBackupConfirmationEvent = navToCreateBackupConfirmationEvent,
            navToBackupReadyEvent = navToBackupReadyEvent,
            navToCreateNewKeyConfirmationEvent = navToCreateNewKeyConfirmationEvent,
            openUrlEvent = openUrlEvent,
            showGlobalErrorEvent = showGlobalErrorEvent,
            onKeyCopiedEvent = onKeyCopiedEvent,
            navToFailureScreenEvent = navToFailureScreenEvent
        )
    }
}
