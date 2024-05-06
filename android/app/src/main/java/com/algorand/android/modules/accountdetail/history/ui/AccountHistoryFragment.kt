/*
 * Copyright 2022 Pera Wallet, LDA
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.modules.accountdetail.history.ui

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.paging.CombinedLoadStates
import androidx.paging.PagingData
import androidx.recyclerview.widget.ConcatAdapter
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAccountHistoryBinding
import com.algorand.android.models.DateFilter
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ui.DateFilterPreview
import com.algorand.android.models.ui.TransactionLoadStatePreview
import com.algorand.android.modules.transaction.csv.ui.model.CsvStatusPreview
import com.algorand.android.modules.transactionhistory.ui.AccountHistoryAdapter
import com.algorand.android.modules.transactionhistory.ui.PendingTransactionAdapter
import com.algorand.android.modules.transactionhistory.ui.StickyAccountHistoryHeaderDecoration
import com.algorand.android.modules.transactionhistory.ui.model.BaseTransactionItem
import com.algorand.android.ui.datepicker.DateFilterListBottomSheet
import com.algorand.android.utils.CSV_FILE_MIME_TYPE
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.scrollToTop
import com.algorand.android.utils.shareFile
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class AccountHistoryFragment : BaseFragment(R.layout.fragment_account_history) {

    override val fragmentConfiguration = FragmentConfiguration()

    private val binding by viewBinding(FragmentAccountHistoryBinding::bind)

    private val accountHistoryViewModel: AccountHistoryViewModel by viewModels()

    private var listener: Listener? = null

    private val transactionListener = object : AccountHistoryAdapter.Listener {
        override fun onStandardTransactionClick(transaction: BaseTransactionItem.TransactionItem) {
            listener?.onStandardTransactionClick(transaction)
        }

        override fun onApplicationCallTransactionClick(
            transaction: BaseTransactionItem.TransactionItem.ApplicationCallItem
        ) {
            listener?.onApplicationCallTransactionClick(transaction)
        }
    }

    private val pendingTransactionListener = object : PendingTransactionAdapter.Listener {
        override fun onTransactionClick(transaction: BaseTransactionItem.TransactionItem) {
            listener?.onStandardTransactionClick(transaction)
        }

        override fun onNewPendingItemInserted() {
            view?.let {
                binding.accountHistoryRecyclerView.scrollToTop()
            }
        }
    }

    private val accountHistoryAdapter = AccountHistoryAdapter(transactionListener)
    private val pendingTransactionAdapter = PendingTransactionAdapter(pendingTransactionListener)
    private val concatAdapter = ConcatAdapter(pendingTransactionAdapter, accountHistoryAdapter)

    private val pendingTransactionCollector: suspend (List<BaseTransactionItem>?) -> Unit = {
        pendingTransactionAdapter.submitList(it)
    }

    private val transactionHistoryCollector: suspend (PagingData<BaseTransactionItem>) -> Unit = {
        accountHistoryAdapter.submitData(it)
    }

    private val dateFilterPreviewCollector: suspend (DateFilterPreview) -> Unit = {
        setTransactionToolbarUi(it)
    }

    private val csvStatusPreviewCollector: suspend (CsvStatusPreview?) -> Unit = {
        updateCsvStatusPreview(it)
    }

    private val loadStateFlowCollector: suspend (CombinedLoadStates) -> Unit = { combinedLoadStates ->
        updateUiWithTransactionLoadStatePreview(
            accountHistoryViewModel.createTransactionLoadStatePreview(
                combinedLoadStates,
                concatAdapter.itemCount,
                binding.screenStateView.isVisible
            )
        )
    }

    private val sharingActivityResultLauncher =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) {
            // Nothing to do
        }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = parentFragment as? Listener
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObserver()
        handleLoadState()
    }

    override fun onResume() {
        super.onResume()
        initSavedStateListener()
        accountHistoryViewModel.activatePendingTransaction()
    }

    override fun onPause() {
        super.onPause()
        accountHistoryViewModel.deactivatePendingTransaction()
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.accountDetailFragment) {
            useSavedStateValue<DateFilter>(DateFilterListBottomSheet.DATE_FILTER_RESULT) { newDateFilter ->
                accountHistoryViewModel.setDateFilter(newDateFilter)
            }
        }
    }

    private fun initUi() {
        with(binding) {
            accountHistoryRecyclerView.apply {
                adapter = concatAdapter
                addItemDecoration(
                    StickyAccountHistoryHeaderDecoration(
                        accountHistoryAdapter = accountHistoryAdapter,
                        pendingTransactionAdapter = pendingTransactionAdapter,
                        context = context
                    )
                )
            }
            transactionHistoryToolbar.apply {
                setPrimaryButtonClickListener(::onFilterClick)
                setSecondaryButtonClickListener(::onExportClick)
            }
            screenStateView.setOnNeutralButtonClickListener { accountHistoryViewModel.refreshTransactionHistory() }
        }
    }

    private fun initObserver() {
        with(accountHistoryViewModel) {
            viewLifecycleOwner.collectLatestOnLifecycle(
                getAccountHistoryFlow(),
                transactionHistoryCollector
            )
            viewLifecycleOwner.collectLatestOnLifecycle(
                pendingTransactionsFlow,
                pendingTransactionCollector
            )
            viewLifecycleOwner.collectLatestOnLifecycle(
                dateFilterPreviewFlow,
                dateFilterPreviewCollector
            )
            viewLifecycleOwner.collectOnLifecycle(
                accountHistoryViewModel.csvStatusPreview,
                csvStatusPreviewCollector
            )
        }
    }

    private fun handleLoadState() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            accountHistoryAdapter.loadStateFlow,
            loadStateFlowCollector
        )
    }

    private fun updateUiWithTransactionLoadStatePreview(loadStatePreview: TransactionLoadStatePreview) {
        with(binding) {
            screenStateView.isVisible = loadStatePreview.isScreenStateViewVisible
            loadStatePreview.screenStateViewType?.let { screenStateView.setupUi(it) }
            accountHistoryRecyclerView.isVisible = loadStatePreview.isTransactionListVisible
            loadingLayout.root.isVisible = loadStatePreview.isLoading
        }
    }

    private fun onFilterClick() {
        accountHistoryViewModel.logAccountHistoryFilterEventTracker()
        val currentFilter = accountHistoryViewModel.getDateFilterValue()
        listener?.onFilterTransactionClick(currentFilter)
    }

    private fun onExportClick() {
        accountHistoryViewModel.logAccountHistoryExportCsvEventTracker()
        context?.cacheDir?.let { cacheDirectory ->
            accountHistoryViewModel.createCsvFile(cacheDirectory)
        }
    }

    private fun updateCsvStatusPreview(csvStatusPreview: CsvStatusPreview?) {
        if (csvStatusPreview == null) return
        if (csvStatusPreview.isErrorShown) {
            showGlobalError(csvStatusPreview.errorResource.parse(binding.root.context))
        }
        with(binding.csvProgressBar) {
            descriptionTextView.setText(csvStatusPreview.descriptionResId)
            root.isVisible = csvStatusPreview.isCsvProgressBarVisible
        }
        csvStatusPreview.csvFile?.consume()?.let { csvFile ->
            shareFile(csvFile, CSV_FILE_MIME_TYPE, sharingActivityResultLauncher)
        }
    }

    private fun setTransactionToolbarUi(dateFilterPreview: DateFilterPreview) {
        with(dateFilterPreview) {
            with(binding) {
                transactionHistoryToolbar.apply {
                    setPrimaryButtonIcon(icon = filterButtonIconResId, useIconsOwnTint = useFilterIconsOwnTint)
                    if (titleResId != null) setTitle(titleResId) else if (title != null) setTitle(title)
                }
            }
        }
    }

    interface Listener {
        fun onStandardTransactionClick(transaction: BaseTransactionItem.TransactionItem)
        fun onApplicationCallTransactionClick(transaction: BaseTransactionItem.TransactionItem.ApplicationCallItem)
        fun onFilterTransactionClick(dateFilter: DateFilter)
    }

    companion object {
        fun newInstance(publicKey: String): AccountHistoryFragment {
            return AccountHistoryFragment().apply {
                arguments = Bundle().apply {
                    putString(AccountHistoryViewModel.PUBLIC_KEY, publicKey)
                }
            }
        }
    }
}
