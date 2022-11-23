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

package com.algorand.android.modules.walletconnect.sessions.ui

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentWalletConnectSessionsBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.WarningConfirmation
import com.algorand.android.modules.walletconnect.sessions.ui.adapter.WalletConnectSessionAdapter
import com.algorand.android.modules.walletconnect.sessions.ui.model.WalletConnectSessionItem
import com.algorand.android.ui.common.warningconfirmation.WarningConfirmationBottomSheet
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class WalletConnectSessionsFragment : DaggerBaseFragment(R.layout.fragment_wallet_connect_sessions) {

    private val binding by viewBinding(FragmentWalletConnectSessionsBinding::bind)

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.wallet_connect_sessions,
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val walletConnectSessionsViewModel by viewModels<WalletConnectSessionsViewModel>()

    private val walletConnectSessionsCollector: suspend (List<WalletConnectSessionItem>?) -> Unit = { sessionList ->
        walletConnectSessionAdapter.submitList(sessionList)
    }

    private val disconnectAllButtonVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        binding.disconnectAllSessionsButton.isVisible = isVisible == true
    }

    private val emptyStateVisibilityCollector: suspend (Boolean?) -> Unit = { isVisible ->
        binding.emptyStateGroup.isVisible = isVisible == true
    }

    private val onDisconnectAllSessionsEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { onDisconnectAllSessions() }
    }

    private val onNavigateToScanQrEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { navToQrScannerFragment() }
    }

    private val walletConnectSessionAdapterListener =
        object : WalletConnectSessionAdapter.WalletConnectSessionAdapterListener {
            override fun onDisconnectClick(sessionId: Long) {
                walletConnectSessionsViewModel.killWalletConnectSession(sessionId)
            }

            override fun onSessionClick(sessionId: Long) {
                walletConnectSessionsViewModel.connectToExistingSession(sessionId)
            }
        }

    private val walletConnectSessionAdapter = WalletConnectSessionAdapter(walletConnectSessionAdapterListener)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initDialogSavedStateListener()
        initObserver()
        initUi()
    }

    private fun initObserver() {
        with(walletConnectSessionsViewModel.walletConnectSessionsPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it?.walletConnectSessionList }.distinctUntilChanged(),
                collection = walletConnectSessionsCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.isDisconnectAllSessionVisible }.distinctUntilChanged(),
                collection = disconnectAllButtonVisibilityCollector
            )
            collectLatestOnLifecycle(
                map { it?.isEmptyStateVisible }.distinctUntilChanged(),
                collection = emptyStateVisibilityCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.onDisconnectAllSessions }.distinctUntilChanged(),
                collection = onDisconnectAllSessionsEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.onNavigateToScanQr }.distinctUntilChanged(),
                collection = onNavigateToScanQrEventCollector
            )
        }
    }

    private fun initUi() {
        with(binding) {
            with(walletConnectSessionsViewModel) {
                scanQrButton.setOnClickListener { onScanQrClick() }
                disconnectAllSessionsButton.setOnClickListener { onDisconnectFromAllSessionsClick() }
            }
            sessionRecyclerView.adapter = walletConnectSessionAdapter
            initAddMoreSessionsButton()
        }
    }

    private fun navToQrScannerFragment() {
        nav(
            WalletConnectSessionsFragmentDirections
                .actionWalletConnectSessionsFragmentToWalletConnectSessionsQrScannerFragment()
        )
    }

    private fun initAddMoreSessionsButton() {
        getAppToolbar()?.setEndButton(button = IconButton(R.drawable.ic_qr_scan, onClick = ::navToQrScannerFragment))
    }

    private fun onDisconnectAllSessions() {
        val warningConfirmation = WarningConfirmation(
            titleRes = R.string.disconnect_all_sessions,
            descriptionRes = R.string.would_disconnect_all_sessions,
            drawableRes = R.drawable.ic_trash,
            positiveButtonTextRes = R.string.disconnect,
            negativeButtonTextRes = R.string.cancel
        )
        nav(
            WalletConnectSessionsFragmentDirections.actionWalletConnectSessionsFragmentToWarningConfirmationNavigation(
                warningConfirmation
            )
        )
    }

    private fun initDialogSavedStateListener() {
        startSavedStateListener(R.id.walletConnectSessionsFragment) {
            useSavedStateValue<Boolean>(WarningConfirmationBottomSheet.WARNING_CONFIRMATION_KEY) { isConfirmed ->
                if (isConfirmed) {
                    walletConnectSessionsViewModel.killAllWalletConnectSessions()
                }
            }
        }
    }
}
