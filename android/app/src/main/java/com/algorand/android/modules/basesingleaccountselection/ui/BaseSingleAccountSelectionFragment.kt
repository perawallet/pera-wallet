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

package com.algorand.android.modules.basesingleaccountselection.ui

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentBaseSingleAccountSelectionBinding
import com.algorand.android.models.ScreenState
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.basesingleaccountselection.ui.adapter.BaseSingleAccountSelectionAdapter
import com.algorand.android.modules.basesingleaccountselection.ui.model.SingleAccountSelectionListItem
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import kotlinx.coroutines.flow.map

abstract class BaseSingleAccountSelectionFragment : BaseFragment(R.layout.fragment_base_single_account_selection) {

    protected abstract val toolbarConfiguration: ToolbarConfiguration
    protected abstract val singleAccountSelectionViewModel: BaseSingleAccountSelectionViewModel

    private val binding by viewBinding(FragmentBaseSingleAccountSelectionBinding::bind)

    private val baseSingleAccountSelectionAdapterListener = object : BaseSingleAccountSelectionAdapter.Listener {
        override fun onAccountItemClick(accountAddress: String) {
            onAccountSelected(accountAddress)
        }

        override fun onAccountItemLongClick(accountAddress: String) {
            onAccountAddressCopied(accountAddress)
        }
    }

    private val loadingStateVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        binding.progressBar.root.isVisible = isVisible == true
    }

    private val baseSingleAccountSelectionAdapter = BaseSingleAccountSelectionAdapter(
        listener = baseSingleAccountSelectionAdapterListener
    )

    private val singleAccountSelectionListItemsCollector: suspend (
        List<SingleAccountSelectionListItem>?
    ) -> Unit = { accountSelectionItemList ->
        baseSingleAccountSelectionAdapter.submitList(accountSelectionItemList)
    }

    private val screenStateCollector: suspend (ScreenState?) -> Unit = { screenState ->
        setScreenStateViewVisibility(screenState != null)
        if (screenState != null) setScreenStateView(screenState)
    }

    abstract fun onAccountSelected(accountAddress: String)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
        initUi()
    }

    private fun initObservers() {
        with(singleAccountSelectionViewModel.singleAccountSelectionFieldsFlow) {
            collectLatestOnLifecycle(
                flow = map { it?.singleAccountSelectionListItems },
                collection = singleAccountSelectionListItemsCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.screenState },
                collection = screenStateCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.isLoading },
                collection = loadingStateVisibilityCollector
            )
        }
    }

    private fun initUi() {
        binding.accountsRecyclerView.adapter = baseSingleAccountSelectionAdapter
    }

    private fun setScreenStateViewVisibility(isVisible: Boolean) {
        binding.screenStateView.isVisible = isVisible
    }

    private fun setScreenStateView(screenState: ScreenState) {
        binding.screenStateView.setupUi(screenState)
    }
}
