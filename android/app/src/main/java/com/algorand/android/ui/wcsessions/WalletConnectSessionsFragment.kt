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

package com.algorand.android.ui.wcsessions

import android.os.Bundle
import android.view.View
import androidx.core.view.isVisible
import androidx.fragment.app.activityViewModels
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentWalletConnectSessionsBinding
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.models.WarningConfirmation
import com.algorand.android.ui.common.warningconfirmation.WarningConfirmationBottomSheet
import com.algorand.android.utils.extensions.collectOnLifecycle
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.algorand.android.utils.walletconnect.WalletConnectViewModel
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WalletConnectSessionsFragment : DaggerBaseFragment(R.layout.fragment_wallet_connect_sessions) {

    private val walletConnectViewModel: WalletConnectViewModel by activityViewModels()
    private val binding by viewBinding(FragmentWalletConnectSessionsBinding::bind)

    private val toolbarConfiguration = ToolbarConfiguration(
        titleResId = R.string.wallet_connect_sessions,
        startIconResId = R.drawable.ic_left_arrow,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val walletConnectSessionAdapterListener = object : WalletConnectSessionAdapter.Listener {
        override fun onDisconnectClick(session: WalletConnectSession) {
            walletConnectViewModel.killSession(session)
        }

        override fun onSessionClick(session: WalletConnectSession) {
            walletConnectViewModel.connectToSession(session)
        }
    }

    private val walletConnectSessionAdapter =
        WalletConnectSessionAdapter(walletConnectSessionAdapterListener, showDetails = true)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initDialogSavedStateListener()
        initObserver()
        initUi()
    }

    private fun initObserver() {
        viewLifecycleOwner.collectOnLifecycle(
            walletConnectViewModel.localSessionsFlow,
            ::onGetLocalSessionsSuccess
        )
    }

    private fun initUi() {
        with(binding) {
            scanQrButton.setOnClickListener { onScanQrClick() }
            disconnectAllSessionsButton.setOnClickListener { onDisconnectAllSessionsClick() }
            sessionRecyclerView.adapter = walletConnectSessionAdapter
            initAddMoreSessionsButton()
        }
    }

    private fun onGetLocalSessionsSuccess(wcSessions: List<WalletConnectSession>) {
        walletConnectSessionAdapter.submitList(wcSessions)
        binding.emptyStateGroup.isVisible = wcSessions.isEmpty()
        binding.disconnectAllSessionsButton.isVisible = wcSessions.isNotEmpty()
    }

    private fun onScanQrClick() {
        nav(
            WalletConnectSessionsFragmentDirections
                .actionWalletConnectSessionsFragmentToWalletConnectSessionsQrScannerFragment()
        )
    }

    private fun initAddMoreSessionsButton() {
        getAppToolbar()?.addButtonToEnd(IconButton(R.drawable.ic_qr_scan, onClick = ::onScanQrClick))
    }

    private fun onDisconnectAllSessionsClick() {
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
                    walletConnectViewModel.killAllWalletConnectSessions()
                }
            }
        }
    }
}
