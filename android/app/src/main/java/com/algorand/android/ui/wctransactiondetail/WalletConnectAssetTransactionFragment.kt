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
import com.algorand.android.models.BaseAssetTransferTransaction
import com.algorand.android.models.FragmentConfiguration
import com.algorand.android.models.ToolbarConfiguration
import com.algorand.android.models.WalletConnectPeerMeta
import com.algorand.android.utils.openAssetInAlgoExplorer
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class WalletConnectAssetTransactionFragment : BaseWalletConnectTransactionDetailFragment() {

    private val walletConnectAssetTransactionViewModel: WalletConnectAssetTransactionViewModel by viewModels()
    private val args: WalletConnectAssetTransactionFragmentArgs by navArgs()

    private val toolbarConfiguration = ToolbarConfiguration(
        startIconResId = R.drawable.ic_back_navigation,
        startIconClick = ::navBack,
    )

    override val fragmentConfiguration = FragmentConfiguration(toolbarConfiguration = toolbarConfiguration)

    override val transaction: BaseAssetTransferTransaction
        get() = args.transaction

    override val peerMeta: WalletConnectPeerMeta
        get() = transaction.peerMeta

    override fun initUi() {
        super.initUi()
        setToolbarTitle()
        with(walletConnectAssetTransactionViewModel) {
            getAmountInfo(transaction)
            getTransactionInfo(transaction)
            getExtras(transaction)
        }
        setCloseToLabel(R.string.close_asset_to)
        setCloseToWarning(
            getString(R.string.this_transaction_is_sending_asset, transaction.assetParams?.shortName.orEmpty())
        )
    }

    private fun setToolbarTitle() {
        val toolbarTitleRes: Int = when (transaction) {
            is BaseAssetTransferTransaction.AssetOptInTransaction -> R.string.assets_opt_in_request
            else -> R.string.transfer_asset_request
        }
        val toolbarTitle: String = getString(toolbarTitleRes)
        getAppToolbar()?.changeTitle(toolbarTitle)
    }

    override fun initObservers() {
        with(walletConnectAssetTransactionViewModel) {
            amountInfoLiveData.observe(viewLifecycleOwner, amountInfoObserver)
            transactionInfoLiveData.observe(viewLifecycleOwner, transactionInfoObserver)
            extrasLiveData.observe(viewLifecycleOwner, extrasObserver)
        }
    }

    override fun onAlgoExplorerClick(assetId: Long?, networkSlug: String?) {
        context?.openAssetInAlgoExplorer(assetId, networkSlug)
    }
}
