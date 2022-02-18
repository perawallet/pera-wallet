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
import androidx.fragment.app.activityViewModels
import androidx.lifecycle.lifecycleScope
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetWalletConnectSessionsBinding
import com.algorand.android.models.WalletConnectSession
import com.algorand.android.utils.viewbinding.viewBinding
import com.algorand.android.utils.walletconnect.WalletConnectViewModel
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.collect

@AndroidEntryPoint
class WalletConnectSessionsBottomSheet : BaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_wallet_connect_sessions,
    fullPageNeeded = false
) {

    private val walletConnectViewModel: WalletConnectViewModel by activityViewModels()
    private val binding by viewBinding(BottomSheetWalletConnectSessionsBinding::bind)

    private val walletConnectSessionAdapterListener = object : WalletConnectSessionAdapter.Listener {
        override fun onDisconnectClick(session: WalletConnectSession) {
            walletConnectViewModel.killSession(session)
        }

        override fun onSessionClick(session: WalletConnectSession) {
            walletConnectViewModel.connectToSession(session)
        }
    }

    private val walletConnectSessionAdapter =
        WalletConnectSessionAdapter(walletConnectSessionAdapterListener, showDetails = false)

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
            sessionRecyclerView.adapter = walletConnectSessionAdapter
            closeButton.setOnClickListener { onCloseButtonClicked() }
        }
    }

    private fun onCloseButtonClicked() {
        navBack()
    }

    private fun onGetLocalSessionsSuccess(wcSessions: List<WalletConnectSession>) {
        if (wcSessions.isEmpty()) {
            navBack()
        } else {
            walletConnectSessionAdapter.submitList(wcSessions)
        }
    }
}
