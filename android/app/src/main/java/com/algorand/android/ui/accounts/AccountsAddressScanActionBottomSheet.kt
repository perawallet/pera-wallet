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

package com.algorand.android.ui.accounts

import android.os.Bundle
import android.view.View
import androidx.fragment.app.viewModels
import com.algorand.android.HomeNavigationDirections
import com.algorand.android.R
import com.algorand.android.core.BaseBottomSheet
import com.algorand.android.databinding.BottomSheetAccountsAddressScanActionBinding
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.utils.viewbinding.viewBinding
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class AccountsAddressScanActionBottomSheet : BaseBottomSheet(
    layoutResId = R.layout.bottom_sheet_accounts_address_scan_action
) {

    private val binding by viewBinding(BottomSheetAccountsAddressScanActionBinding::bind)

    private val accountsAddressScanActionViewModel by viewModels<AccountsAddressScanActionViewModel>()
    private val toolbarConfiguration = ToolbarConfiguration(
        startIconClick = ::navBack,
        startIconResId = R.drawable.ic_close,
        titleResId = R.string.address_scanned
    )

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        configureToolbar()
        initUi()
    }

    private fun configureToolbar() {
        binding.toolbar.configure(toolbarConfiguration)
    }

    private fun initUi() {
        with(binding) {
            val accountAddress = accountsAddressScanActionViewModel.getAccountAddress()
            sendTransactionButton.setOnClickListener { onSendTransactionClick() }
            addWatchAccountButton.setOnClickListener { onAddWatchAccountClick() }
            addNewContactButton.setOnClickListener { onAddContactClick() }
            accountAddressTextView.text = accountAddress
            accountAddressContainerView.setOnLongClickListener { onAccountAddressCopied(accountAddress); true }
        }
    }

    private fun onSendTransactionClick() {
        val assetTransactionArg = accountsAddressScanActionViewModel.getAssetTransactionArg()
        nav(HomeNavigationDirections.actionGlobalSendAlgoNavigation(assetTransactionArg))
    }

    private fun onAddWatchAccountClick() {
        if (accountsAddressScanActionViewModel.isAccountLimitExceed()) {
            showMaxAccountLimitExceededError()
            navBack()
            return
        }
        nav(
            AccountsAddressScanActionBottomSheetDirections
                .actionAccountsAddressScanActionBottomSheetToRegisterWatchAccountNavigation(
                    accountAddress = accountsAddressScanActionViewModel.getAccountAddress()
                )
        )
    }

    private fun onAddContactClick() {
        nav(
            HomeNavigationDirections.actionGlobalContactAdditionNavigation(
                contactName = accountsAddressScanActionViewModel.getLabel(),
                contactPublicKey = accountsAddressScanActionViewModel.getAccountAddress()
            )
        )
    }
}
