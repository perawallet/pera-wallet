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

package com.algorand.android.ui.accountselection

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentBaseAccountSelectionBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.common.listhelper.BaseAccountListItem
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.extensions.show
import com.algorand.android.utils.viewbinding.viewBinding
import kotlinx.coroutines.flow.collect

abstract class BaseAccountSelectionFragment : BaseFragment(R.layout.fragment_base_account_selection) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.select_account,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentBaseAccountSelectionBinding::bind)

    private val baseAccountSelectionViewModel by viewModels<BaseAccountSelectionViewModel>()

    private val accountItemsCollector: suspend (List<BaseAccountListItem.BaseAccountItem>) -> Unit = { accountItems ->
        accountAdapter.submitList(accountItems)
    }

    protected abstract fun onAccountSelected(publicKey: String)

    private val accountAdapter = AccountSelectionAdapter(::onAccountSelected)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        binding.accountsRecyclerView.adapter = accountAdapter
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launchWhenStarted {
            baseAccountSelectionViewModel.accountItemsFlow.collect(accountItemsCollector)
        }
    }

    protected fun showProgress() {
        binding.progressBar.root.show()
    }

    protected fun hideProgress() {
        binding.progressBar.root.hide()
    }
}
