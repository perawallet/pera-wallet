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

package com.algorand.android.modules.basefoundaccount.selection.ui

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentBaseFoundAccountSelectionBinding
import com.algorand.android.modules.basefoundaccount.selection.ui.adapter.FoundAccountSelectionAdapter
import com.algorand.android.modules.basefoundaccount.selection.ui.model.BaseFoundAccountSelectionItem
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import kotlinx.coroutines.flow.map

abstract class BaseFoundAccountSelectionFragment : BaseFragment(R.layout.fragment_base_found_account_selection) {

    protected abstract val baseFoundAccountSelectionViewModel: BaseFoundAccountSelectionViewModel

    protected val binding by viewBinding(FragmentBaseFoundAccountSelectionBinding::bind)

    private val foundAccountSelectionAdapterListener = object : FoundAccountSelectionAdapter.Listener {
        override fun onAccountItemClick(accountAddress: String) {
            onAccountSelected(accountAddress)
        }

        override fun onAccountItemInformationClick(accountAddress: String) {
            navToAccountInformationBottomSheet(accountAddress)
        }
    }

    private val foundAccountSelectionAdapter = FoundAccountSelectionAdapter(foundAccountSelectionAdapterListener)

    private val foundAccountSelectionListItemCollector: suspend (List<BaseFoundAccountSelectionItem>) -> Unit = {
        foundAccountSelectionAdapter.submitList(it)
    }

    private val loadingVisibilityCollector: suspend (Boolean) -> Unit = { isVisible ->
        binding.progressbar.root.isVisible = isVisible
    }

    abstract fun navToAccountInformationBottomSheet(accountAddress: String)
    abstract fun onAccountSelected(accountAddress: String)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    open fun initUi() {
        binding.foundAccountSelectionRecyclerView.adapter = foundAccountSelectionAdapter
    }

    open fun initObservers() {
        with(baseFoundAccountSelectionViewModel.foundAccountSelectionFieldsFlow) {
            collectLatestOnLifecycle(
                flow = map { it.foundAccountSelectionListItem },
                collection = foundAccountSelectionListItemCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.isLoading },
                collection = loadingVisibilityCollector
            )
        }
    }
}
