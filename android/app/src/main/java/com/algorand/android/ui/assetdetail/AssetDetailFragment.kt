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

package com.algorand.android.ui.assetdetail

import android.os.Bundle
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.content.res.AppCompatResources
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.paging.PagingData
import androidx.recyclerview.widget.ConcatAdapter
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.AlgorandFloatingActionButton
import com.algorand.android.databinding.FragmentAssetDetailBinding
import com.algorand.android.models.AssetTransaction
import com.algorand.android.models.BaseTransactionItem
import com.algorand.android.models.CsvStatusPreview
import com.algorand.android.models.DateFilter
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.PendingReward
import com.algorand.android.models.StatusBarConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.ui.AssetDetailPreview
import com.algorand.android.models.ui.DateFilterPreview
import com.algorand.android.models.ui.TransactionLoadStatePreview
import com.algorand.android.ui.accountdetail.history.adapter.AccountHistoryAdapter
import com.algorand.android.ui.accountdetail.history.adapter.PendingTransactionAdapter
import com.algorand.android.ui.datepicker.DateFilterListBottomSheet
import com.algorand.android.utils.CSV_FILE_MIME_TYPE
import com.algorand.android.utils.copyToClipboard
import com.algorand.android.utils.extensions.hide
import com.algorand.android.utils.sendErrorLog
import com.algorand.android.utils.setDrawable
import com.algorand.android.utils.shareFile
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class AssetDetailFragment : DaggerBaseFragment(R.layout.fragment_asset_detail) {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack,
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        firebaseEventScreenId = FIREBASE_EVENT_SCREEN_ID
    )

    private val assetDetailViewModel: AssetDetailViewModel by viewModels()

    private val binding by viewBinding(FragmentAssetDetailBinding::bind)

    private val assetId by lazy { assetDetailViewModel.getAssetId() }

    private val transactionListener = object : AccountHistoryAdapter.Listener {
        override fun onTransactionClick(transaction: BaseTransactionItem.TransactionItem) {
            onTransactionItemClick(transaction)
        }
    }

    private val extendedStatusBarConfiguration by lazy {
        StatusBarConfiguration(backgroundColor = R.color.black_A3, showNodeStatus = false)
    }

    private val defaultStatusBarConfiguration by lazy { StatusBarConfiguration() }

    private val fabListener = object : AlgorandFloatingActionButton.Listener {
        override fun onReceiveClick() {
            nav(
                AssetDetailFragmentDirections.actionGlobalShowQrBottomSheet(
                    title = getString(R.string.qr_code),
                    qrText = assetDetailViewModel.getPublicKey()
                )
            )
        }

        override fun onSendClick() {
            nav(
                HomeNavigationDirections.actionGlobalSendAlgoNavigation(
                    assetTransaction = AssetTransaction(
                        senderAddress = assetDetailViewModel.getPublicKey(),
                        assetId = assetDetailViewModel.getAssetId()
                    )
                )
            )
        }

        override fun onStateChange(isExtended: Boolean) {
            val statusBarConfiguration = if (isExtended) {
                extendedStatusBarConfiguration
            } else {
                defaultStatusBarConfiguration
            }
            changeStatusBarConfiguration(statusBarConfiguration)
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
            onTransactionItemClick(transaction)
        }

        override fun onNewPendingItemInserted() {
            binding.screenStateView.hide()
            binding.transactionList.scrollToPosition(0)
        }
    }

    private val transactionAdapter = AccountHistoryAdapter(transactionListener)
    private val pendingTransactionAdapter = PendingTransactionAdapter(pendingTransactionListener)
    private val concatAdapter = ConcatAdapter(pendingTransactionAdapter, transactionAdapter)

    private val assetDetailPreviewCollector: suspend (AssetDetailPreview?) -> Unit = {
        updateUiWithAssetDetailPreview(it)
    }

    private val transactionCollector: suspend (PagingData<BaseTransactionItem>) -> Unit = {
        transactionAdapter.submitData(it)
    }

    private val pendingTransactionCollector: suspend (List<BaseTransactionItem>?) -> Unit = {
        pendingTransactionAdapter.submitList(it)
    }

    private val dateFilterPreviewCollector: suspend (DateFilterPreview) -> Unit = {
        setTransactionToolbarUi(it)
    }

    private val pendingRewardCollector: suspend (PendingReward) -> Unit = {
        // TODO: 10.02.2022 Implementing the loading state could be good cause calculating
        //  reward is taking a bit of time at the first time
        binding.rewardsTextView.text = it.formattedPendingRewardAmount
    }

    override fun onStart() {
        super.onStart()
        assetDetailViewModel.activatePendingTransaction()
    }

    override fun onPause() {
        super.onPause()
        assetDetailViewModel.deactivatePendingTransaction()
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

    private fun initSavedStateListener() {
        startSavedStateListener(R.id.assetDetailFragment) {
            useSavedStateValue<DateFilter>(DateFilterListBottomSheet.DATE_FILTER_RESULT) { newDateFilter ->
                assetDetailViewModel.setDateFilter(newDateFilter)
            }
        }
    }

    private fun initObservers() {
        with(assetDetailViewModel) {
            viewLifecycleOwner.lifecycleScope.launch {
                assetDetailPreviewFlow.collectLatest(assetDetailPreviewCollector)
            }
            viewLifecycleOwner.lifecycleScope.launch {
                transactionPaginationFlow?.collectLatest(transactionCollector)
            }
            viewLifecycleOwner.lifecycleScope.launch {
                pendingTransactionsFlow.collectLatest(pendingTransactionCollector)
            }
            viewLifecycleOwner.lifecycleScope.launch {
                dateFilterPreviewFlow.collectLatest(dateFilterPreviewCollector)
            }
            viewLifecycleOwner.lifecycleScope.launch {
                pendingRewardFlow.collectLatest(pendingRewardCollector)
            }
            viewLifecycleOwner.lifecycleScope.launchWhenStarted {
                csvStatusPreview.collectLatest(csvStatusPreviewCollector)
            }
        }
    }

    private fun initUi() {
        with(binding) {
            assetDetailSendReceiveFab.setListener(fabListener)
            rewardsInfo.setOnClickListener { onRewardsInfoClicked() }
            transactionList.adapter = concatAdapter
            transactionHistoryToolbar.apply {
                setOnFilterClickListener(::onFilterClick)
                setOnExportClickListener(::onExportClick)
            }
            screenStateView.setOnNeutralButtonClickListener { assetDetailViewModel.refreshTransactionHistory() }
            assetIdCopyButton.setOnClickListener { onAssetIdClicked() }
        }
    }

    private fun updateUiWithAssetDetailPreview(assetDetailPreview: AssetDetailPreview?) {
        with(binding) {
            // TODO Find a better way to handling null & error & loading cases
            assetDetailPreview?.run {
                getAppToolbar()?.setAssetAvatarIfAlgorand(isAlgorand, shortName.getName(resources))
                assetDetailSendReceiveFab.isVisible = canSignTransaction
                algoAssetGroup.isVisible = isAlgorand
                otherAssetGroup.isVisible = isAlgorand.not()
                balanceTextView.text = formattedAssetBalance
                balanceInCurrencyTextView.text = formattedAssetBalanceInCurrency
                balanceInCurrencyTextView.isVisible = isAmountInSelectedCurrencyVisible
                otherAssetIdTextView.text = getString(R.string.asset_id_formatted, formattedAssetId)
                otherAssetFullNameTextView.apply {
                    text = fullName.getName(resources)
                    if (assetDetailPreview.isVerified) {
                        setDrawable(end = AppCompatResources.getDrawable(context, R.drawable.ic_shield_check_small))
                    }
                }
            } ?: kotlin.run {
                sendErrorLog("updateUiWithAssetDetailPreview: assetDetailPreview is null and assetId is $assetId")
            }
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

    private fun updateUiWithTransactionLoadStatePreview(loadStatePreview: TransactionLoadStatePreview) {
        with(binding) {
            loadingProgressBar.isVisible = loadStatePreview.isLoading
            screenStateView.isVisible = loadStatePreview.isScreenStateViewVisible
            transactionList.isVisible = loadStatePreview.isTransactionListVisible
            loadStatePreview.screenStateViewType?.let { screenStateView.setupUi(it) }
        }
    }

    private fun handleLoadState() {
        viewLifecycleOwner.lifecycleScope.launch {
            transactionAdapter.loadStateFlow.collectLatest { combinedLoadStates ->
                updateUiWithTransactionLoadStatePreview(
                    assetDetailViewModel.createTransactionLoadStatePreview(
                        combinedLoadStates,
                        transactionAdapter.itemCount,
                        binding.screenStateView.isVisible
                    )
                )
            }
        }
    }

    private fun onAssetIdClicked() {
        context?.copyToClipboard(assetId.toString(), ASSET_ID_COPY_LABEL)
    }

    private fun onTransactionItemClick(transaction: BaseTransactionItem) {
        nav(AssetDetailFragmentDirections.actionAssetDetailFragmentToTransactionDetailFragment(transaction))
    }

    private fun onFilterClick() {
        val currentFilter = assetDetailViewModel.getDateFilterValue()
        nav(AssetDetailFragmentDirections.actionAssetDetailFragmentToDateFilterPickerBottomSheet(currentFilter))
    }

    private fun onRewardsInfoClicked() {
        val publicKey = assetDetailViewModel.getPublicKey()
        nav(AssetDetailFragmentDirections.actionAssetDetailFragmentToRewardsBottomSheet(publicKey))
    }

    private fun onExportClick() {
        context?.cacheDir?.let { cacheDirectory ->
            assetDetailViewModel.createCsvFile(cacheDirectory)
        }
    }

    private fun setTransactionToolbarUi(dateFilterPreview: DateFilterPreview) {
        with(dateFilterPreview) {
            with(binding) {
                transactionHistoryToolbar.setFilterIcon(filterButtonIconResId)
                transactionHistoryToolbar.apply {
                    if (titleResId != null) setTitle(titleResId) else if (title != null) setTitle(title)
                }
            }
        }
    }

    companion object {
        private const val FIREBASE_EVENT_SCREEN_ID = "screen_asset_detail"
        private const val ASSET_ID_COPY_LABEL = "address"
    }
}
