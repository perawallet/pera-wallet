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

package com.algorand.android.modules.walletconnect.connectedapps.ui

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetWalletConnectConnectedAppsBinding
import com.algorand.android.modules.walletconnect.connectedapps.ui.adapter.WalletConnectSessionAdapter
import com.algorand.android.modules.walletconnect.connectedapps.ui.model.WalletConnectSessionItem
import com.algorand.android.modules.walletconnect.ui.model.WalletConnectSessionIdentifier
import com.algorand.android.utils.Event
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class WalletConnectConnectedAppsBottomSheet : BaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_wallet_connect_connected_apps
) {

    private val binding by viewBinding(BottomSheetWalletConnectConnectedAppsBinding::bind)

    private val walletConnectConnectedAppsViewModel by viewModels<WalletConnectConnectedAppsViewModel>()

    private val navigateBackEventCollector: suspend (Event<Unit>?) -> Unit = { event ->
        event?.consume()?.run { navBack() }
    }

    private val walletConnectSessionListCollector: suspend (List<WalletConnectSessionItem>?) -> Unit = { sessions ->
        walletConnectSessionAdapter.submitList(sessions)
    }

    private val walletConnectSessionAdapterListener =
        object : WalletConnectSessionAdapter.WalletConnectSessionAdapterListener {
            override fun onDisconnectClick(sessionIdentifier: WalletConnectSessionIdentifier) {
                walletConnectConnectedAppsViewModel.killWalletConnectSession(sessionIdentifier)
            }

            override fun onSessionClick(sessionIdentifier: WalletConnectSessionIdentifier) {
                walletConnectConnectedAppsViewModel.connectToExistingSession(sessionIdentifier)
            }
        }

    private val walletConnectSessionAdapter = WalletConnectSessionAdapter(walletConnectSessionAdapterListener)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObserver()
    }

    private fun initObserver() {
        with(walletConnectConnectedAppsViewModel.walletConnectConnectedAppsPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it?.walletConnectSessionList },
                collection = walletConnectSessionListCollector
            )
            collectLatestOnLifecycle(
                flow = map { it?.navigateBackEvent },
                collection = navigateBackEventCollector
            )
        }
    }

    private fun initUi() {
        with(binding) {
            sessionRecyclerView.adapter = walletConnectSessionAdapter
            closeButton.setOnClickListener { navBack() }
        }
    }
}
