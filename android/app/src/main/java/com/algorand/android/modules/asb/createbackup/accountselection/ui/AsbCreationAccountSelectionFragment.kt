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

package com.algorand.android.modules.asb.createbackup.accountselection.ui

import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.basemultipleaccountselection.ui.BaseMultipleAccountSelectionFragment
import com.algorand.android.modules.basemultipleaccountselection.ui.BaseMultipleAccountSelectionViewModel
import com.algorand.android.modules.basemultipleaccountselection.ui.adapter.MultipleAccountSelectionAdapter
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class AsbCreationAccountSelectionFragment : BaseMultipleAccountSelectionFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    override val multipleAccountSelectionAdapter = MultipleAccountSelectionAdapter(
        listener = multipleAccountSelectionAdapterListener
    )

    override val multipleAccountSelectionViewModel: BaseMultipleAccountSelectionViewModel
        get() = asbCreationAccountSelectionViewModel

    private val asbCreationAccountSelectionViewModel by viewModels<AsbCreationAccountSelectionViewModel>()

    private val navToStoreKeyEventCollector: suspend (Event<List<String>>?) -> Unit = { event ->
        event?.consume()?.run { navToStoreKey(this) }
    }

    override fun initObservers() {
        super.initObservers()
        with(asbCreationAccountSelectionViewModel.multipleAccountSelectionPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it.navToStoreKeyEvent },
                collection = navToStoreKeyEventCollector
            )
        }
    }

    override fun onHeaderCheckBoxClick() {
        asbCreationAccountSelectionViewModel.onHeaderCheckBoxClick()
    }

    override fun onAccountCheckBoxClick(accountAddress: String) {
        asbCreationAccountSelectionViewModel.onAccountCheckBoxClick(accountAddress)
    }

    override fun onAccountLongPress(accountAddress: String) {
        onAccountAddressCopied(accountAddress)
    }

    override fun onActionButtonClick() {
        asbCreationAccountSelectionViewModel.onBackupAccountClick()
    }

    private fun navToStoreKey(accountList: List<String>) {
        nav(
            AsbCreationAccountSelectionFragmentDirections
                .actionAsbCreationAccountSelectionFragmentToAsbStoreKeyFragment(
                    accountList = accountList.toTypedArray()
                )
        )
    }
}
