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
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.DaggerBaseFragment
import com.algorand.android.databinding.FragmentWalletConnectSessionsBinding
import com.algorand.android.models.DecodedQrCode
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.IconButton
import com.algorand.android.models.QrScanner
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.ui.qr.QrCodeScannerFragment.Companion.QR_SCAN_RESULT_KEY
import com.algorand.android.ui.qr.QrCodeScannerFragment.ScanReturnType.WALLET_CONNECT
import com.algorand.android.utils.startSavedStateListener
import com.algorand.android.utils.useSavedStateValue
import com.algorand.android.utils.viewbinding.viewBinding
import com.algorand.android.utils.walletconnect.WalletConnectViewModel
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collect

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
        initObserver()
        initUi()
    }

    private fun initObserver() {
        viewLifecycleOwner.lifecycleScope.launchWhenStarted {
            walletConnectViewModel.localSessionsFlow.collect(::onGetLocalSessionsSuccess)
        }
    }

    private fun initUi() {
        with(binding) {
            scanQrButton.setOnClickListener { onScanQrClick() }
            sessionRecyclerView.adapter = walletConnectSessionAdapter
            initAddMoreSessionsButton()
        }
    }

    override fun onResume() {
        super.onResume()
        startSavedStateListener(R.id.walletConnectSessionsFragment) {
            useSavedStateValue<DecodedQrCode?>(QR_SCAN_RESULT_KEY) {
                handleWalletConnectUrl(it?.walletConnectUrl.orEmpty())
            }
        }
    }

    private fun onGetLocalSessionsSuccess(wcSessions: List<WalletConnectSession>) {
        walletConnectSessionAdapter.submitList(wcSessions)
        binding.emptyStateGroup.isVisible = wcSessions.isEmpty()
    }

    private fun onScanQrClick() {
        nav(
            WalletConnectSessionsFragmentDirections.actionWalletConnectSessionsFragmentToQrCodeScannerNavigation(
                QrScanner(scanTypes = arrayOf(WALLET_CONNECT), isShowingWCSessionsButton = true)
            )
        )
    }

    private fun initAddMoreSessionsButton() {
        getAppToolbar()?.addButtonToEnd(IconButton(R.drawable.ic_qr_scan, onClick = ::onScanQrClick))
    }
}
