/*
 * Copyright 2019 Algorand, Inc.
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

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.core.view.isInvisible
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.navArgs
import androidx.paging.LoadState
import androidx.recyclerview.widget.ConcatAdapter
import androidx.viewpager2.widget.MarginPageTransformer
import androidx.viewpager2.widget.ViewPager2.ORIENTATION_HORIZONTAL
import androidx.viewpager2.widget.ViewPager2.OnPageChangeCallback
import com.algorand.android.MainActivity
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.ErrorListView
import com.algorand.android.customviews.SendReceiveBottomView
import com.algorand.android.customviews.Tooltip
import com.algorand.android.databinding.FragmentAssetDetailBinding
import com.algorand.android.models.Account
import com.algorand.android.models.AccountCacheData
import com.algorand.android.models.AccountCacheStatus
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.BaseTransactionListItem
import com.algorand.android.models.CurrencyValue
import com.algorand.android.models.DateFilter
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.TransactionDiffCallback
import com.algorand.android.models.TransactionListItem
import com.algorand.android.ui.assetdetail.AssetDetailFragmentDirections.Companion.actionAccountsFragmentToSendInfoFragment
import com.algorand.android.ui.assetdetail.AssetDetailFragmentDirections.Companion.actionAccountsFragmentToTransactionDetailFragment
import com.algorand.android.ui.assetdetail.AssetDetailFragmentDirections.Companion.actionAssetDetailFragmentToAnalyticsDetailBottomSheet
import com.algorand.android.ui.assetdetail.AssetDetailFragmentDirections.Companion.actionAssetDetailFragmentToDateFilterPickerBottomSheet
import com.algorand.android.ui.assetdetail.AssetDetailFragmentDirections.Companion.actionAssetDetailFragmentToShowQrBottomSheet
import com.algorand.android.ui.common.transactions.PendingAdapter
import com.algorand.android.ui.common.transactions.TransactionsPagingAdapter
import com.algorand.android.ui.datepicker.DateFilterListFragment.Companion.DATE_FILTER_RESULT
import com.algorand.android.utils.AccountCacheManager
import com.algorand.android.utils.CSV_FILE_MIME_TYPE
import com.algorand.android.utils.Event
import com.algorand.android.utils.Resource
import com.algorand.android.utils.analytics.logAssetDetail
import com.algorand.android.utils.analytics.logAssetDetailChange
import com.algorand.android.utils.analytics.logTapAssetDetailReceive
import com.algorand.android.utils.analytics.logTapAssetDetailSend
import com.algorand.android.utils.formatAmount
import com.algorand.android.utils.shareFile
import com.algorand.android.utils.showSnackbar
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.google.android.material.tabs.TabLayoutMediator
import com.google.firebase.crashlytics.FirebaseCrashlytics
import dagger.hilt.android.AndroidEntryPoint
import java.io.File
import java.io.IOException
import java.math.BigInteger
import javax.inject.Inject
import kotlin.properties.Delegates
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class AssetDetailFragment : DaggerBaseFragment(R.layout.fragment_asset_detail), AssetCardFragment.Listener {

    @Inject
    lateinit var accountCacheManager: AccountCacheManager

    private var csvFile: File? = null
    private lateinit var accountCacheData: AccountCacheData

    private lateinit var assetCardPagerAdapter: AssetCardPagerAdapter

    private val assetDetailViewModel: AssetDetailViewModel by viewModels()

    private val args: AssetDetailFragmentArgs by navArgs()

    private val binding by viewBinding(FragmentAssetDetailBinding::bind)

    private lateinit var selectedAsset: AssetInformation

    private var transactionsAdapter: ConcatAdapter? = null
    private lateinit var transactionsPagingAdapter: TransactionsPagingAdapter
    private lateinit var pendingAdapter: PendingAdapter

    private val sendRequestButtonListener = object : SendReceiveBottomView.Listener {
        override fun onSendClick() {
            val address = accountCacheData.account.address
            firebaseAnalytics.get().logTapAssetDetailSend(address)
            nav(
                actionAccountsFragmentToSendInfoFragment(assetInformation = selectedAsset, fromAccountAddress = address)
            )
        }

        override fun onReceiveClick() {
            with(accountCacheData.account) {
                firebaseAnalytics.get().logTapAssetDetailReceive(address)
                nav(actionAssetDetailFragmentToShowQrBottomSheet(title = name, qrText = address))
            }
        }
    }

    // <editor-fold defaultstate="collapsed" desc="Observers">

    // <editor-fold defaultstate="collapsed" desc="BalanceObservers">

    private val balanceObserver = Observer<BigInteger?> { newBalance ->
        balance = newBalance
    }

    private var balance by Delegates.observable<BigInteger?>(null) { _, oldValue, newValue ->
        if (oldValue != null && oldValue != newValue) {
            refreshTransactionHistoryData()
        }
        if (newValue != null) {
            setBalanceUI(newValue)
        }
    }

    // </editor-fold>

    // <editor-fold defaultstate="collapsed" desc="DateFilterObservers">

    private val dateFilterObserver = Observer<DateFilter> { newDateFilter ->
        dateFilter = newDateFilter
    }

    private var dateFilter by Delegates.observable<DateFilter?>(null) { _, oldValue, newValue ->
        if (oldValue != null && oldValue != newValue) {
            refreshTransactionHistoryData()
        }
        if (newValue != null) {
            setDateFilterUI(newValue)
        }
    }

    // </editor-fold>

    private val csvFileObserver = Observer<Event<Resource<File>>> { csvFileResourceEvent ->
        csvFileResourceEvent.consume()?.let { csvFileResource ->
            csvFileResource.use(
                onSuccess = { file -> onNewCSVFileCreated(file) },
                onFailed = { showSnackbar(getString(R.string.couldnt_create), binding.assetDetailMotionLayout) },
                onLoading = { binding.blockerLoading.visibility = View.VISIBLE },
                onLoadingFinished = { binding.blockerLoading.visibility = View.GONE }
            )
        }
    }

    private val pendingHistoryObserver = Observer<List<BaseTransactionListItem>> { pendingHistory ->
        pendingAdapter.submitList(pendingHistory)
        checkEmptyListViewVisibility()
    }

    // </editor-fold>

    override val fragmentConfiguration = FragmentConfiguration(
        firebaseEventScreenId = FIREBASE_EVENT_SCREEN_ID
    )

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initSyncObserver()
    }

    override fun onResume() {
        super.onResume()
        if (this::accountCacheData.isInitialized) {
            assetDetailViewModel.isPendingTransactionPollingActive = true
        }
    }

    override fun onPause() {
        super.onPause()
        assetDetailViewModel.isPendingTransactionPollingActive = false
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == CSV_REQUEST_CODE) {
            csvFile?.delete()
        }
    }

    private fun setupFragment() {
        if (getData()) {
            loadData()
            initTransactionRecyclerView()
            initObservers()
            initUI()
        } else {
            // TODO refactor here.
            // no data found in cache.
            navBack()
        }
    }

    private val accountCacheObserver = Observer<AccountCacheStatus> {
        if (it == AccountCacheStatus.DONE) {
            deactivateSyncObserver()
            setupFragment()
            binding.blockerLoading.visibility = View.GONE
        } else {
            binding.blockerLoading.visibility = View.VISIBLE
        }
    }

    private fun deactivateSyncObserver() {
        (activity as MainActivity).mainViewModel.accountBalanceSyncStatus.removeObservers(viewLifecycleOwner)
    }

    private fun initSyncObserver() {
        (activity as MainActivity).mainViewModel.accountBalanceSyncStatus.observe(
            viewLifecycleOwner,
            accountCacheObserver
        )
    }

    private fun initUI() {
        binding.backButton.setOnClickListener { navBack() }
        binding.swipeRefresh.setOnRefreshListener { onSwipeToRefresh() }
        binding.filterButton.setOnClickListener { onFilterClick() }
        binding.shareButton.setOnClickListener { onShareClick() }
        binding.sendReceiveBottom.apply {
            isVisible = accountCacheData.account.type != Account.Type.WATCH
            setListener(sendRequestButtonListener)
        }
        initDialogSavedStateListener()
        initCardAdapter()
        binding.errorListView.setTryAgainAction { transactionsPagingAdapter.retry() }
        activateFilterTooltipIfNeeded()
    }

    @SuppressLint("WrongConstant")
    private fun initCardAdapter() {
        assetCardPagerAdapter =
            AssetCardPagerAdapter(this, accountCacheData.assetsInformation, args.address)
        binding.cardsViewPager.apply {
            orientation = ORIENTATION_HORIZONTAL
            offscreenPageLimit = OFFSCREEN_PAGE_LIMIT_DEFAULT
            adapter = assetCardPagerAdapter
            setPageTransformer(MarginPageTransformer(resources.getDimensionPixelSize(R.dimen.card_margin)))
            val selectedAssetIndex =
                accountCacheData.assetsInformation.indexOfFirst { it.assetId == selectedAsset.assetId }
            post { currentItem = selectedAssetIndex }
            registerOnPageChangeCallback(object : OnPageChangeCallback() {
                override fun onPageSelected(position: Int) {
                    super.onPageSelected(position)
                    selectedAsset = accountCacheData.assetsInformation[position]
                    assetDetailViewModel.start(args.address, selectedAsset)
                    assetDetailViewModel.balanceLiveData?.observe(viewLifecycleOwner, balanceObserver)
                    initTransactionRecyclerView()
                    assetDetailViewModel.assetFilterLiveData.postValue(selectedAsset)
                    firebaseAnalytics.get().logAssetDetailChange(selectedAsset.assetId)
                }
            })
        }
        if (accountCacheData.assetsInformation.size > 1) {
            binding.pageIndicator.visibility = View.VISIBLE
            TabLayoutMediator(binding.pageIndicator, binding.cardsViewPager) { _, _ -> }.attach()
        }
    }

    private fun initObservers() {

        assetDetailViewModel.balanceLiveData?.observe(viewLifecycleOwner, balanceObserver)

        assetDetailViewModel.csvFileLiveData.observe(viewLifecycleOwner, csvFileObserver)

        assetDetailViewModel.getPendingDateAwareList().observe(viewLifecycleOwner, pendingHistoryObserver)

        assetDetailViewModel.dateFilterLiveData.observe(viewLifecycleOwner, dateFilterObserver)

        lifecycleScope.launch {
            assetDetailViewModel.transactionPaginationFlow?.collectLatest { transactionPagingData ->
                transactionsPagingAdapter.submitData(transactionPagingData)
            }
        }
    }

    private fun initDialogSavedStateListener() {
        startSavedStateListener(R.id.assetDetailFragment) {
            useSavedStateValue<DateFilter>(DATE_FILTER_RESULT) { newDateFilter ->
                assetDetailViewModel.dateFilterLiveData.value = newDateFilter
            }
        }
    }

    private fun initTransactionRecyclerView() {
        if (transactionsAdapter == null) {
            val diffCallback = TransactionDiffCallback()
            transactionsPagingAdapter = TransactionsPagingAdapter(::onTransactionClick, diffCallback)
            pendingAdapter = PendingAdapter(::onTransactionClick, ::onNewPendingItemInserted, diffCallback)
            transactionsAdapter = ConcatAdapter(pendingAdapter, transactionsPagingAdapter)
        }

        binding.historyList.apply {
            adapter = transactionsAdapter
            itemAnimator = null
        }

        viewLifecycleOwner.lifecycleScope.launch {
            transactionsPagingAdapter.loadStateFlow.collectLatest { combinedLoadStates ->
                val isPreviousStateError = binding.errorListView.isVisible
                val isCurrentStateError = combinedLoadStates.refresh is LoadState.Error
                val isLoading = combinedLoadStates.refresh is LoadState.Loading
                if (isCurrentStateError) {
                    enableHistoryErrorState((combinedLoadStates.refresh as LoadState.Error).error)
                }
                checkEmptyListViewVisibility(isLoading)
                binding.historyList.isInvisible = isPreviousStateError || isCurrentStateError
                binding.errorListView.isVisible = isCurrentStateError
                binding.emptyListView.isVisible = binding.emptyListView.isVisible && isCurrentStateError.not()
                binding.swipeRefresh.isRefreshing = isLoading
            }
        }
    }

    private fun checkEmptyListViewVisibility(isLoading: Boolean = false) {
        binding.emptyListView.isVisible = isLoading.not() && transactionsAdapter?.itemCount == 0
    }

    private fun setBalanceUI(balance: BigInteger) {
        val formattedValue = balance.formatAmount(selectedAsset.decimals)
        val subtitleText = "$formattedValue ${selectedAsset.getTickerText(resources)}"
        binding.subtitleTextView.text = subtitleText
    }

    private fun setDateFilterUI(dateFilter: DateFilter) {
        val filterButtonIconResId = if (dateFilter == DateFilter.AllTime) {
            R.drawable.ic_filter
        } else {
            R.drawable.ic_selected_filter
        }

        val title = when (dateFilter) {
            DateFilter.AllTime -> getString(R.string.transactions)
            is DateFilter.CustomRange -> dateFilter.getDateRange()?.getRangeAsText(dateFilter).orEmpty()
            else -> getString(dateFilter.titleResId)
        }

        binding.historyTitleTextView.text = title
        binding.filterButton.setIconResource(filterButtonIconResId)
    }

    private fun getData(): Boolean {
        if (this::selectedAsset.isInitialized.not()) {
            selectedAsset = args.assetInformation
            assetDetailViewModel.assetFilterLiveData.postValue(selectedAsset)
        }

        // START TODO get this from livedata to fix problems.
        val currentCacheData = accountCacheManager.getCacheData(args.address)
        return if (currentCacheData != null) {
            accountCacheData = currentCacheData
            true
        } else {
            val exception = Exception("${args.address} cache data is null for AssetDetailFragment.")
            FirebaseCrashlytics.getInstance().recordException(exception)
            false
        }
        // END TODO
    }

    private fun loadData() {
        assetDetailViewModel.start(args.address, selectedAsset)
        binding.titleTextView.text = accountCacheData.account.name
        firebaseAnalytics.get().logAssetDetail(selectedAsset.assetId)
    }

    private fun refreshTransactionHistoryData() {
        assetDetailViewModel.transactionHistoryDataSource?.invalidate()
    }

    private fun activateFilterTooltipIfNeeded() {
        val offsetX = resources.getDimensionPixelOffset(R.dimen.keyline_1_minus_8dp)
        binding.filterButton.post {
            if (assetDetailViewModel.isFilterTooltipShown().not()) {
                val config = Tooltip.Config(binding.filterButton, offsetX, R.string.you_can_now_filter, false)
                Tooltip(binding.filterButton.context).show(config, viewLifecycleOwner)
                assetDetailViewModel.setFilterTooltipShown()
            }
        }
    }

    private fun enableHistoryErrorState(throwable: Throwable) {
        binding.errorListView.setupError(
            if (throwable is IOException) {
                ErrorListView.Type.CONNECTION_ERROR
            } else {
                ErrorListView.Type.DEFAULT_ERROR
            }
        )
    }

    private fun onFilterClick() {
        val currentDateFilter = assetDetailViewModel.dateFilterLiveData.value ?: DateFilter.AllTime
        nav(actionAssetDetailFragmentToDateFilterPickerBottomSheet(currentDateFilter))
    }

    private fun onTransactionClick(transaction: TransactionListItem) {
        nav(actionAccountsFragmentToTransactionDetailFragment(transaction))
    }

    private fun onSwipeToRefresh() {
        refreshTransactionHistoryData()
    }

    private fun onNewPendingItemInserted() {
        binding.emptyListView.visibility = View.GONE
        binding.historyList.scrollToPosition(0)
    }

    private fun onShareClick() {
        context?.cacheDir?.let { cacheDirectory ->
            assetDetailViewModel.createCSVForList(cacheDirectory, accountCacheData.account.name)
        }
    }

    private fun onNewCSVFileCreated(file: File?) {
        if (file != null) {
            csvFile = shareFile(file, CSV_REQUEST_CODE, CSV_FILE_MIME_TYPE)
        } else {
            showSnackbar(getString(R.string.couldnt_create), binding.assetDetailMotionLayout)
        }
    }

    companion object {
        private const val CSV_REQUEST_CODE = 1015
        private const val OFFSCREEN_PAGE_LIMIT_DEFAULT = 3
        private const val FIREBASE_EVENT_SCREEN_ID = "screen_asset_detail"
    }

    override fun onAssetCardSelected(algoAccountAddress: String, selectedCurrency: CurrencyValue) {
        nav(actionAssetDetailFragmentToAnalyticsDetailBottomSheet(args.address, selectedCurrency))
    }
}
