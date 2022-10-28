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

package com.algorand.android.modules.sorting.accountsorting.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.ConcatAdapter
import androidx.recyclerview.widget.ItemTouchHelper
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAccountSortBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.TextButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.modules.sorting.accountsorting.domain.model.AccountSortingType
import com.algorand.android.modules.sorting.accountsorting.domain.model.BaseAccountSortingListItem
import com.algorand.android.modules.sorting.accountsorting.ui.adapter.AccountSortAdapter
import com.algorand.android.modules.sorting.accountsorting.ui.adapter.SortTypeAdapter
import com.algorand.android.modules.sorting.accountsorting.util.AccountSortItemTouchHelper
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class AccountSortFragment : BaseFragment(R.layout.fragment_account_sort) {

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.sort,
        startIconResId = R.drawable.ic_close,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val binding by viewBinding(FragmentAccountSortBinding::bind)

    private val accountSortViewModel: AccountSortViewModel by viewModels()

    private val onItemMoveListener = AccountSortItemTouchHelper.ItemMoveListener { fromPosition, toPosition ->
        onItemMoved(fromPosition, toPosition)
    }

    private val sortItemTouchHelper = AccountSortItemTouchHelper(onItemMoveListener)

    private val dragDropItemTouchHelper = ItemTouchHelper(sortItemTouchHelper)

    private val accountSortAdapterListener = AccountSortAdapter.AccountSortAdapterListener { viewHolder ->
        dragDropItemTouchHelper.startDrag(viewHolder)
    }

    private val sortTypeAdapterListener = SortTypeAdapter.SortTypeAdapterListener { sortingType ->
        onNewSortPreferencesSelected(sortingType)
    }

    private val sortTypeListItemsCollector: suspend (List<BaseAccountSortingListItem.SortTypeListItem>) -> Unit = {
        sortTypeAdapter.submitList(it)
    }

    private val accountSortingListItemsCollector: suspend (List<BaseAccountSortingListItem>) -> Unit = {
        accountSortAdapter.submitList(it)
    }

    private val accountSortAdapter = AccountSortAdapter(accountSortAdapterListener)
    private val sortTypeAdapter = SortTypeAdapter(sortTypeAdapterListener)
    private val concatAdapter = ConcatAdapter(sortTypeAdapter, accountSortAdapter)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        getAppToolbar()?.setEndButton(button = TextButton(R.string.done, onClick = ::onDoneClick))
        binding.accountRecyclerView.apply {
            adapter = concatAdapter
            dragDropItemTouchHelper.attachToRecyclerView(this)
        }
    }

    private fun initObservers() {
        with(accountSortViewModel) {
            with(viewLifecycleOwner.lifecycleScope) {
                launchWhenResumed {
                    accountSortingPreviewFlow.map { it.sortTypeListItems }
                        .distinctUntilChanged()
                        .collectLatest(sortTypeListItemsCollector)
                }
                launchWhenResumed {
                    accountSortingPreviewFlow.map { it.accountSortingListItems }
                        .distinctUntilChanged()
                        .collectLatest(accountSortingListItemsCollector)
                }
            }
        }
    }

    private fun saveSortedList(accountListAccount: List<BaseAccountSortingListItem>) {
        accountSortViewModel.saveSortedAccountListIfSortedManually(accountListAccount)
    }

    private fun saveSortingPreferences() {
        accountSortViewModel.saveSortingPreferences()
    }

    private fun onItemMoved(fromPosition: Int, toPosition: Int) {
        accountSortViewModel.onAccountItemMoved(fromPosition, toPosition)
    }

    private fun onDoneClick() {
        saveSortedList(accountSortAdapter.currentList)
        saveSortingPreferences()
        navBack()
    }

    private fun onNewSortPreferencesSelected(accountSortingType: AccountSortingType) {
        accountSortViewModel.onSortingPreferencesSelected(accountSortingType)
    }
}
