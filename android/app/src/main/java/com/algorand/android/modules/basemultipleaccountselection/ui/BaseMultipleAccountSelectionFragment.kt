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

package com.algorand.android.modules.basemultipleaccountselection.ui

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentBaseMultipleAccountSelectionBinding
import com.algorand.android.models.ScreenState
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.basemultipleaccountselection.ui.adapter.MultipleAccountSelectionAdapter
import com.algorand.android.modules.basemultipleaccountselection.ui.model.MultipleAccountSelectionListItem
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
abstract class BaseMultipleAccountSelectionFragment : BaseFragment(R.layout.fragment_base_multiple_account_selection) {

    protected abstract val toolbarConfiguration: ToolbarConfiguration
    protected abstract val multipleAccountSelectionViewModel: BaseMultipleAccountSelectionViewModel
    protected abstract val multipleAccountSelectionAdapter: MultipleAccountSelectionAdapter

    private val binding by viewBinding(FragmentBaseMultipleAccountSelectionBinding::bind)

    protected val multipleAccountSelectionAdapterListener = object : MultipleAccountSelectionAdapter.Listener {
        override fun onHeaderCheckBoxClicked() {
            onHeaderCheckBoxClick()
        }

        override fun onAccountCheckboxClicked(accountAddress: String) {
            onAccountCheckBoxClick(accountAddress)
        }

        override fun onAccountLongPressed(accountAddress: String) {
            onAccountLongPress(accountAddress)
        }
    }

    private val actionButtonStateCollector: suspend (Boolean) -> Unit = {
        binding.primaryActionButton.isEnabled = it
    }

    private val actionButtonTextPairCollector: suspend (Pair<Int, Int>) -> Unit = { (pluralResId, count) ->
        binding.primaryActionButton.text = resources.getString(pluralResId, count)
    }

    private val loadingStateCollector: suspend (Boolean) -> Unit = {
        binding.progressBarLayout.root.isVisible = it
    }

    private val multipleAccountSelectionListCollector: suspend (List<MultipleAccountSelectionListItem>) -> Unit = {
        multipleAccountSelectionAdapter.submitList(it)
    }

    private val emptyScreenStateCollector: suspend (ScreenState?) -> Unit = { emptyScreenState ->
        updateScreenStateViewAsEmptyState(emptyScreenState)
    }

    abstract fun onHeaderCheckBoxClick()
    abstract fun onAccountCheckBoxClick(accountAddress: String)
    abstract fun onAccountLongPress(accountAddress: String)
    abstract fun onActionButtonClick()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
        initUi()
    }

    protected fun setEmptyStateActionButtonClick(action: () -> Unit) {
        binding.screenStateView.setOnNeutralButtonClickListener { action() }
    }

    private fun initUi() {
        with(binding) {
            accountsRecyclerView.adapter = multipleAccountSelectionAdapter
            primaryActionButton.setOnClickListener { onActionButtonClick() }
        }
    }

    open fun initObservers() {
        with(multipleAccountSelectionViewModel.multipleAccountSelectionPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it.isLoadingVisible },
                collection = loadingStateCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.multipleAccountSelectionList },
                collection = multipleAccountSelectionListCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.actionButtonTextResId to it.checkedAccountCount },
                collection = actionButtonTextPairCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.isActionButtonEnabled },
                collection = actionButtonStateCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.emptyScreenState },
                collection = emptyScreenStateCollector
            )
        }
    }

    private fun updateScreenStateViewAsEmptyState(screenState: ScreenState?) {
        binding.screenStateView.apply {
            isVisible = screenState != null
            setupUi(screenState ?: return)
        }
    }
}
