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

package com.algorand.android.modules.asb.importbackup.accountselection.ui.mapper

import com.algorand.android.models.ScreenState
import com.algorand.android.modules.asb.importbackup.accountselection.ui.model.AsbAccountImportResult
import com.algorand.android.modules.asb.importbackup.accountselection.ui.model.AsbImportAccountSelectionPreview
import com.algorand.android.modules.backupprotocol.model.BackupProtocolElement
import com.algorand.android.modules.basemultipleaccountselection.ui.model.MultipleAccountSelectionListItem
import com.algorand.android.utils.Event
import javax.inject.Inject

class AsbImportAccountSelectionPreviewMapper @Inject constructor() {

    fun mapToAsbImportAccountSelectionPreview(
        multipleAccountSelectionList: List<MultipleAccountSelectionListItem>,
        isActionButtonEnabled: Boolean,
        actionButtonTextResId: Int,
        checkedAccountCount: Int,
        isLoadingVisible: Boolean,
        unsupportedAccounts: List<BackupProtocolElement>?,
        emptyScreenState: ScreenState? = null,
        navToRestoreCompleteEvent: Event<AsbAccountImportResult>? = null
    ): AsbImportAccountSelectionPreview {
        return AsbImportAccountSelectionPreview(
            multipleAccountSelectionList = multipleAccountSelectionList,
            isActionButtonEnabled = isActionButtonEnabled,
            actionButtonTextResId = actionButtonTextResId,
            checkedAccountCount = checkedAccountCount,
            isLoadingVisible = isLoadingVisible,
            unsupportedAccounts = unsupportedAccounts,
            emptyScreenState = emptyScreenState,
            navToRestoreCompleteEvent = navToRestoreCompleteEvent
        )
    }
}
