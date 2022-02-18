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

package com.algorand.android.ui.accountdetail.history

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.paging.PagingData
import androidx.recyclerview.widget.ConcatAdapter
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAccountHistoryBinding
import com.algorand.android.models.BaseTransactionItem
import com.algorand.android.models.CsvStatusPreview
import com.algorand.android.models.DateFilter
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ui.DateFilterPreview
import com.algorand.android.models.ui.TransactionLoadStatePreview
import com.algorand.android.ui.accountdetail.history.adapter.AccountHistoryAdapter
import com.algorand.android.ui.accountdetail.history.adapter.PendingTransactionAdapter
import com.algorand.android.ui.datepicker.DateFilterListBottomSheet
import com.algorand.android.utils.CSV_FILE_MIME_TYPE
import com.algorand.android.utils.shareFile
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class AccountHistoryFragment : BaseFragment(R.layout.fragment_account_history) {

    override val fragmentConfiguration = FragmentConfiguration()

    private val binding by viewBinding(FragmentAccountHistoryBinding::bind)

    private val accountHistoryViewModel: AccountHistoryViewModel by viewModels()

    private var listener: Listener? = null

    private val transactionListener = object : AccountHistoryAdapter.Listener {
        override fun onTransactionClick(transaction: BaseTransactionItem.TransactionItem) {
            listener?.onTransactionClick(transaction)
        }
    }

    private val pendingTransactionListener = object : PendingTransactionAdapter.Listener {
        override fun onTransactionClick(transaction: BaseTransactionItem.TransactionItem) {
            listener?.onTransactionClick(transaction)
        }

        override fun onNewPendingItemInserted() {
            binding.accountHistoryRecyclerView.scrollToPosition(0)
        }
    }

    private val publicKey by lazy { arguments?.getString(PUBLIC_KEY, "").orEmpty() }

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
        accountHistoryViewModel.startAccountBalanceFlow(publicKey)
        accountHistoryViewModel.getAccountHistory(publicKey)
        initUi()
        initObserver()
        handleLoadState()
    }

    override fun onStart() {
        super.onStart()
        initSavedStateListener()
        accountHistoryViewModel.activatePendingTransaction(publicKey)
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
            accountHistoryRecyclerView.adapter = concatAdapter
            transactionHistoryToolbar.apply {
                setOnFilterClickListener(::onFilterClick)
                setOnExportClickListener(::onExportClick)
            }
            screenStateView.setOnNeutralButtonClickListener { accountHistoryViewModel.refreshTransactionHistory() }
        }
    }

    private fun initObserver() {
        with(accountHistoryViewModel) {
            viewLifecycleOwner.lifecycleScope.launch {
                getAccountHistoryFlow(publicKey)?.collectLatest(transactionHistoryCollector)
            }
            viewLifecycleOwner.lifecycleScope.launch {
                pendingTransactionsFlow.collectLatest(pendingTransactionCollector)
            }
            viewLifecycleOwner.lifecycleScope.launch {
                dateFilterPreviewFlow.collectLatest(dateFilterPreviewCollector)
            }
            viewLifecycleOwner.lifecycleScope.launchWhenStarted {
                accountHistoryViewModel.csvStatusPreview.collect(csvStatusPreviewCollector)
            }
        }
    }

    private fun handleLoadState() {
        viewLifecycleOwner.lifecycleScope.launch {
            accountHistoryAdapter.loadStateFlow.collectLatest { combinedLoadStates ->
                updateUiWithTransactionLoadStatePreview(
                    accountHistoryViewModel.createTransactionLoadStatePreview(
                        combinedLoadStates,
                        concatAdapter.itemCount,
                        binding.screenStateView.isVisible
                    )
                )
            }
        }
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
        val currentFilter = accountHistoryViewModel.getDateFilterValue()
        listener?.onFilterTransactionClick(currentFilter)
    }

    private fun onExportClick() {
        context?.cacheDir?.let { cacheDirectory ->
            accountHistoryViewModel.createCsvFile(cacheDirectory, publicKey)
        }
    }

    private fun updateCsvStatusPreview(csvStatusPreview: CsvStatusPreview?) {
        if (csvStatusPreview == null) return
        if (csvStatusPreview.isErrorShown) {
            showGlobalError(getString(csvStatusPreview.errorResId))
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
                    setFilterIcon(filterButtonIconResId)
                    if (titleResId != null) setTitle(titleResId) else if (title != null) setTitle(title)
                }
            }
        }
    }

    interface Listener {
        fun onTransactionClick(transaction: BaseTransactionItem.TransactionItem)
        fun onFilterTransactionClick(dateFilter: DateFilter)
    }

    companion object {
        private const val PUBLIC_KEY = "public_key"
        fun newInstance(publicKey: String): AccountHistoryFragment {
            return AccountHistoryFragment().apply { arguments = Bundle().apply { putString(PUBLIC_KEY, publicKey) } }
        }
    }
}
