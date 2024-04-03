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

package com.algorand.android.ui.common.warningconfirmation.accountselection

import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.accountselection.BaseAccountSelectionFragment
import com.algorand.android.ui.common.warningconfirmation.accountselection.model.BackupAccountSelectionPreview
import com.algorand.android.utils.extensions.collectOnLifecycle
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class BackupAccountSelectionFragment : BaseAccountSelectionFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.select_account,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val backupAccountSelectionViewModel by viewModels<BackupAccountSelectionViewModel>()

    private val backupAccountSelectionPreviewCollector: suspend (BackupAccountSelectionPreview) -> Unit = {
        accountAdapter.submitList(it.accountSelectionListItems)
    }

    override fun onAccountSelected(publicKey: String) {
        nav(
            BackupAccountSelectionFragmentDirections
                .actionBackupAccountSelectionFragmentToBackupPassphraseNavigation(publicKey, accountCreation = null)
        )
    }

    override fun initObservers() {
        viewLifecycleOwner.collectOnLifecycle(
            backupAccountSelectionViewModel.backupAccountSelectionPreviewFlow,
            backupAccountSelectionPreviewCollector
        )
    }
}
