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

package com.algorand.android.modules.accountdetail.ui

import android.os.Bundle
import android.view.View
import androidx.navigation.fragment.navArgs
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetAccountQuickActionsBinding
import com.algorand.android.models.AssetTransaction
import com.algorand.android.utils.viewbinding.viewBinding

class AccountQuickActionsBottomSheet : BaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_account_quick_actions
) {
    private val args by navArgs<AccountQuickActionsBottomSheetArgs>()

    private val binding by viewBinding(BottomSheetAccountQuickActionsBinding::bind)

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initUi()
    }

    private fun initUi() {
        with(binding) {
            buyAlgoButton.setOnClickListener { navToMoonpayNavigation() }
            sendButton.setOnClickListener { navToGlobalSendAlgoNavigation() }
            receiveButton.setOnClickListener { navToShowQrFragment() }
            addNewAssetButton.setOnClickListener { navToAddAssetFragment() }
            moreButton.setOnClickListener { navToAccountOptionsBottomSheet() }
        }
    }

    private fun navToMoonpayNavigation() {
        nav(
            AccountQuickActionsBottomSheetDirections.actionAccountQuickActionsBottomSheetToMoonpayNavigation(
                args.publicKey
            )
        )
    }

    private fun navToGlobalSendAlgoNavigation() {
        nav(
            HomeNavigationDirections.actionGlobalSendAlgoNavigation(
                assetTransaction = AssetTransaction(senderAddress = args.publicKey)
            )
        )
    }

    private fun navToShowQrFragment() {
        nav(
            HomeNavigationDirections.actionGlobalShowQrNavigation(
                title = getString(R.string.qr_code),
                qrText = args.publicKey
            )
        )
    }

    private fun navToAddAssetFragment() {
        nav(
            AccountQuickActionsBottomSheetDirections.actionAccountQuickActionsBottomSheetToAssetAdditionNavigation(
                accountAddress = args.publicKey
            )
        )
    }

    private fun navToAccountOptionsBottomSheet() {
        nav(
            AccountQuickActionsBottomSheetDirections.actionAccountQuickActionsBottomSheetToAccountOptionsNavigation(
                publicKey = args.publicKey
            )
        )
    }
}
