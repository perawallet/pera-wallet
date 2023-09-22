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

package com.algorand.android.modules.accountdetail.quickaction.watchaccount

import android.os.Bundle
import android.view.View
import androidx.navigation.fragment.navArgs
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetWatchAccountQuickActionsBinding
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WatchAccountQuickActionsBottomSheet : BaseBottomSheet(
    R.layout.bottom_sheet_watch_account_quick_actions
) {

    private val binding by viewBinding(BottomSheetWatchAccountQuickActionsBinding::bind)

    private val args: WatchAccountQuickActionsBottomSheetArgs by navArgs()

    private val accountAddress: String
        get() = args.publicKey

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
    }

    private fun initUi() {
        with(binding) {
            showAddressButton.setOnClickListener { onShowAddressClick() }
            moreButton.setOnClickListener { navToAccountOptionsBottomSheet() }
            copyAddressButton.setOnClickListener { onCopyAddressClick() }
        }
    }

    private fun onShowAddressClick() {
        nav(
            HomeNavigationDirections.actionGlobalShowQrNavigation(
                title = getString(R.string.qr_code),
                qrText = accountAddress
            )
        )
    }

    private fun onCopyAddressClick() {
        onAccountAddressCopied(accountAddress)
        navBack()
    }

    private fun navToAccountOptionsBottomSheet() {
        nav(
            WatchAccountQuickActionsBottomSheetDirections
                .actionWatchAccountQuickActionsBottomSheetToAccountOptionsNavigation(accountAddress)
        )
    }
}
