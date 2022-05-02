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

package com.algorand.android.ui.notificationcenter

import android.os.Bundle
import android.view.View
import androidx.core.view.isInvisible
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import androidx.paging.LoadState
import androidx.paging.PagingData
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentNotificationCenterBinding
import com.algorand.android.models.AccountDetailTab
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.NotificationCenterPreview
import com.algorand.android.models.NotificationListItem
import com.algorand.android.models.ScreenState
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import java.io.IOException
import java.time.ZonedDateTime
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class NotificationCenterFragment : DaggerBaseFragment(R.layout.fragment_notification_center) {

    private val notificationCenterViewModel: NotificationCenterViewModel by viewModels()

    private val binding by viewBinding(FragmentNotificationCenterBinding::bind)

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.notifications,
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(
        toolbarConfiguration = toolbarConfiguration,
        isBottomBarNeeded = false
    )

    private val emptyState by lazy {
        ScreenState.CustomState(
            icon = R.drawable.ic_notification,
            title = R.string.no_current_notifications,
            description = R.string.your_recent_transactions
        )
    }

    private val notificationAdapter = NotificationAdapter(::onNewItemAddedToTop, ::onNotificationClick)

    private val notificationCenterPreviewCollector: suspend (NotificationCenterPreview?) -> Unit = {
        if (it != null) initPreview(it)
    }

    private val notificationPaginationCollector: suspend (PagingData<NotificationListItem>) -> Unit = { pagingData ->
        notificationAdapter.submitData(pagingData)
    }

    private val isRefreshNeededObserver = Observer<Boolean> { isRefreshNeeded ->
        if (isRefreshNeeded) {
            refreshList(changeRefreshTime = true)
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupToolbar()
        setupRecyclerView()
        initObservers()
        initUi()
    }

    private fun initUi() {
        binding.screenStateView.setOnNeutralButtonClickListener(::handleErrorButtonClick)
    }

    private fun initPreview(notificationCenterPreview: NotificationCenterPreview) {
        with(notificationCenterPreview) {
            onGoingAssetDetailEvent?.consume()?.run {
                navToAssetDetail(publicKey = first, assetId = second)
            }
            onGoingCollectibleDetailEvent?.consume()?.run {
                navToCollectibleDetail(publicKey = first, assetId = second)
            }
            onAssetSupportRequestEvent?.consume()?.run {
                nav(HomeNavigationDirections.actionGlobalUnsupportedAssetNotificationRequestActionBottomSheet(this))
            }
            onHistoryNotAvailableEvent?.consume()?.run {
                onHistoryNotAvailable(publicKey = this)
            }
            onTransactionReceivedEvent?.consume()?.run {
                notificationCenterViewModel.isAssetAvailableOnAccount(publicKey = first, assetId = second)
            }
            onTransactionSentEvent?.consume()?.run {
                notificationCenterViewModel.isAssetAvailableOnAccount(publicKey = first, assetId = second)
            }
        }
    }

    private fun setupToolbar() {
        getAppToolbar()?.addButtonToEnd(IconButton(R.drawable.ic_filter, onClick = ::onFilterClick))
    }

    private fun setupRecyclerView() {
        binding.notificationsRecyclerView.apply {
            notificationAdapter.lastRefreshedDateTime = notificationCenterViewModel.getLastRefreshedDateTime()
            notificationCenterViewModel.setLastRefreshedDateTime(ZonedDateTime.now())
            adapter = notificationAdapter
        }

        notificationAdapter.registerDataObserver()

        handleLoadState()

        binding.swipeRefreshLayout.setOnRefreshListener { refreshList(changeRefreshTime = true) }
    }

    private fun initObservers() {
        viewLifecycleOwner.lifecycleScope.launch {
            notificationCenterViewModel.notificationPaginationFlow.collectLatest(notificationPaginationCollector)
        }
        viewLifecycleOwner.lifecycleScope.launch {
            notificationCenterViewModel.notificationCenterPreviewFlow.collectLatest(notificationCenterPreviewCollector)
        }
        notificationCenterViewModel.isRefreshNeededLiveData().observe(viewLifecycleOwner, isRefreshNeededObserver)
    }

    override fun onResume() {
        super.onResume()
        refreshList(changeRefreshTime = false)
    }

    private fun handleLoadState() {
        viewLifecycleOwner.lifecycleScope.launch {
            notificationAdapter.loadStateFlow.collectLatest { combinedLoadStates ->
                val isNotificationListEmpty = notificationAdapter.itemCount == 0
                val isCurrentStateError = combinedLoadStates.refresh is LoadState.Error
                val isLoading = combinedLoadStates.refresh is LoadState.Loading
                binding.swipeRefreshLayout.isRefreshing = isLoading
                when {
                    isCurrentStateError -> {
                        enableNotificationsErrorState((combinedLoadStates.refresh as LoadState.Error).error)
                    }
                    isLoading.not() && isNotificationListEmpty -> {
                        binding.screenStateView.setupUi(emptyState)
                    }
                }
                binding.notificationsRecyclerView.isInvisible = isCurrentStateError || isNotificationListEmpty
                binding.screenStateView.isVisible = (isCurrentStateError || isNotificationListEmpty) && isLoading.not()
            }
        }
    }

    private fun enableNotificationsErrorState(throwable: Throwable) {
        if (throwable is IOException) {
            binding.screenStateView.setupUi(ScreenState.ConnectionError())
        } else {
            binding.screenStateView.setupUi(ScreenState.DefaultError())
        }
    }

    private fun handleErrorButtonClick() {
        refreshList()
    }

    private fun refreshList(changeRefreshTime: Boolean = false) {
        var refreshDateTime: ZonedDateTime? = null
        if (changeRefreshTime) {
            refreshDateTime = ZonedDateTime.now()
            notificationAdapter.lastRefreshedDateTime = refreshDateTime
        }
        notificationCenterViewModel.refreshNotificationData(refreshDateTime)
    }

    private fun onNotificationClick(notificationListItem: NotificationListItem) {
        notificationCenterViewModel.onNotificationClickEvent(notificationListItem)
    }

    private fun onNewItemAddedToTop() {
        if (lifecycle.currentState.isAtLeast(Lifecycle.State.INITIALIZED)) {
            binding.notificationsRecyclerView.scrollToPosition(0)
        }
    }

    override fun onDestroyView() {
        notificationAdapter.unregisterDataObserver()
        super.onDestroyView()
    }

    private fun onFilterClick() {
        nav(
            NotificationCenterFragmentDirections.actionNotificationCenterFragmentToNotificationFilterFragment(
                showDoneButton = false
            )
        )
    }

    private fun navToCollectibleDetail(publicKey: String, assetId: Long) {
        nav(
            NotificationCenterFragmentDirections.actionNotificationCenterFragmentToCollectibleDetailFragment(
                publicKey = publicKey,
                collectibleAssetId = assetId
            )
        )
    }

    private fun navToAssetDetail(publicKey: String, assetId: Long) {
        nav(HomeNavigationDirections.actionGlobalAssetDetailFragment(address = publicKey, assetId = assetId))
    }

    private fun onHistoryNotAvailable(publicKey: String) {
        navToAccountHistory(publicKey)
        showUnavailableTransactionHistoryError()
    }

    private fun navToAccountHistory(publicKey: String) {
        nav(
            NotificationCenterFragmentDirections.actionNotificationCenterFragmentToAccountDetailFragment(
                publicKey = publicKey,
                accountDetailTab = AccountDetailTab.HISTORY
            )
        )
    }

    private fun showUnavailableTransactionHistoryError() {
        showGlobalError(
            errorMessage = getString(R.string.the_history_for_this_spesific),
            title = getString(R.string.asset_history_not_available)
        )
    }
}
