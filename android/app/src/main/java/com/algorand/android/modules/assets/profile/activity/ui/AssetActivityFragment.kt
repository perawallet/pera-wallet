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

package com.algorand.android.modules.assets.profile.activity.ui

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.os.bundleOf
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.paging.CombinedLoadStates
import androidx.paging.PagingData
import androidx.recyclerview.widget.ConcatAdapter
import com.algorand.android.R
import com.algorand.android.core.BaseFragment
import com.algorand.android.databinding.FragmentAssetActivityBinding
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
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.scrollToTop
import com.algorand.android.utils.shareFile
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class AssetActivityFragment : BaseFragment(R.layout.fragment_asset_activity) {
    override val fragmentConfiguration = FragmentConfiguration()

    private val assetActivityViewModel: AssetActivityViewModel by viewModels()

    private val binding by viewBinding(FragmentAssetActivityBinding::bind)

    private var listener: Listener? = null

    private val transactionListener = object : AccountHistoryAdapter.Listener {
        override fun onStandardTransactionClick(transaction: BaseTransactionItem.TransactionItem) {
            onStandardTransactionItemClick(transaction)
        }

        override fun onApplicationCallTransactionClick(
            transaction: BaseTransactionItem.TransactionItem.ApplicationCallItem
        ) {
            onApplicationCallTransactionItemClick(transaction)
        }
    }

    private val sharingActivityResultLauncher =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) {
            // Nothing to do
        }

    private val csvStatusPreviewCollector: suspend (CsvStatusPreview?) -> Unit = {
        updateCsvStatusPreview(it)
    }

    private val pendingTransactionListener = object : PendingTransactionAdapter.Listener {
        override fun onTransactionClick(transaction: BaseTransactionItem.TransactionItem) {
            onStandardTransactionItemClick(transaction)
        }

        override fun onNewPendingItemInserted() {
// TODO This view check was added to prevent from the crash that was caused by accessing binding after fragment is dead
// This should be fixed by observing flows in `repeatOnLifecycle` scope after migrating to API 31
            if (view != null) {
                binding.screenStateView.hide()
                binding.assetActivityRecyclerView.scrollToTop()
            }
        }
    }

    private val transactionAdapter = AccountHistoryAdapter(transactionListener)
    private val pendingTransactionAdapter = PendingTransactionAdapter(pendingTransactionListener)
    private val concatAdapter = ConcatAdapter(pendingTransactionAdapter, transactionAdapter)

    private val transactionCollector: suspend (PagingData<BaseTransactionItem>) -> Unit = {
        transactionAdapter.submitData(it)
    }

    private val pendingTransactionCollector: suspend (List<BaseTransactionItem>?) -> Unit = {
        pendingTransactionAdapter.submitList(it)
    }

    private val dateFilterPreviewCollector: suspend (DateFilterPreview) -> Unit = {
        setTransactionToolbarUi(it)
    }

    private val loadStateFlowCollector: suspend (CombinedLoadStates) -> Unit = { combinedLoadStates ->
        updateUiWithTransactionLoadStatePreview(
            assetActivityViewModel.createTransactionLoadStatePreview(
                combinedLoadStates,
                transactionAdapter.itemCount,
                binding.screenStateView.isVisible
            )
        )
    }

    override fun onStart() {
        super.onStart()
        assetActivityViewModel.activatePendingTransaction()
    }

    override fun onPause() {
        super.onPause()
        assetActivityViewModel.deactivatePendingTransaction()
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initObservers()
        initUi()
        handleLoadState()
    }

    override fun onResume() {
        super.onResume()
        initSavedStateListener()
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = parentFragment as? Listener
    }

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.assetDetailFragment) {
            useSavedStateValue<DateFilter>(DateFilterListBottomSheet.DATE_FILTER_RESULT) { newDateFilter ->
                assetActivityViewModel.setDateFilter(newDateFilter)
            }
        }
    }

    private fun initObservers() {
        with(assetActivityViewModel) {
            viewLifecycleOwner.collectLatestOnLifecycle(
                transactionPaginationFlow,
                transactionCollector
            )

            viewLifecycleOwner.collectLatestOnLifecycle(
                pendingTransactionsFlow,
                pendingTransactionCollector
            )

            viewLifecycleOwner.collectLatestOnLifecycle(
                dateFilterPreviewFlow,
                dateFilterPreviewCollector
            )

            viewLifecycleOwner.collectLatestOnLifecycle(
                csvStatusPreview,
                csvStatusPreviewCollector
            )
        }
    }

    private fun initUi() {
        with(binding) {
            assetActivityRecyclerView.apply {
                adapter = concatAdapter
                addItemDecoration(
                    StickyAccountHistoryHeaderDecoration(
                        accountHistoryAdapter = transactionAdapter,
                        pendingTransactionAdapter = pendingTransactionAdapter,
                        context = context
                    )
                )
            }
            assetActivityToolbar.apply {
                setPrimaryButtonClickListener(::onFilterClick)
                setSecondaryButtonClickListener(::onExportClick)
            }
            screenStateView.setOnNeutralButtonClickListener { assetActivityViewModel.refreshTransactionHistory() }
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

    private fun updateUiWithTransactionLoadStatePreview(loadStatePreview: TransactionLoadStatePreview) {
        with(binding) {
            progressbar.loadingProgressBar.isVisible = loadStatePreview.isLoading
            screenStateView.isVisible = loadStatePreview.isScreenStateViewVisible
            assetActivityRecyclerView.isVisible = loadStatePreview.isTransactionListVisible
            loadStatePreview.screenStateViewType?.let { screenStateView.setupUi(it) }
        }
    }

    private fun handleLoadState() {
        viewLifecycleOwner.collectLatestOnLifecycle(
            transactionAdapter.loadStateFlow,
            loadStateFlowCollector
        )
    }

    private fun onStandardTransactionItemClick(transaction: BaseTransactionItem.TransactionItem) {
        listener?.onStandardTransactionItemClick(transaction)
    }

    private fun onApplicationCallTransactionItemClick(transaction: BaseTransactionItem.TransactionItem) {
        listener?.onApplicationCallTransactionItemClick(transaction)
    }

    private fun onFilterClick() {
        val currentFilter = assetActivityViewModel.getDateFilterValue()
        listener?.onDateFilterClick(currentFilter)
    }

    private fun onExportClick() {
        context?.cacheDir?.let { cacheDirectory ->
            assetActivityViewModel.createCsvFile(cacheDirectory)
        }
    }

    private fun setTransactionToolbarUi(dateFilterPreview: DateFilterPreview) {
        with(dateFilterPreview) {
            with(binding) {
                assetActivityToolbar.setPrimaryButtonIcon(
                    icon = filterButtonIconResId,
                    useIconsOwnTint = useFilterIconsOwnTint
                )
                assetActivityToolbar.apply {
                    if (titleResId != null) setTitle(titleResId) else if (title != null) setTitle(title)
                }
            }
        }
    }

    interface Listener {
        fun onDateFilterClick(currentFilter: DateFilter)
        fun onStandardTransactionItemClick(transaction: BaseTransactionItem.TransactionItem)
        fun onApplicationCallTransactionItemClick(transaction: BaseTransactionItem.TransactionItem)
    }

    companion object {
        fun newInstance(accountAddress: String, assetId: Long): AssetActivityFragment {
            return AssetActivityFragment().apply {
                arguments = bundleOf(
                    AssetActivityViewModel.ASSET_ID_KEY to assetId, // TODO: Get keys from its own view model
                    AssetActivityViewModel.ADDRESS_KEY to accountAddress
                )
            }
        }
    }
}
