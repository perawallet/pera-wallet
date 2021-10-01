/*
 * Copyright 2019 Algorand, Inc.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 *  limitations under the License
 *
 */

package com.algorand.android.ui.wctransactiondetail

import androidx.fragment.app.viewModels
import androidx.navigation.fragment.navArgs
import com.algorand.android.R
import com.algorand.android.models.BaseAssetConfigurationTransaction
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.utils.openAssetInAlgoExplorer
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WalletConnectAssetConfigurationTransactionFragment : BaseWalletConnectTransactionDetailFragment() {

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::navBack
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    private val args by navArgs<WalletConnectAssetConfigurationTransactionFragmentArgs>()

    private val walletConnectAssetConfigurationTransactionViewModel:
        WalletConnectAssetConfigurationTransactionViewModel by viewModels()

    override val transaction: BaseAssetConfigurationTransaction
        get() = args.transaction

    override val peerMeta: WalletConnectPeerMeta
        get() = transaction.peerMeta

    override fun initUi() {
        super.initUi()
        setToolbar()
        with(walletConnectAssetConfigurationTransactionViewModel) {
            getTransactionInfo(transaction)
            getAccountsInfo(transaction)
            getExtras(transaction)
        }
    }

    private fun setToolbar() {
        getAppToolbar()?.changeTitle(getString(transaction.screenTitleResId))
    }

    override fun initObservers() {
        with(walletConnectAssetConfigurationTransactionViewModel) {
            transactionInfoLiveData.observe(viewLifecycleOwner, transactionInfoObserver)
            accountsInfoLiveData.observe(viewLifecycleOwner, accountsInfoObserver)
            extrasLiveData.observe(viewLifecycleOwner, extrasObserver)
        }
    }

    override fun onAlgoExplorerClick(assetId: Long?, networkSlug: String?) {
        context?.openAssetInAlgoExplorer(assetId, networkSlug)
    }
}
