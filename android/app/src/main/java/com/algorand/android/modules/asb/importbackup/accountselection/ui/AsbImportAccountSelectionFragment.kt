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

package com.algorand.android.modules.asb.importbackup.accountselection.ui

import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.asb.importbackup.accountselection.ui.model.AsbAccountImportResult
import com.algorand.android.modules.basemultipleaccountselection.ui.BaseMultipleAccountSelectionFragment
import com.algorand.android.modules.basemultipleaccountselection.ui.BaseMultipleAccountSelectionViewModel
import com.algorand.android.modules.basemultipleaccountselection.ui.adapter.MultipleAccountSelectionAdapter
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import kotlinx.coroutines.flow.map

class AsbImportAccountSelectionFragment : BaseMultipleAccountSelectionFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_left_arrow
    )
    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)
    override val multipleAccountSelectionAdapter = MultipleAccountSelectionAdapter(
        listener = multipleAccountSelectionAdapterListener
    )
    override val multipleAccountSelectionViewModel: BaseMultipleAccountSelectionViewModel
        get() = asbImportAccountSelectionViewModel

    private val asbImportAccountSelectionViewModel by viewModels<AsbImportAccountSelectionViewModel>()

    private val navToRestoreCompleteEventCollector: suspend (Event<AsbAccountImportResult>?) -> Unit = { event ->
        event?.consume()?.run { navToRestoreCompleteFragment(this) }
    }

    override fun onHeaderCheckBoxClick() {
        asbImportAccountSelectionViewModel.onHeaderCheckBoxClick()
    }

    override fun onAccountCheckBoxClick(accountAddress: String) {
        asbImportAccountSelectionViewModel.onAccountCheckBoxClick(accountAddress)
    }

    override fun onActionButtonClick() {
        asbImportAccountSelectionViewModel.onRestoreClick()
    }

    override fun onAccountLongPress(accountAddress: String) {
        onAccountAddressCopied(accountAddress)
    }

    override fun initObservers() {
        super.initObservers()
        with(asbImportAccountSelectionViewModel.multipleAccountSelectionPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it.navToRestoreCompleteEvent },
                collection = navToRestoreCompleteEventCollector
            )
        }
    }

    private fun navToRestoreCompleteFragment(asbAccountImportResult: AsbAccountImportResult) {
        nav(
            AsbImportAccountSelectionFragmentDirections
                .actionAsbImportAccountSelectionFragmentToAsbAccountRestoreResultFragment(asbAccountImportResult)
        )
    }
}
