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

package com.algorand.android.modules.accountdetail.quickaction

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import androidx.navigation.NavDirections
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetAccountQuickActionsBinding
import com.algorand.android.utils.Event
import com.algorand.android.utils.emptyString
import com.algorand.android.utils.extensions.collectLatestOnLifecycle
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.flow.map

@AndroidEntryPoint
class AccountQuickActionsBottomSheet : BaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_account_quick_actions
) {

    private val accountQuickActionsViewModel by viewModels<AccountQuickActionsViewModel>()

    private val binding by viewBinding(BottomSheetAccountQuickActionsBinding::bind)

    private val onNavigationEventCollector: suspend (Event<NavDirections>?) -> Unit = { event ->
        event?.consume()?.run { nav(this) }
    }

    private val showGlobalErrorEventCollector: suspend (Event<Int>?) -> Unit = { event ->
        event?.consume()?.let { safeTitleResId ->
            showGlobalError(errorMessage = emptyString(), title = context?.getString(safeTitleResId))
        }
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
        initObservers()
    }

    private fun initUi() {
        with(binding) {
            receiveButton.setOnClickListener { navToShowQrFragment() }
            moreButton.setOnClickListener { navToAccountOptionsBottomSheet() }
            buySellButton.setOnClickListener { accountQuickActionsViewModel.onBuySellClick() }
            sendButton.setOnClickListener { accountQuickActionsViewModel.onSendClick() }
            addNewAssetButton.setOnClickListener { accountQuickActionsViewModel.onAddAssetClick() }
            swapButton.setOnClickListener { accountQuickActionsViewModel.onSwapClick() }
        }
    }

    private fun initObservers() {
        with(accountQuickActionsViewModel.accountQuickActionsPreviewFlow) {
            collectLatestOnLifecycle(
                flow = map { it.onNavigationEvent },
                collection = onNavigationEventCollector
            )
            collectLatestOnLifecycle(
                flow = map { it.showGlobalErrorEvent },
                collection = showGlobalErrorEventCollector
            )
        }
    }

    private fun navToShowQrFragment() {
        nav(
            HomeNavigationDirections.actionGlobalShowQrNavigation(
                title = getString(R.string.qr_code),
                qrText = accountQuickActionsViewModel.accountAddress
            )
        )
    }

    private fun navToAccountOptionsBottomSheet() {
        nav(
            AccountQuickActionsBottomSheetDirections.actionAccountQuickActionsBottomSheetToAccountOptionsNavigation(
                publicKey = accountQuickActionsViewModel.accountAddress
            )
        )
    }
}
