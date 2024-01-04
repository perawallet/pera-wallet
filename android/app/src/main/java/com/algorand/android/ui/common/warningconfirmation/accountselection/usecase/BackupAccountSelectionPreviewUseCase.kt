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

package com.algorand.android.ui.common.warningconfirmation.accountselection.usecase

import com.algorand.android.ui.common.warningconfirmation.accountselection.mapper.BackupAccountSelectionPreviewMapper
import com.algorand.android.ui.common.warningconfirmation.accountselection.model.BackupAccountSelectionPreview
import com.algorand.android.usecase.AccountSelectionListUseCase
import javax.inject.Inject

class BackupAccountSelectionPreviewUseCase @Inject constructor(
    private val accountSelectionListUseCase: AccountSelectionListUseCase,
    private val backupAccountSelectionPreviewMapper: BackupAccountSelectionPreviewMapper
) {

    fun getInitialStatePreview() = backupAccountSelectionPreviewMapper.mapToBackupAccountSelectionPreview(emptyList())

    suspend fun getBackupAccountSelectionPreview(): BackupAccountSelectionPreview {
        val accountSelectionListItems = accountSelectionListUseCase
            .createAccountSelectionListAccountItemsWhichNotBackedUp(
                showHoldings = true,
                showFailedAccounts = true
            )
        return backupAccountSelectionPreviewMapper.mapToBackupAccountSelectionPreview(accountSelectionListItems)
    }
}
