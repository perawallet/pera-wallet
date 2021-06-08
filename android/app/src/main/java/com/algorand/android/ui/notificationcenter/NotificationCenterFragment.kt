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

package com.algorand.android.ui.notificationcenter

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.widget.ImageButton
import androidx.core.view.isInvisible
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import androidx.paging.LoadState
import androidx.recyclerview.widget.LinearLayoutManager
import com.algorand.android.HomeNavigationDirections.Companion.actionGlobalAssetDetailFragment
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.customviews.CustomToolbar
import com.algorand.android.customviews.ErrorListView
import com.algorand.android.databinding.FragmentNotificationCenterBinding
import com.algorand.android.models.AssetInformation
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.NotificationListItem
import com.algorand.android.models.NotificationType
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.ui.common.AssetActionBottomSheet
import com.algorand.android.ui.notificationcenter.NotificationCenterFragmentDirections.Companion.actionNotificationCenterFragmentToNotificationFilterFragment
import com.algorand.android.utils.addDivider
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

    private val toolbarConfiguration =
        ToolbarConfiguration(titleResId = R.string.notifications, type = CustomToolbar.Type.TAB_TOOLBAR)

    override val fragmentConfiguration =
        FragmentConfiguration(toolbarConfiguration = toolbarConfiguration, isBottomBarNeeded = true)

    private var notificationAdapter = NotificationAdapter(::onNewItemAddedToTop, ::onNotificationClick)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        setupToolbar()
        setupRecyclerView()
        initObservers()
    }

    private fun setupToolbar() {
        getAppToolbar()?.apply {
            val marginEnd = resources.getDimensionPixelSize(R.dimen.keyline_1_minus_8dp)

            val filterButton = LayoutInflater
                .from(context)
                .inflate(R.layout.custom_icon_tab_button, this, false) as ImageButton

            filterButton.apply {
                setImageResource(R.drawable.ic_filter)
                setOnClickListener { onFilterClick() }
                addViewToEndSide(this, marginEnd)
            }
        }
    }

    private fun setupRecyclerView() {
        val layoutManager = LinearLayoutManager(context)
        binding.notificationsRecyclerView.apply {
            setLayoutManager(layoutManager)
            notificationAdapter.lastRefreshedDateTime = notificationCenterViewModel.getLastRefreshedDateTime()
            notificationCenterViewModel.setLastRefreshedDateTime(ZonedDateTime.now())
            adapter = notificationAdapter
            addDivider(R.drawable.horizontal_divider_20dp)
        }

        notificationAdapter.registerDataObserver()

        handleLoadState()

        binding.swipeRefreshLayout.setOnRefreshListener { refreshList(changeRefreshTime = true) }

        binding.errorListView.setTryAgainAction { refreshList(changeRefreshTime = false) }
    }

    private fun initObservers() {
        lifecycleScope.launch {
            notificationCenterViewModel.notificationPaginationFlow.collectLatest { pagingData ->
                notificationAdapter.submitData(pagingData)
            }
        }

        notificationCenterViewModel.isRefreshNeededLiveData().observe(viewLifecycleOwner, Observer { isRefreshNeeded ->
            if (isRefreshNeeded) {
                refreshList(changeRefreshTime = true)
            }
        })
    }

    override fun onResume() {
        super.onResume()
        refreshList(changeRefreshTime = false)
    }

    private fun handleLoadState() {
        viewLifecycleOwner.lifecycleScope.launch {
            notificationAdapter.loadStateFlow.collectLatest { combinedLoadStates ->
                val isPreviousStateError = binding.errorListView.isVisible
                val isCurrentStateError = combinedLoadStates.refresh is LoadState.Error
                val isLoading = combinedLoadStates.refresh is LoadState.Loading
                binding.swipeRefreshLayout.isRefreshing = isLoading
                if (isCurrentStateError) {
                    enableNotificationsErrorState((combinedLoadStates.refresh as LoadState.Error).error)
                }
                binding.emptyListView.isVisible = isLoading.not() && notificationAdapter.itemCount == 0
                binding.notificationsRecyclerView.isInvisible = isPreviousStateError || isCurrentStateError
                binding.emptyListView.isVisible =
                    binding.emptyListView.isVisible && isCurrentStateError.not()
                binding.errorListView.isVisible = isCurrentStateError
            }
        }
    }

    private fun enableNotificationsErrorState(throwable: Throwable) {
        binding.errorListView.setupError(
            if (throwable is IOException) {
                ErrorListView.Type.CONNECTION_ERROR
            } else {
                ErrorListView.Type.DEFAULT_ERROR
            }
        )
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
        val metadata = notificationListItem.metadata ?: return
        val assetInformation = metadata.getAssetDescription().convertToAssetInformation()
        when (notificationListItem.type) {
            NotificationType.TRANSACTION_RECEIVED, NotificationType.ASSET_TRANSACTION_RECEIVED -> {
                navigateToAssetDetail(assetInformation, metadata.receiverPublicKey.orEmpty())
            }
            NotificationType.TRANSACTION_SENT, NotificationType.ASSET_TRANSACTION_SENT -> {
                navigateToAssetDetail(assetInformation, metadata.senderPublicKey.orEmpty())
            }
            NotificationType.ASSET_SUPPORT_REQUEST -> {
                AssetActionBottomSheet.show(
                    parentFragmentManager,
                    assetInformation.assetId,
                    AssetActionBottomSheet.Type.UNSUPPORTED_NOTIFICATION_REQUEST,
                    accountPublicKey = metadata.receiverPublicKey,
                    asset = assetInformation
                )
            }
            else -> {
                // NO ACTION TO TAKE
            }
        }
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

    private fun navigateToAssetDetail(assetInformation: AssetInformation, publicKey: String) {
        if (notificationCenterViewModel.isAssetAvailableOnAccount(publicKey, assetInformation)) {
            nav(actionGlobalAssetDetailFragment(assetInformation, publicKey))
        }
    }

    private fun onFilterClick() {
        nav(actionNotificationCenterFragmentToNotificationFilterFragment(showDoneButton = true))
    }
}
