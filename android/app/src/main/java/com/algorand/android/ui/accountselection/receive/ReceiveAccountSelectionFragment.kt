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

package com.algorand.android.ui.accountselection.receive

import android.content.Context
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.models.BaseAccountSelectionListItem
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.accountselection.BaseAccountSelectionFragment
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest

@AndroidEntryPoint
class ReceiveAccountSelectionFragment : BaseAccountSelectionFragment() {

    override val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.select_account,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val receiveAccountSelectionViewModel by viewModels<ReceiveAccountSelectionViewModel>()

    private var listener: ReceiveAccountSelectionFragmentListener? = null

    private val accountItemsCollector: suspend (List<BaseAccountSelectionListItem>) -> Unit = { accountItems ->
        accountAdapter.submitList(accountItems)
    }

    override fun onAccountSelected(publicKey: String) {
        navBack()
        listener?.onAccountSelected(publicKey)
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = activity as? ReceiveAccountSelectionFragmentListener
    }

    override fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launchWhenStarted {
            receiveAccountSelectionViewModel.accountItemsFlow.collectLatest(accountItemsCollector)
        }
    }

    interface ReceiveAccountSelectionFragmentListener {
        fun onAccountSelected(publicKey: String)
    }
}
