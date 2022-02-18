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

package com.algorand.android.ui.accountorder

import android.os.Bundle
import android.view.View
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.ItemTouchHelper
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAccountOrderBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.ui.AccountOrderItem
import com.algorand.android.ui.accountorder.AccountOrderItemTouchHelper.ItemMoveListener
import com.algorand.android.utils.viewbinding.viewBinding
import kotlinx.coroutines.flow.collect

abstract class BaseAccountOrderFragment : BaseFragment(R.layout.fragment_account_order) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.arrange_list,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding: FragmentAccountOrderBinding by viewBinding(FragmentAccountOrderBinding::bind)

    abstract val accountOrderViewModel: BaseAccountOrderViewModel

    private val onItemMoveListener: ItemMoveListener = ItemMoveListener { fromPosition, toPosition ->
        onAccountItemMoved(fromPosition, toPosition)
    }

    private val dragDropItemTouchHelper = ItemTouchHelper(AccountOrderItemTouchHelper(onItemMoveListener))

    private val dragDropListener = AccountOrderItemViewHolder.DragButtonPressedListener { viewHolder ->
        dragDropItemTouchHelper.startDrag(viewHolder)
    }

    private val accountListFlowCollector: suspend (List<AccountOrderItem>) -> Unit = { accountOrderItemList ->
        accountOrderAdapter.submitList(accountOrderItemList)
    }

    private val accountOrderAdapter = AccountOrderAdapter(dragDropListener)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        getAppToolbar()?.addButtonToEnd(TextButton(R.string.done, onClick = ::onDoneClick))
        binding.accountRecyclerView.apply {
            adapter = accountOrderAdapter
            dragDropItemTouchHelper.attachToRecyclerView(this)
        }
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launchWhenResumed {
            accountOrderViewModel.accountListFlow.collect(accountListFlowCollector)
        }
    }

    private fun saveAccounts(accountList: List<AccountOrderItem>) {
        accountOrderViewModel.saveAccounts(accountList)
    }

    private fun onAccountItemMoved(fromPosition: Int, toPosition: Int) {
        accountOrderViewModel.onAccountItemMoved(fromPosition, toPosition)
    }

    private fun onDoneClick() {
        saveAccounts(accountOrderAdapter.currentList)
        navBack()
    }
}
