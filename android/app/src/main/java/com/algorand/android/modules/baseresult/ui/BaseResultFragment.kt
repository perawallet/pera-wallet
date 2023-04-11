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

package com.algorand.android.modules.baseresult.ui

import android.os.Bundle
import android.view.View
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentBaseResultBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.baseresult.ui.adapter.BaseResultAdapter
import com.algorand.android.modules.baseresult.ui.model.ResultListItem
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import kotlinx.coroutines.flow.map

abstract class BaseResultFragment : BaseFragment(R.layout.fragment_base_result) {

    abstract val toolbarConfiguration: ToolbarConfiguration
    abstract val baseResultViewModel: BaseResultViewModel
    abstract val baseResultAdapter: BaseResultAdapter

    protected val binding by viewBinding(FragmentBaseResultBinding::bind)

    protected val accountItemListener = BaseResultAdapter.AccountItemListener { accountAddress ->
        onAccountAddressCopied(accountAddress)
    }

    private val resultListItemsCollector: suspend (List<ResultListItem>) -> Unit = { itemList ->
        baseResultAdapter.submitList(itemList)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    open fun initUi() {
        binding.resultItemRecyclerView.adapter = baseResultAdapter
    }

    open fun initObservers() {
        with(baseResultViewModel.baseResultPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it.resultListItems },
                collection = resultListItemsCollector
            )
        }
    }
}
